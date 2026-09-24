import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingolearn/core/services/audio_attempt_recorder.dart';

const MethodChannel _recordChannel = MethodChannel(
  'com.llfbandit.record/messages',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_recordChannel, null);
    AudioAttemptRecorder.resetPluginProbe();
  });

  test('detects a reachable record plugin', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          _recordChannel,
          (call) async => call.method == 'hasPermission' ? true : null,
        );

    expect(await AudioAttemptRecorder.pluginAvailable(), isTrue);
  });

  test('degrades gracefully when the record plugin is missing', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          _recordChannel,
          (call) async => throw MissingPluginException('no record plugin'),
        );

    expect(await AudioAttemptRecorder.pluginAvailable(), isFalse);
  });

  test(
    'start returns false without constructing the recorder when unsupported',
    () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            _recordChannel,
            (call) async => throw MissingPluginException('no record plugin'),
          );

      final recorder = AudioAttemptRecorder();
      final started = await recorder.start(path: r'C:\tmp\attempt.m4a');

      expect(
        started,
        isFalse,
        reason: 'no plugin must never throw, just degrade',
      );
      expect(recorder.isRecording, isFalse);
      expect(await recorder.stop(), isNull);
    },
  );
}
