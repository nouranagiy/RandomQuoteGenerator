import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/services/audio_attempt_recorder.dart';
import '../../../core/utils/debug_log.dart';
import '../../vocabulary/data/language_storage.dart';
import '../../vocabulary/data/language_word.dart';
import '../data/pronunciation_assessment_result_model.dart';
import '../data/pronunciation_assessment_service.dart';
import '../data/pronunciation_audio_analyzer.dart';
import '../data/pronunciation_issues.dart';
import '../data/pronunciation_token_provider.dart';

enum PronunciationPhase {
  checking,
  idle,
  preparing,
  listening,
  recording,
  stopping,
  analyzing,
  result,
}

const Duration _minAttemptDuration = Duration(milliseconds: 1200);

const Duration _maxRecordingDuration = Duration(seconds: 15);

const Duration _operationWatchdog = Duration(seconds: 35);

class PronunciationController extends ChangeNotifier {
  PronunciationController({
    required LanguageWord initialWord,
    PronunciationScoringGateway? scorer,
    PronunciationTokenProvider? tokenProvider,
    PronunciationAudioAnalyzer? analyzer,
    LanguageStorage? storage,
    AttemptAudioRecorder? recorder,
  }) : _word = initialWord,
       _scorer = scorer,
       _tokens = tokenProvider,
       _analyzer = analyzer ?? const PronunciationAudioAnalyzer(),
       _storage = storage ?? LanguageStorage(),
       _recorder = recorder ?? AudioAttemptRecorder();

  LanguageWord _word;
  final PronunciationScoringGateway? _scorer;
  final PronunciationTokenProvider? _tokens;
  final PronunciationAudioAnalyzer _analyzer;
  final LanguageStorage _storage;
  final AttemptAudioRecorder _recorder;

  LanguageWord get word => _word;

  PronunciationScoringGateway get _scoring =>
      _scorer ?? PronunciationAssessmentService();
  PronunciationTokenProvider get _tokenProvider =>
      _tokens ?? AzureTokenProvider();

  PronunciationPhase _phase = PronunciationPhase.checking;
  PronunciationAssessmentResultModel? _result;
  PronunciationIssue? _issue;
  int _attempt = 0;
  String? _attemptAudioPath;
  List<String> _focusPhones = const [];
  Timer? _elapsedTimer;
  Timer? _watchdog;
  DateTime? _captureStartedAt;
  double _elapsedSeconds = 0;
  bool _isDisposed = false;

  PronunciationPhase get phase => _phase;
  PronunciationAssessmentResultModel? get result => _result;
  PronunciationIssue? get issue => _issue;
  String? get attemptAudioPath => _attemptAudioPath;
  List<String> get focusPhones => _focusPhones;
  int get attemptCount => _attempt;
  double get elapsedSeconds => _elapsedSeconds;
  bool get isRecording =>
      _phase == PronunciationPhase.listening ||
      _phase == PronunciationPhase.recording;
  bool get isBusy =>
      _phase == PronunciationPhase.preparing ||
      _phase == PronunciationPhase.listening ||
      _phase == PronunciationPhase.recording ||
      _phase == PronunciationPhase.stopping ||
      _phase == PronunciationPhase.analyzing;

  Future<void> initialize() async {
    _issue = null;
    _phase = PronunciationPhase.checking;
    _notify();

    if (!await _recorder.isPluginAvailable()) {
      _issue = PronunciationIssue.micUnavailable;
      debugLog('PronunciationAudio', 'plugin unavailable -> micUnavailable');
    } else if (!await _recorder.hasPermission()) {
      _issue = PronunciationIssue.permissionDenied;
      debugLog('PronunciationAudio', 'mic permission denied');
    }

    _phase = PronunciationPhase.idle;
    _notify();
  }

  Future<void> startRecording() async {
    if (isBusy || _issue != null) return;

    _armWatchdog();
    _phase = PronunciationPhase.preparing;
    _notify();

    if (!await _recorder.hasPermission()) {
      _issue = PronunciationIssue.permissionDenied;
      _stopTimers();
      _phase = PronunciationPhase.idle;
      _notify();
      return;
    }

    _attempt++;
    _result = null;
    _issue = null;
    await _deleteAttemptFile(_attemptAudioPath);
    _attemptAudioPath = null;
    _elapsedSeconds = 0;
    _captureStartedAt = null;

    bool started;
    try {
      started = await _recorder.start(
        path: _attemptPath(),
        format: AttemptAudioFormat.pcmWav16kMono,
      );
    } catch (e) {
      debugLog('PronunciationAudio', 'start threw: $e');
      started = false;
    }

    if (!started) {
      _issue = PronunciationIssue.recordingFailed;
      _stopTimers();
      _phase = PronunciationPhase.idle;
      _notify();
      return;
    }

    _captureStartedAt = DateTime.now().toUtc();
    _phase = PronunciationPhase.listening;
    _notify();
    debugLog(
      'PronunciationAudio',
      'attempt $_attempt listening (WAV/16k/mono)',
    );
    _elapsedTimer = Timer.periodic(
      const Duration(milliseconds: 120),
      _onCaptureTick,
    );
  }

  Future<void> stopRecording() async {
    if (!isRecording) return;

    _phase = PronunciationPhase.stopping;
    _notify();

    final path = await _recorder.stop();
    _stopTimers();

    if (path == null || path.trim().isEmpty) {
      _issue = PronunciationIssue.recordingFailed;
      _failRecording();
      _phase = PronunciationPhase.idle;
      _notify();
      return;
    }
    _attemptAudioPath = path;
    debugLog('PronunciationAudio', 'captured $_attemptAudioPath');

    _phase = PronunciationPhase.analyzing;
    _notify();

    final localIssue = await _validateAttempt();
    if (localIssue != null) {
      _issue = localIssue;
      _stopTimers();
      // Keep the file for anything that captured real sound so it can be
      // replayed while the user retries; drop unusable audio only.
      final keepFile =
          localIssue == PronunciationIssue.audioTooQuiet ||
          localIssue == PronunciationIssue.recordingClipped;
      if (!keepFile) await _failRecording();
      _phase = PronunciationPhase.idle;
      _notify();
      return;
    }

    await _assess();
  }

  void _onCaptureTick(Timer timer) {
    if (!isRecording) return;
    final started = _captureStartedAt;
    if (started == null) return;

    _elapsedSeconds =
        DateTime.now().toUtc().difference(started).inMilliseconds / 1000.0;

    if (_phase == PronunciationPhase.listening &&
        _elapsedSeconds >= _minAttemptDuration.inMilliseconds / 1000.0) {
      _phase = PronunciationPhase.recording;
      debugLog('PronunciationAudio', 'min attempt reached -> recording');
    }

    if (_elapsedSeconds >= _maxRecordingDuration.inSeconds) {
      debugLog('PronunciationAudio', 'max duration reached -> auto stop');
      unawaited(stopRecording());
      return;
    }

    _notify();
  }

  void _armWatchdog() {
    _watchdog?.cancel();
    _watchdog = Timer(_operationWatchdog, _onOperationStalled);
  }

  void _onOperationStalled() {
    debugLog('PronunciationAudio', 'watchdog fired during ${_phase.name}');
    final wasCapturing =
        _phase == PronunciationPhase.preparing ||
        _phase == PronunciationPhase.listening ||
        _phase == PronunciationPhase.recording ||
        _phase == PronunciationPhase.stopping;
    _issue = wasCapturing
        ? PronunciationIssue.recordingFailed
        : PronunciationIssue.assessmentTimedOut;
    unawaited(_recorder.cancel());
    _stopTimers();
    if (wasCapturing) unawaited(_failRecording());
    _phase = PronunciationPhase.idle;
    _notify();
  }

  void _stopTimers() {
    _elapsedTimer?.cancel();
    _elapsedTimer = null;
    _captureStartedAt = null;
    _watchdog?.cancel();
    _watchdog = null;
  }

  Future<PronunciationIssue?> _validateAttempt() async {
    final analysis = await _analyzer.analyzeWav(_attemptAudioPath!);
    if (analysis == null) {
      return PronunciationIssue.recordingFailed;
    }
    if (!analysis.validWav) {
      debugLog(
        'PronunciationAudio',
        'invalid WAV '
            '(rate=${analysis.sampleRate} ch=${analysis.channels} '
            'bits=${analysis.bitsPerSample}) -> invalidAudioFormat',
      );
      return PronunciationIssue.invalidAudioFormat;
    }
    if (analysis.durationSeconds < _minAttemptDuration.inMilliseconds / 1000) {
      debugLog(
        'PronunciationAudio',
        '${analysis.durationSeconds.toStringAsFixed(2)}s < '
            '${_minAttemptDuration.inMilliseconds}ms -> recordingTooShort',
      );
      return PronunciationIssue.recordingTooShort;
    }
    _logAudioQuality(analysis);
    if (!analysis.hasSpeech) {
      debugLog('PronunciationAudio', 'quiet/silent -> audioTooQuiet');
      return PronunciationIssue.audioTooQuiet;
    }
    if (analysis.clipped) {
      debugLog(
        'PronunciationAudio',
        'sustained clipping '
            '(${analysis.clippedSampleCount} samples, '
            '${analysis.clippedPercentage.toStringAsFixed(2)}%, '
            'longest run ${analysis.longestClippedRun}) '
            '-> recordingClipped',
      );
      return PronunciationIssue.recordingClipped;
    }
    debugLog(
      'PronunciationAudio',
      'WAV ok '
          '(${analysis.durationSeconds.toStringAsFixed(2)}s, '
          'peak ${analysis.peakDb.toStringAsFixed(1)} dBFS, '
          'rms ${analysis.rmsDb.toStringAsFixed(1)} dBFS)',
    );
    return null;
  }

  void _logAudioQuality(PronunciationAudioAnalysis analysis) {
    debugLog(
      'PronunciationAudio',
      'duration: ${analysis.durationSeconds.toStringAsFixed(2)}s',
    );
    debugLog(
      'PronunciationAudio',
      'peak: ${analysis.peakDb.toStringAsFixed(1)} dBFS',
    );
    debugLog(
      'PronunciationAudio',
      'rms: ${analysis.rmsDb.toStringAsFixed(1)} dBFS',
    );
    debugLog(
      'PronunciationAudio',
      'clipped samples: ${analysis.clippedSampleCount}',
    );
    debugLog(
      'PronunciationAudio',
      'clipped percentage: ${analysis.clippedPercentage.toStringAsFixed(2)}%',
    );
    debugLog(
      'PronunciationAudio',
      'longest clipped run: ${analysis.longestClippedRun} samples',
    );
    debugLog('PronunciationAudio', 'audio quality: ${analysis.quality.label}');
  }

  Future<void> _assess() async {
    _phase = PronunciationPhase.analyzing;
    _notify();
    try {
      final access = await _tokenProvider.access();
      final result = await _scoring.assess(
        target: _word.word,
        audioPath: _attemptAudioPath!,
        access: access,
        attempt: _attempt,
        referenceAudioUrl: _word.audioUrl,
      );
      _result = result;
      _focusPhones = _failingPhones(result);
      debugLog(
        'PronunciationAssessment',
        'status=${result.recognitionStatus} '
            'scored=${result.hasScores} '
            'overall=${result.overallScore}',
      );
      _stopTimers();
      _phase = PronunciationPhase.result;
      _notify();
    } on PronunciationUnconfiguredException {
      debugLog(
        'PronunciationAssessment',
        'not configured (set --dart-define=LINGOLEARN_AZURE_TOKEN_URL)',
      );
      _issue = PronunciationIssue.assessmentUnavailable;
      _failAndIdle();
    } on PronunciationTokenException {
      debugLog('PronunciationAssessment', 'token failure');
      _issue = PronunciationIssue.tokenFailed;
      _failAndIdle();
    } on PronunciationTimeoutException {
      debugLog('PronunciationAssessment', 'timeout');
      _issue = PronunciationIssue.assessmentTimedOut;
      _failAndIdle();
    } on PronunciationNetworkException {
      debugLog('PronunciationAssessment', 'network error');
      _issue = PronunciationIssue.networkError;
      _failAndIdle();
    } on PronunciationHttpException catch (e) {
      debugLog('PronunciationAssessment', 'HTTP ${e.statusCode}');
      _issue = (e.statusCode == 401 || e.statusCode == 403)
          ? PronunciationIssue.tokenFailed
          : PronunciationIssue.assessmentFailed;
      _failAndIdle();
    } on PronunciationRecognitionStatusException catch (e) {
      _issue = switch (e.status) {
        'InitialSilenceTimeout' => PronunciationIssue.noSpeechDetected,
        'BabbleTimeout' => PronunciationIssue.unclearAudio,
        _ => PronunciationIssue.assessmentFailed,
      };
      debugLog('PronunciationAssessment', 'status ${e.status} -> $_issue');
      _failAndIdle();
    } on PronunciationMalformedResponseException {
      debugLog('PronunciationAssessment', 'malformed response');
      _issue = PronunciationIssue.malformedResponse;
      _failAndIdle();
    } on Object catch (e) {
      debugLog('PronunciationAssessment', 'unexpected failure: $e');
      _issue = PronunciationIssue.assessmentFailed;
      _failAndIdle();
    }
  }

  List<String> _failingPhones(PronunciationAssessmentResultModel result) {
    final phones = <String>[];
    for (final word in result.wordResults) {
      for (final phoneme in word.phonemes) {
        if (phoneme.accuracy < 60 && !phones.contains(phoneme.phone)) {
          phones.add(phoneme.phone);
        }
      }
    }
    return phones;
  }

  Future<void> retry() async {
    await _deleteAttemptFile(_attemptAudioPath);
    _result = null;
    _attemptAudioPath = null;
    _issue = null;
    _elapsedSeconds = 0;
    _stopTimers();
    _phase = PronunciationPhase.idle;
    _notify();
  }

  Future<void> nextWord() async {
    await _deleteAttemptFile(_attemptAudioPath);
    final words = await _storage.getWords();
    if (words.isEmpty) return;

    final sameCategory = words
        .where((w) => w.category == _word.category && w.id != _word.id)
        .toList();
    final anyOther = words.firstWhere(
      (w) => w.id != _word.id,
      orElse: () => words.first,
    );

    _word = sameCategory.isNotEmpty ? sameCategory.first : anyOther;
    _attempt = 0;
    _result = null;
    _issue = null;
    _attemptAudioPath = null;
    _focusPhones = const [];
    _elapsedSeconds = 0;
    _stopTimers();
    _phase = PronunciationPhase.idle;
    _notify();
  }

  String _attemptPath() {
    final dir = Directory.systemTemp;
    if (!dir.existsSync()) {
      try {
        dir.createSync(recursive: true);
      } catch (_) {}
    }
    return '${dir.path}${Platform.pathSeparator}lingo_attempt_${const Uuid().v4()}.wav';
  }

  Future<void> _failAndIdle() async {
    _stopTimers();
    _phase = PronunciationPhase.idle;
    _notify();
  }

  Future<void> _failRecording() async {
    await _deleteAttemptFile(_attemptAudioPath);
    _attemptAudioPath = null;
  }

  Future<void> _deleteAttemptFile(String? path) async {
    if (path == null || path.isEmpty) return;
    try {
      await File(path).delete().catchError((_) => File(path));
    } catch (_) {}
  }

  void _notify() {
    if (_isDisposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _stopTimers();
    unawaited(_recorder.cancel());
    unawaited(_deleteAttemptFile(_attemptAudioPath));
    unawaited(_tokenProvider.clear());
    super.dispose();
  }
}
