import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lingolearn/core/services/audio_attempt_recorder.dart';
import 'package:lingolearn/features/pronunciation/data/pronunciation_assessment_result_model.dart';
import 'package:lingolearn/features/pronunciation/data/pronunciation_assessment_service.dart';
import 'package:lingolearn/features/pronunciation/data/pronunciation_audio_analyzer.dart';
import 'package:lingolearn/features/pronunciation/data/pronunciation_issues.dart';
import 'package:lingolearn/features/pronunciation/data/pronunciation_token_provider.dart';
import 'package:lingolearn/features/pronunciation/presentation/pronunciation_controller.dart';
import 'package:lingolearn/features/vocabulary/data/language_word.dart';

class _FakeAttemptRecorder implements AttemptAudioRecorder {
  bool _isRecording = false;
  bool permissionGranted = true;
  bool pluginAvailable = true;
  bool startSucceeds = true;

  @override
  bool get isRecording => _isRecording;

  @override
  Future<bool> isPluginAvailable() async => pluginAvailable;

  @override
  Future<bool> hasPermission() async => permissionGranted;

  @override
  Future<bool> start({
    required String path,
    AttemptAudioFormat format = AttemptAudioFormat.compressed,
  }) async {
    if (!permissionGranted || !startSucceeds) return false;
    _isRecording = true;
    return true;
  }

  @override
  Future<String?> stop() async {
    _isRecording = false;
    return r'C:\tmp\lingo_attempt_test.wav';
  }

  @override
  Future<void> cancel() async {
    _isRecording = false;
  }
}

class _FakeAnalyzer implements PronunciationAudioAnalyzer {
  final PronunciationAudioAnalysis analysis;

  _FakeAnalyzer(this.analysis);

  @override
  Future<PronunciationAudioAnalysis?> analyzeWav(String path) async => analysis;

  @override
  PronunciationAudioAnalysis analyzeBytes(Uint8List bytes) => analysis;
}

class _FakeScorer implements PronunciationScoringGateway {
  final PronunciationAssessmentResultModel? result;
  final PronunciationServiceException? error;

  _FakeScorer({this.result, this.error});

  @override
  Future<PronunciationAssessmentResultModel> assess({
    required String target,
    required String audioPath,
    required AzureAccess access,
    required int attempt,
    String? referenceAudioUrl,
  }) async {
    if (error != null) throw error!;
    return result!;
  }
}

class _FakeTokenProvider implements PronunciationTokenProvider {
  final AzureAccess token;

  _FakeTokenProvider({AzureAccess? token})
    : token =
          token ??
          AzureAccess(
            token: 't',
            endpoint: 'https://example.com/v1',
            expiresAt: DateTime.now().add(const Duration(hours: 1)),
          );

  @override
  Future<AzureAccess> access() async => token;

  @override
  Future<void> clear() async {}
}

LanguageWord _word() {
  return LanguageWord(
    id: 'w1',
    word: 'beautiful',
    translation: 'جميل',
    pronunciation: 'BYOO-tuh-fuhl',
    example: 'A beautiful sunset.',
    category: 'Common Words',
  );
}

PronunciationAudioAnalysis _speech({
  double duration = 2.0,
  bool hasSpeech = true,
  bool clipped = false,
}) {
  return PronunciationAudioAnalysis(
    validWav: true,
    sampleRate: 16000,
    channels: 1,
    bitsPerSample: 16,
    durationSeconds: duration,
    rmsDb: hasSpeech ? -25 : -80,
    peakDb: clipped ? -0.1 : (hasSpeech ? -12 : -80),
    clipped: clipped,
  );
}

PronunciationAssessmentResultModel _scoredResult(int attempt) {
  return PronunciationAssessmentResultModel(
    target: 'beautiful',
    recognitionStatus: 'Success',
    recognizedText: 'beautiful',
    overallScore: 92,
    accuracyScore: 95,
    fluencyScore: 90,
    completenessScore: 100,
    prosodyScore: 88,
    wordResults: const [
      AssessmentWordResult(
        word: 'beautiful',
        accuracy: 95,
        errorType: PronunciationErrorType.none,
        phonemes: [
          AssessmentPhoneme(phone: 'b', accuracy: 98),
          AssessmentPhoneme(phone: 'y', accuracy: 92),
        ],
      ),
    ],
    attempt: attempt,
  );
}

PronunciationAssessmentResultModel _needsWorkResult(int attempt) {
  return PronunciationAssessmentResultModel(
    target: 'beautiful',
    recognitionStatus: 'Success',
    recognizedText: 'beautiful',
    overallScore: 54,
    accuracyScore: 50,
    fluencyScore: 70,
    completenessScore: 90,
    wordResults: const [
      AssessmentWordResult(
        word: 'beautiful',
        accuracy: 50,
        errorType: PronunciationErrorType.mispronunciation,
        phonemes: [
          AssessmentPhoneme(phone: 'θ', accuracy: 30),
          AssessmentPhoneme(phone: 'r', accuracy: 88),
        ],
      ),
    ],
    attempt: attempt,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('initialize ends in idle with mic permission granted', (
    tester,
  ) async {
    final controller = PronunciationController(
      initialWord: _word(),
      recorder: _FakeAttemptRecorder(),
      analyzer: _FakeAnalyzer(_speech()),
    );
    await tester.runAsync(() => controller.initialize());

    expect(
      controller.phase,
      PronunciationPhase.idle,
      reason: 'init must always terminate in idle, never stay on checking',
    );
    expect(controller.issue, isNull);
    controller.dispose();
  });

  testWidgets('record -> stop produces an engine result with attempt audio', (
    tester,
  ) async {
    final controller = PronunciationController(
      initialWord: _word(),
      recorder: _FakeAttemptRecorder(),
      analyzer: _FakeAnalyzer(_speech()),
      scorer: _FakeScorer(result: _scoredResult(1)),
      tokenProvider: _FakeTokenProvider(),
    );
    await tester.runAsync(() async {
      await controller.initialize();
      await controller.startRecording();
      expect(controller.isRecording, isTrue);
      expect(
        (controller.phase == PronunciationPhase.listening ||
            controller.phase == PronunciationPhase.recording),
        isTrue,
        reason: 'capture must transition through listening/recording',
      );

      await controller.stopRecording();
    });

    expect(controller.phase, PronunciationPhase.result);
    expect(controller.result, isNotNull);
    expect(
      controller.result!.hasScores,
      isTrue,
      reason: 'engine scores must flow into the controller result',
    );
    expect(
      controller.attemptAudioPath,
      isNotNull,
      reason: 'the replayed attempt audio must be preserved',
    );
    expect(controller.issue, isNull);
    controller.dispose();
  });

  testWidgets('a short attempt surfaces recordingTooShort (no hang)', (
    tester,
  ) async {
    final controller = PronunciationController(
      initialWord: _word(),
      recorder: _FakeAttemptRecorder(),
      analyzer: _FakeAnalyzer(_speech(duration: 0.4)),
      scorer: _FakeScorer(result: _scoredResult(1)),
      tokenProvider: _FakeTokenProvider(),
    );
    await tester.runAsync(() async {
      await controller.initialize();
      await controller.startRecording();
      await controller.stopRecording();
    });

    expect(controller.phase, PronunciationPhase.idle);
    expect(controller.issue, PronunciationIssue.recordingTooShort);
    expect(controller.result, isNull);
    controller.dispose();
  });

  testWidgets('a quiet attempt maps to audioTooQuiet, never a fake score', (
    tester,
  ) async {
    final controller = PronunciationController(
      initialWord: _word(),
      recorder: _FakeAttemptRecorder(),
      analyzer: _FakeAnalyzer(_speech(hasSpeech: false)),
      scorer: _FakeScorer(result: _scoredResult(1)),
      tokenProvider: _FakeTokenProvider(),
    );
    await tester.runAsync(() async {
      await controller.initialize();
      await controller.startRecording();
      await controller.stopRecording();
    });

    expect(controller.phase, PronunciationPhase.idle);
    expect(controller.issue, PronunciationIssue.audioTooQuiet);
    expect(controller.result, isNull);
    controller.dispose();
  });

  testWidgets('unconfigured backend -> assessmentUnavailable, audio kept', (
    tester,
  ) async {
    final controller = PronunciationController(
      initialWord: _word(),
      recorder: _FakeAttemptRecorder(),
      analyzer: _FakeAnalyzer(_speech()),
      scorer: _FakeScorer(error: const PronunciationUnconfiguredException()),
      tokenProvider: _FakeTokenProvider(),
    );
    await tester.runAsync(() async {
      await controller.initialize();
      await controller.startRecording();
      await controller.stopRecording();
    });

    expect(controller.phase, PronunciationPhase.idle);
    expect(controller.issue, PronunciationIssue.assessmentUnavailable);
    expect(
      controller.attemptAudioPath,
      isNotNull,
      reason: 'the attempt file must survive server-side errors until retry',
    );
    controller.dispose();
  });

  testWidgets('a network outage maps to networkError', (tester) async {
    final controller = PronunciationController(
      initialWord: _word(),
      recorder: _FakeAttemptRecorder(),
      analyzer: _FakeAnalyzer(_speech()),
      scorer: _FakeScorer(error: const PronunciationNetworkException()),
      tokenProvider: _FakeTokenProvider(),
    );
    await tester.runAsync(() async {
      await controller.initialize();
      await controller.startRecording();
      await controller.stopRecording();
    });

    expect(controller.issue, PronunciationIssue.networkError);
    expect(controller.result, isNull);
    controller.dispose();
  });

  testWidgets('a failed recorder start surfaces recordingFailed', (
    tester,
  ) async {
    final recorder = _FakeAttemptRecorder()..startSucceeds = false;
    final controller = PronunciationController(
      initialWord: _word(),
      recorder: recorder,
      analyzer: _FakeAnalyzer(_speech()),
    );
    await tester.runAsync(() async {
      await controller.initialize();
      await controller.startRecording();
    });

    expect(controller.phase, PronunciationPhase.idle);
    expect(controller.issue, PronunciationIssue.recordingFailed);
    expect(controller.isRecording, isFalse);
    controller.dispose();
  });

  testWidgets('a clipped attempt -> recordingClipped, audio stays replayable', (
    tester,
  ) async {
    final controller = PronunciationController(
      initialWord: _word(),
      recorder: _FakeAttemptRecorder(),
      analyzer: _FakeAnalyzer(_speech(clipped: true)),
      scorer: _FakeScorer(result: _scoredResult(1)),
      tokenProvider: _FakeTokenProvider(),
    );
    await tester.runAsync(() async {
      await controller.initialize();
      await controller.startRecording();
      await controller.stopRecording();
    });

    expect(controller.phase, PronunciationPhase.idle);
    expect(controller.issue, PronunciationIssue.recordingClipped);
    expect(
      controller.attemptAudioPath,
      isNotNull,
      reason: 'distorted audio must remain alive so the user can replay it',
    );
    controller.dispose();
  });

  testWidgets(
    'a clear recording peaking at 0 dBFS is still sent for assessment',
    (tester) async {
      final controller = PronunciationController(
        initialWord: _word(),
        recorder: _FakeAttemptRecorder(),
        analyzer: _FakeAnalyzer(
          const PronunciationAudioAnalysis(
            validWav: true,
            sampleRate: 16000,
            channels: 1,
            bitsPerSample: 16,
            durationSeconds: 2.0,
            rmsDb: -25,
            peakDb: 0.0,
            clippedSampleCount: 3,
            clippedPercentage: 0.01,
            longestClippedRun: 1,
            quality: AudioQuality.acceptable,
            clipped: false,
          ),
        ),
        scorer: _FakeScorer(result: _scoredResult(1)),
        tokenProvider: _FakeTokenProvider(),
      );
      await tester.runAsync(() async {
        await controller.initialize();
        await controller.startRecording();
        await controller.stopRecording();
      });

      expect(
        controller.phase,
        PronunciationPhase.result,
        reason: 'a few full-scale samples must NOT block assessment',
      );
      expect(controller.issue, isNull);
      expect(controller.result, isNotNull);
      expect(
        controller.attemptAudioPath,
        isNotNull,
        reason: 'the clean attempt remains replayable',
      );
      controller.dispose();
    },
  );

  testWidgets('a low-scoring result exposes focus phonemes, retry resets', (
    tester,
  ) async {
    final controller = PronunciationController(
      initialWord: _word(),
      recorder: _FakeAttemptRecorder(),
      analyzer: _FakeAnalyzer(_speech()),
      scorer: _FakeScorer(result: _needsWorkResult(1)),
      tokenProvider: _FakeTokenProvider(),
    );
    await tester.runAsync(() async {
      await controller.initialize();
      await controller.startRecording();
      await controller.stopRecording();
    });

    expect(controller.phase, PronunciationPhase.result);
    expect(
      controller.focusPhones,
      contains('θ'),
      reason: 'failing phonemes feed the retry focus hint',
    );
    expect(controller.focusPhones, isNot(contains('r')));

    await tester.runAsync(() => controller.retry());
    expect(controller.phase, PronunciationPhase.idle);
    expect(controller.result, isNull);
    expect(
      controller.attemptAudioPath,
      isNull,
      reason: 'retry clears the previous attempt so the next one replaces it',
    );
    controller.dispose();
  });

  testWidgets('retry keeps preselecting the same target and counts attempts', (
    tester,
  ) async {
    final controller = PronunciationController(
      initialWord: _word(),
      recorder: _FakeAttemptRecorder(),
      analyzer: _FakeAnalyzer(_speech()),
      scorer: _FakeScorer(result: _scoredResult(1)),
      tokenProvider: _FakeTokenProvider(),
    );
    await tester.runAsync(() async {
      await controller.initialize();
      await controller.startRecording();
      await controller.stopRecording();
      await controller.retry();
      await controller.startRecording();
      await controller.stopRecording();
    });

    expect(controller.phase, PronunciationPhase.result);
    expect(
      controller.attemptCount,
      2,
      reason: 'retry keeps the attempt counter for the same target',
    );
    expect(controller.word.word, 'beautiful');
    controller.dispose();
  });
}
