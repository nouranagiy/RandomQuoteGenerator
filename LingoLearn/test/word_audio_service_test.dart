import 'package:flutter_test/flutter_test.dart';
import 'package:lingolearn/core/services/word_audio_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'play without an audio URL completes (TTS path) and never throws',
    () async {
      final result = await WordAudioService()
          .play('hello')
          .timeout(const Duration(seconds: 15));
      expect(result, isA<bool>());
    },
  );

  test(
    'play with an audio URL completes (network path) and never throws',
    () async {
      final result = await WordAudioService()
          .play('hello', audioUrl: 'https://example.com/hello.mp3')
          .timeout(const Duration(seconds: 15));
      expect(result, isA<bool>());
    },
  );

  test('stop never throws and completes promptly', () async {
    await WordAudioService().stop().timeout(const Duration(seconds: 5));
  });

  test('repeat play calls do not accumulate stuck state', () async {
    final service = WordAudioService();
    for (var i = 0; i < 3; i++) {
      final result = await service
          .play('word $i', audioUrl: 'https://example.com/$i.mp3')
          .timeout(const Duration(seconds: 15));
      expect(result, isA<bool>(), reason: 'attempt $i must terminate');
    }
  });
}
