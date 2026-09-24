import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_error.dart';
import '../../../core/widgets/app_loading.dart';
import '../../vocabulary/data/language_word.dart';
import '../data/pronunciation_issues.dart';
import 'pronunciation_controller.dart';
import 'widgets/pronunciation_audio_controls.dart';
import 'widgets/pronunciation_header.dart';
import 'widgets/pronunciation_loading_view.dart';
import 'widgets/pronunciation_record_button.dart';
import 'widgets/pronunciation_result_view.dart';
import 'widgets/target_word_card.dart';

class PronunciationScreen extends StatefulWidget {
  final LanguageWord word;

  const PronunciationScreen({super.key, required this.word});

  @override
  State<PronunciationScreen> createState() => _PronunciationScreenState();
}

class _PronunciationScreenState extends State<PronunciationScreen> {
  late final PronunciationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PronunciationController(initialWord: widget.word);
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.pronunciationPractice)),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) => _buildBody(l),
      ),
    );
  }

  Widget _buildBody(AppLocalizations l) {
    final issue = _controller.issue;
    if (issue != null) {
      if (_controller.attemptAudioPath != null) {
        return _buildIssueWithAudio(issue, l);
      }
      return AppError(
        message: _messageFor(issue, l),
        onRetry: _controller.retry,
      );
    }

    switch (_controller.phase) {
      case PronunciationPhase.checking:
        return const AppLoading();
      case PronunciationPhase.preparing:
        return _buildContent(
          l,
          showHeader: true,
          showLoading: false,
          transitional: true,
          statusLabel: l.preparingRecording,
        );
      case PronunciationPhase.listening:
      case PronunciationPhase.recording:
        return _buildContent(l, showHeader: true, showLoading: false);
      case PronunciationPhase.stopping:
        return _buildContent(
          l,
          showHeader: false,
          showLoading: true,
          transitional: true,
        );
      case PronunciationPhase.analyzing:
        return _buildContent(l, showHeader: false, showLoading: true);
      case PronunciationPhase.idle:
      case PronunciationPhase.result:
        return _buildContent(l, showHeader: true, showLoading: false);
    }
  }

  Widget _buildIssueWithAudio(PronunciationIssue issue, AppLocalizations l) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        PronunciationHeader(isRecording: false),
        const SizedBox(height: 18),
        TargetWordCard(word: _controller.word),
        const SizedBox(height: 24),
        _IssueBanner(message: _messageFor(issue, l)),
        const SizedBox(height: 20),
        PronunciationAudioControls(
          word: _controller.word.word,
          referenceAudioUrl: _controller.word.audioUrl,
          attemptAudioPath: _controller.attemptAudioPath,
        ),
        const SizedBox(height: 24),
        Center(
          child: AppButton(
            text: l.tryAgain,
            icon: Icons.refresh_rounded,
            onPressed: _controller.retry,
          ),
        ),
      ],
    );
  }

  String _messageFor(PronunciationIssue issue, AppLocalizations l) {
    switch (issue) {
      case PronunciationIssue.permissionDenied:
        return l.microphonePermissionDenied;
      case PronunciationIssue.micUnavailable:
        return l.micUnavailable;
      case PronunciationIssue.recordingFailed:
        return l.recordingFailed;
      case PronunciationIssue.recordingTooShort:
        return l.recordingTooShort;
      case PronunciationIssue.recordingClipped:
        return l.recordingClipped;
      case PronunciationIssue.noSpeechDetected:
        return l.noSpeechDetected;
      case PronunciationIssue.audioTooQuiet:
        return l.audioTooQuiet;
      case PronunciationIssue.unclearAudio:
        return l.unclearAudio;
      case PronunciationIssue.invalidAudioFormat:
        return l.invalidAudioFormat;
      case PronunciationIssue.assessmentUnavailable:
        return l.assessmentUnavailable;
      case PronunciationIssue.tokenFailed:
        return l.tokenFailed;
      case PronunciationIssue.networkError:
        return l.assessmentNetworkError;
      case PronunciationIssue.assessmentTimedOut:
        return l.assessmentTimedOut;
      case PronunciationIssue.assessmentFailed:
        return l.assessmentFailed;
      case PronunciationIssue.malformedResponse:
        return l.malformedResponse;
    }
  }

  Widget _buildContent(
    AppLocalizations l, {
    required bool showHeader,
    required bool showLoading,
    bool transitional = false,
    String? statusLabel,
  }) {
    final result = _controller.result;
    final isRecording = _controller.isRecording;
    final busy = showLoading || transitional;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (showHeader) ...[
          PronunciationHeader(
            isRecording: isRecording,
            subtitle: isRecording ? _elapsedLabel(l) : null,
          ),
          const SizedBox(height: 18),
        ],
        TargetWordCard(word: _controller.word),
        const SizedBox(height: 32),
        Center(
          child: PronunciationRecordButton(
            isRecording: isRecording,
            enabled: !busy,
            onPressed: isRecording
                ? _controller.stopRecording
                : _controller.startRecording,
            liveText:
                statusLabel ??
                (isRecording
                    ? (_controller.phase == PronunciationPhase.listening
                          ? l.listening
                          : l.recording)
                    : ''),
          ),
        ),
        const SizedBox(height: 24),
        if (_controller.phase == PronunciationPhase.idle &&
            _controller.focusPhones.isNotEmpty) ...[
          _FocusHint(phones: _controller.focusPhones),
          const SizedBox(height: 16),
        ],
        if (showLoading)
          const PronunciationLoadingView()
        else if (result != null)
          PronunciationResultView(
            result: result,
            referenceAudioUrl: _controller.word.audioUrl,
            attemptAudioPath: _controller.attemptAudioPath,
            onRetry: _controller.retry,
            onNextWord: _controller.nextWord,
          ),
      ],
    );
  }

  String _elapsedLabel(AppLocalizations l) {
    final seconds = _controller.elapsedSeconds.floor();
    final m = (seconds ~/ 60).toString();
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

class _IssueBanner extends StatelessWidget {
  final String message;

  const _IssueBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: colorScheme.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FocusHint extends StatelessWidget {
  final List<String> phones;

  const _FocusHint({required this.phones});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      children: [
        Text(
          l.focusOnRetry,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          children: [
            for (final phone in phones)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  phone,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
