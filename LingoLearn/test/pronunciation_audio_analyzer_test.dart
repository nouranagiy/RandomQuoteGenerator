import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lingolearn/features/pronunciation/data/pronunciation_audio_analyzer.dart';

Uint8List _wav({
  int channels = 1,
  int sampleRate = 16000,
  int bitsPerSample = 16,
  List<int> samples = const [0],
}) {
  final byteRate = sampleRate * channels * (bitsPerSample ~/ 8);
  final blockAlign = channels * (bitsPerSample ~/ 8);
  final dataSize = samples.length * (bitsPerSample ~/ 8) * channels;
  final buffer = BytesBuilder();

  void writeString(String value) => buffer.add(value.codeUnits);
  void writeU32(int value) {
    final data = ByteData(4)..setUint32(0, value, Endian.little);
    buffer.add(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  void writeU16(int value) {
    final data = ByteData(2)..setUint16(0, value, Endian.little);
    buffer.add(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  writeString('RIFF');
  writeU32(36 + dataSize);
  writeString('WAVE');
  writeString('fmt ');
  writeU32(16);
  writeU16(1);
  writeU16(channels);
  writeU32(sampleRate);
  writeU32(byteRate);
  writeU16(blockAlign);
  writeU16(bitsPerSample);
  writeString('data');
  writeU32(dataSize);
  for (final sample in samples) {
    writeU16(sample < 0 ? (-sample) & 0xffff : sample & 0xffff);
  }
  return buffer.toBytes();
}

void main() {
  const analyzer = PronunciationAudioAnalyzer();

  test('a valid loud 16 kHz mono WAV is recognized as speech', () {
    final bytes = _wav(samples: List.filled(16000, 8000));
    final result = analyzer.analyzeBytes(bytes);

    expect(result.validWav, isTrue);
    expect(result.sampleRate, 16000);
    expect(result.channels, 1);
    expect(result.bitsPerSample, 16);
    expect(result.durationSeconds, closeTo(1.0, 0.01));
    expect(result.peakDb, greaterThan(-20));
    expect(result.hasSpeech, isTrue);
  });

  test('a silent WAV is detected as quiet while still valid', () {
    final bytes = _wav(samples: List.filled(16000, 0));
    final result = analyzer.analyzeBytes(bytes);

    expect(result.validWav, isTrue);
    expect(result.hasSpeech, isFalse);
  });

  test('an entire recording pinned at full scale is flagged as clipped', () {
    final bytes = _wav(samples: List.filled(16000, 32767));
    final result = analyzer.analyzeBytes(bytes);

    expect(result.validWav, isTrue);
    expect(result.clipped, isTrue);
    expect(result.quality, AudioQuality.clipped);
    expect(result.clippedSampleCount, 16000);
    expect(result.clippedPercentage, closeTo(100, 0.01));
    expect(result.longestClippedRun, 16000);
    expect(result.hasSpeech, isTrue);
  });

  test('a loud-but-unclipped recording is not flagged as clipped', () {
    final bytes = _wav(samples: List.filled(16000, 12000));
    final result = analyzer.analyzeBytes(bytes);

    expect(result.validWav, isTrue);
    expect(result.clipped, isFalse);
    expect(result.quality, AudioQuality.acceptable);
    expect(result.clippedSampleCount, 0);
  });

  test('a few isolated full-scale samples are NOT flagged as clipped', () {
    final samples = List<int>.filled(16000, 8000);
    for (final at in [100, 5000, 9000]) {
      samples[at] = 32767;
    }
    final result = analyzer.analyzeBytes(_wav(samples: samples));

    expect(result.validWav, isTrue);
    expect(result.hasSpeech, isTrue);
    expect(
      result.peakDb,
      greaterThan(-1),
      reason: 'the peak genuinely touched 0 dBFS',
    );
    expect(result.clippedSampleCount, 3);
    expect(result.longestClippedRun, 1);
    expect(
      result.clipped,
      isFalse,
      reason: 'isolated full-scale samples are no proof of distortion',
    );
    expect(result.quality, AudioQuality.acceptable);
  });

  test('a sustained 10 ms flattened run is flagged as clipped', () {
    final samples = List<int>.filled(16000, 8000);
    for (var i = 0; i < 160; i++) {
      samples[8000 + i] = 32767;
    }
    final result = analyzer.analyzeBytes(_wav(samples: samples));

    expect(result.clippedSampleCount, 160);
    expect(result.clippedPercentage, closeTo(1.0, 0.01));
    expect(result.longestClippedRun, 160);
    expect(result.clipped, isTrue);
    expect(result.quality, AudioQuality.clipped);
  });

  test('a flattened run shorter than the sustained threshold is accepted', () {
    final samples = List<int>.filled(16000, 8000);
    for (var i = 0; i < 100; i++) {
      samples[8000 + i] = 32767;
    }
    final result = analyzer.analyzeBytes(_wav(samples: samples));

    expect(result.longestClippedRun, 100);
    expect(
      result.clipped,
      isFalse,
      reason:
          'a 6 ms flattening without a high share of full-scale is not '
          'sustained distortion',
    );
    expect(result.quality, AudioQuality.acceptable);
  });

  test(
    'a long flat run over a long recording is accepted when share is tiny',
    () {
      final samples = List<int>.filled(80000, 8000);
      for (var i = 0; i < 200; i++) {
        samples[40000 + i] = 32767;
      }
      final result = analyzer.analyzeBytes(_wav(samples: samples));

      expect(result.longestClippedRun, 200);
      expect(result.clippedPercentage, closeTo(0.25, 0.01));
      expect(
        result.clipped,
        isFalse,
        reason: '0.25% of samples pinned to the rails is not significant',
      );
      expect(result.quality, AudioQuality.acceptable);
    },
  );

  test('2%+ of all samples at full scale is clipped even scattered', () {
    final samples = List<int>.filled(16000, 8000);
    for (var i = 0; i < samples.length; i += 40) {
      samples[i] = 32767;
    }
    final result = analyzer.analyzeBytes(_wav(samples: samples));

    expect(result.clippedSampleCount, 400);
    expect(
      result.longestClippedRun,
      1,
      reason: 'deliberately scattered, no sustained run',
    );
    expect(result.clippedPercentage, closeTo(2.5, 0.01));
    expect(
      result.clipped,
      isTrue,
      reason: '2.5% of every sample at full scale is heavy clipping',
    );
    expect(result.quality, AudioQuality.clipped);
  });

  test('classifyAudioQuality keeps TOO_QUIET distinct from CLIPPED', () {
    expect(
      classifyAudioQuality(
        hasSpeech: false,
        clippedSampleCount: 16000,
        clippedPercentage: 100,
        longestClippedRun: 16000,
      ),
      AudioQuality.tooQuiet,
      reason: 'quiet audio must never be labelled as clipping',
    );
    expect(
      classifyAudioQuality(
        hasSpeech: true,
        clippedSampleCount: 0,
        clippedPercentage: 0,
        longestClippedRun: 0,
      ),
      AudioQuality.acceptable,
    );
  });

  test('non-WAV bytes are rejected as invalid', () {
    final bytes = Uint8List.fromList('hello world'.codeUnits);
    final result = analyzer.analyzeBytes(bytes);

    expect(result.validWav, isFalse);
  });

  test('a stereo 16 kHz file is rejected (assessment needs mono)', () {
    final bytes = _wav(channels: 2, samples: List.filled(32000, 8000));
    final result = analyzer.analyzeBytes(bytes);

    expect(result.validWav, isFalse);
    expect(result.channels, 2);
  });

  test('analyzeWav returns null when the file does not exist', () async {
    final result = await analyzer.analyzeWav(
      r'C:\definitely\does-not-exist\attempt.wav',
    );

    expect(result, isNull);
  });
}
