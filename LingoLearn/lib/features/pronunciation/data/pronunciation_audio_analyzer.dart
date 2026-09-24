import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../../core/utils/debug_log.dart';

enum AudioQuality {
  acceptable,
  tooQuiet,
  clipped;

  String get label => switch (this) {
    AudioQuality.acceptable => 'acceptable',
    AudioQuality.tooQuiet => 'too_quiet',
    AudioQuality.clipped => 'clipped',
  };
}

@immutable
class PronunciationAudioAnalysis {
  final bool validWav;
  final int sampleRate;
  final int channels;
  final int bitsPerSample;
  final double durationSeconds;
  final double rmsDb;

  final double peakDb;

  /// Number of samples whose magnitude reaches [kClipSampleThreshold].
  final int clippedSampleCount;

  /// [clippedSampleCount] as a percentage of all samples (0-100).
  final double clippedPercentage;

  /// Longest consecutive run of samples at/near full scale.
  final int longestClippedRun;

  /// Overall classification for the captured audio.
  final AudioQuality quality;

  /// True only when the waveform is genuinely (sustained/significant) clipped,
  /// never for an isolated peak that merely touches 0 dBFS.
  final bool clipped;

  const PronunciationAudioAnalysis({
    required this.validWav,
    this.sampleRate = 0,
    this.channels = 0,
    this.bitsPerSample = 0,
    this.durationSeconds = 0,
    this.rmsDb = double.negativeInfinity,
    this.peakDb = double.negativeInfinity,
    this.clippedSampleCount = 0,
    this.clippedPercentage = 0,
    this.longestClippedRun = 0,
    this.quality = AudioQuality.acceptable,
    this.clipped = false,
  });

  bool get hasSpeech {
    if (!validWav) return false;
    return peakDb > kSilencePeakDb && rmsDb > kSilenceRmsDb;
  }
}

const double kSilencePeakDb = -45;

const double kSilenceRmsDb = -52;

// A 16-bit PCM sample counts as "at/near full scale" once its magnitude is at
// least 32760 out of 32768 (within ~7 LSB of the rails, ~ -0.004 dBFS).
// Touching 0 dBFS with one or a few samples is NOT distortion; only sustained
// or significant clipping indicates a genuinely flattened waveform.
const int kClipSampleThreshold = 32760;

// Distortion decision thresholds for the WAV produced by this app
// (16-bit PCM, mono, 16 kHz).
//  - kSustainedClippedRunSamples: a flattened run of >= 160 samples is 10 ms
//    of continuous clipping at 16 kHz - clearly audible gross distortion.
//  - kHeavyClippedPercent: >= 2% of every sample pinned to the rails means a
//    substantial portion of the waveform is flattened, whatever the run shape.
//  - kSustainedClippedPercent: once a sustained run exists, >= 0.5% of all
//    samples at full scale confirms it is more than a transient spike.
//  - kSevereClippedMinCount: an absolute floor so a tiny handful of overs can
//    never trip the detector.
const int kSustainedClippedRunSamples = 160;

const double kSustainedClippedPercent = 0.5;

const double kHeavyClippedPercent = 2.0;

const int kSevereClippedMinCount = 64;

AudioQuality classifyAudioQuality({
  required bool hasSpeech,
  required int clippedSampleCount,
  required double clippedPercentage,
  required int longestClippedRun,
}) {
  if (!hasSpeech) return AudioQuality.tooQuiet;
  final significant =
      clippedSampleCount >= kSevereClippedMinCount &&
      (clippedPercentage >= kHeavyClippedPercent ||
          (longestClippedRun >= kSustainedClippedRunSamples &&
              clippedPercentage >= kSustainedClippedPercent));
  return significant ? AudioQuality.clipped : AudioQuality.acceptable;
}

class PronunciationAudioAnalyzer {
  const PronunciationAudioAnalyzer();

  Future<PronunciationAudioAnalysis?> analyzeWav(String path) async {
    try {
      final bytes = await File(path).readAsBytes();
      return analyzeBytes(bytes);
    } catch (e) {
      debugLog('PronunciationAudio', 'failed to read WAV: $e');
      return null;
    }
  }

  PronunciationAudioAnalysis analyzeBytes(Uint8List bytes) {
    if (!_isWav(bytes)) {
      return const PronunciationAudioAnalysis(validWav: false);
    }

    final fmt = _findChunk(bytes, 'fmt ');
    if (fmt == null) {
      return const PronunciationAudioAnalysis(validWav: false);
    }
    final data = _findChunk(bytes, 'data');
    if (data == null) {
      return const PronunciationAudioAnalysis(validWav: false);
    }

    final view = ByteData.view(bytes.buffer, fmt.offset, fmt.length);
    final audioFormat = view.getUint16(0, Endian.little);
    final channels = view.getUint16(2, Endian.little);
    final sampleRate = view.getUint32(4, Endian.little);
    final bitsPerSample = view.getUint16(14, Endian.little);

    if (audioFormat != 1 || channels != 1 || bitsPerSample != 16) {
      return PronunciationAudioAnalysis(
        validWav: false,
        sampleRate: sampleRate,
        channels: channels,
        bitsPerSample: bitsPerSample,
      );
    }

    final duration =
        data.length / (sampleRate * channels * (bitsPerSample / 8));
    final levels = _levels(bytes, data.offset, data.length);
    final quality = classifyAudioQuality(
      hasSpeech: levels.peakDb > kSilencePeakDb && levels.rmsDb > kSilenceRmsDb,
      clippedSampleCount: levels.clippedSampleCount,
      clippedPercentage: levels.clippedPercentage,
      longestClippedRun: levels.longestClippedRun,
    );

    return PronunciationAudioAnalysis(
      validWav: true,
      sampleRate: sampleRate,
      channels: channels,
      bitsPerSample: bitsPerSample,
      durationSeconds: duration,
      rmsDb: levels.rmsDb,
      peakDb: levels.peakDb,
      clippedSampleCount: levels.clippedSampleCount,
      clippedPercentage: levels.clippedPercentage,
      longestClippedRun: levels.longestClippedRun,
      quality: quality,
      clipped: quality == AudioQuality.clipped,
    );
  }

  bool _isWav(Uint8List bytes) {
    if (bytes.length < 12) return false;
    return (bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x41 &&
        bytes[10] == 0x56 &&
        bytes[11] == 0x45);
  }

  ({int offset, int length})? _findChunk(Uint8List bytes, String id) {
    var cursor = 12;
    while (cursor + 8 <= bytes.length) {
      final chunkId = String.fromCharCodes(bytes, cursor, cursor + 4);
      final view = ByteData.view(bytes.buffer, cursor + 4, 4);
      final length = view.getUint32(0, Endian.little);
      if (chunkId == id) return (offset: cursor + 8, length: length);
      final advance = 8 + length + (length.isOdd ? 1 : 0);
      if (advance <= 0) break;
      cursor += advance;
    }
    return null;
  }

  ({
    double rmsDb,
    double peakDb,
    int clippedSampleCount,
    double clippedPercentage,
    int longestClippedRun,
  })
  _levels(Uint8List bytes, int offset, int length) {
    final sampleCount = length ~/ 2;
    var sumSquares = 0.0;
    var peak = 0;
    var clippedCount = 0;
    var longestRun = 0;
    var currentRun = 0;
    final view = ByteData.sublistView(bytes, offset, offset + length);
    for (var i = 0; i < sampleCount; i++) {
      final sample = view.getInt16(i * 2, Endian.little).abs();
      if (sample > peak) peak = sample;
      final scaled = sample / 32768.0;
      sumSquares += scaled * scaled;
      if (sample >= kClipSampleThreshold) {
        clippedCount++;
        currentRun++;
        if (currentRun > longestRun) longestRun = currentRun;
      } else {
        currentRun = 0;
      }
    }
    final rms = sampleCount == 0 ? 0.0 : math.sqrt(sumSquares / sampleCount);
    final rmsDb = 20 * math.log(rms.clamp(1e-9, 1.0)) / math.ln10;
    final peakDb = 20 * math.log((peak / 32768.0).clamp(1e-9, 1.0)) / math.ln10;
    final clippedPercentage = sampleCount == 0
        ? 0.0
        : (clippedCount / sampleCount) * 100.0;
    return (
      rmsDb: rmsDb,
      peakDb: peakDb,
      clippedSampleCount: clippedCount,
      clippedPercentage: clippedPercentage,
      longestClippedRun: longestRun,
    );
  }
}
