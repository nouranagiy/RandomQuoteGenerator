import 'package:flutter_test/flutter_test.dart';
import 'package:lingolearn/core/services/audio_attempt_recorder.dart';
import 'package:lingolearn/features/pronunciation/data/pronunciation_issues.dart';
import 'package:lingolearn/features/pronunciation/presentation/pronunciation_controller.dart';
import 'package:lingolearn/features/vocabulary/data/language_word.dart';

class _NoMicRecorder implements AttemptAudioRecorder {
  bool _isRecording = false;

  @override
  bool get isRecording => _isRecording;

  @override
  Future<bool> isPluginAvailable() async => true;

  @override
  Future<bool> hasPermission() async => false;

  @override
  Future<bool> start({
    required String path,
    AttemptAudioFormat format = AttemptAudioFormat.compressed,
  }) async => _isRecording = true;

  @override
  Future<String?> stop() async {
    _isRecording = false;
    return null;
  }

  @override
  Future<void> cancel() async {
    _isRecording = false;
  }
}

class _NoMicPluginRecorder implements AttemptAudioRecorder {
  @override
  bool get isRecording => false;

  @override
  Future<bool> isPluginAvailable() async => false;

  @override
  Future<bool> hasPermission() async => false;

  @override
  Future<bool> start({
    required String path,
    AttemptAudioFormat format = AttemptAudioFormat.compressed,
  }) async => false;

  @override
  Future<String?> stop() async => null;

  @override
  Future<void> cancel() async {}
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'denied mic permission maps to permissionDenied, never stuck checking',
    (tester) async {
      final controller = PronunciationController(
        initialWord: _word(),
        recorder: _NoMicRecorder(),
      );
      await tester.runAsync(() => controller.initialize());

      expect(
        controller.phase,
        PronunciationPhase.idle,
        reason: 'init must terminate even when permission is denied',
      );
      expect(controller.issue, PronunciationIssue.permissionDenied);
      controller.dispose();
    },
  );

  testWidgets('missing mic plugin maps to micUnavailable', (tester) async {
    final controller = PronunciationController(
      initialWord: _word(),
      recorder: _NoMicPluginRecorder(),
    );
    await tester.runAsync(() => controller.initialize());

    expect(controller.phase, PronunciationPhase.idle);
    expect(controller.issue, PronunciationIssue.micUnavailable);
    controller.dispose();
  });

  testWidgets('recording without permission is rejected, not hung', (
    tester,
  ) async {
    final controller = PronunciationController(
      initialWord: _word(),
      recorder: _NoMicRecorder(),
    );
    await tester.runAsync(() async {
      await controller.startRecording();
    });

    expect(controller.isRecording, isFalse);
    expect(controller.phase, isNot(PronunciationPhase.recording));
    expect(controller.issue, PronunciationIssue.permissionDenied);
    controller.dispose();
  });
}
