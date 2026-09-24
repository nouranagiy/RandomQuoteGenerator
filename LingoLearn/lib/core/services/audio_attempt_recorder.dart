import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:record/record.dart';

enum AttemptAudioFormat { compressed, pcmWav16kMono }

RecordConfig _recordConfigFor(AttemptAudioFormat format) {
  switch (format) {
    case AttemptAudioFormat.compressed:
      return const RecordConfig();
    case AttemptAudioFormat.pcmWav16kMono:
      return const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
      );
  }
}

abstract interface class AttemptAudioRecorder {
  bool get isRecording;

  Future<bool> isPluginAvailable();

  Future<bool> hasPermission();

  Future<bool> start({
    required String path,
    AttemptAudioFormat format = AttemptAudioFormat.compressed,
  });

  Future<String?> stop();

  Future<void> cancel();
}

class AudioAttemptRecorder implements AttemptAudioRecorder {
  static const MethodChannel _recordChannel = MethodChannel(
    'com.llfbandit.record/messages',
  );
  static const Duration _channelTimeout = Duration(seconds: 5);

  static const String _probeRecorderId = 'lingolearn_probe';

  static bool? _pluginAvailable;

  AudioRecorder? _recorder;
  bool _isRecording = false;

  @override
  bool get isRecording => _isRecording;

  static Future<bool> _probePlugin() async {
    try {
      await _recordChannel
          .invokeMethod<void>('create', {'recorderId': _probeRecorderId})
          .timeout(_channelTimeout);
      final result = await _recordChannel
          .invokeMethod<bool>('hasPermission', {
            'recorderId': _probeRecorderId,
            'request': false,
          })
          .timeout(_channelTimeout);
      return result is bool;
    } on TimeoutException {
      return false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> pluginAvailable() async {
    if (_pluginAvailable != null) return _pluginAvailable!;
    _pluginAvailable = await _probePlugin();
    return _pluginAvailable!;
  }

  @visibleForTesting
  static void resetPluginProbe() {
    _pluginAvailable = null;
  }

  @override
  Future<bool> isPluginAvailable() => pluginAvailable();

  Future<bool> _ensureRecorder() async {
    if (_recorder != null) return true;
    if (!await pluginAvailable()) return false;
    _recorder = AudioRecorder();
    return true;
  }

  @override
  Future<bool> hasPermission() async {
    if (!await _ensureRecorder()) return false;
    try {
      final permitted = await _recorder!.hasPermission().timeout(
        _channelTimeout,
      );
      return permitted;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> start({
    required String path,
    AttemptAudioFormat format = AttemptAudioFormat.compressed,
  }) async {
    if (_isRecording) return true;
    if (!await _ensureRecorder()) return false;
    try {
      final permitted = await _recorder!.hasPermission().timeout(
        _channelTimeout,
      );
      if (permitted != true) return false;
      await _recorder!
          .start(_recordConfigFor(format), path: path)
          .timeout(_channelTimeout);
      _isRecording = true;
      return true;
    } catch (_) {
      _isRecording = false;
      return false;
    }
  }

  @override
  Future<String?> stop() async {
    if (!_isRecording) return null;
    _isRecording = false;
    try {
      final path = await _recorder!.stop();
      if (path == null || path.trim().isEmpty) return null;
      return path;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> cancel() async {
    if (!_isRecording) return;
    _isRecording = false;
    try {
      await _recorder!.cancel();
    } catch (_) {}
  }
}
