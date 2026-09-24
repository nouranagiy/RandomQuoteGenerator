import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;

import '../utils/debug_log.dart';
import 'tts_service.dart';

class ReferenceAudioCache {
  ReferenceAudioCache._();

  static Directory? _dir;

  static Future<String?> _resolveDir() async {
    if (_dir != null) return _dir!.path;
    final root = Directory.systemTemp;
    final dir = Directory(
      '${root.path}${Platform.pathSeparator}lingo_ref_cache',
    );
    try {
      if (!dir.existsSync()) dir.createSync(recursive: true);
    } catch (_) {
      return null;
    }
    _dir = dir;
    return dir.path;
  }

  static String _cacheKey(String url) =>
      'lingo_ref_${(url.hashCode & 0x7fffffff).toRadixString(16)}'
      '${_guessExtension(url)}';

  static String _guessExtension(String url) {
    final path = Uri.tryParse(url)?.path ?? '';
    final dot = path.lastIndexOf('.');
    if (dot >= 0) {
      final ext = path.substring(dot);
      if (RegExp(r'^\.[A-Za-z0-9]{1,5}$').hasMatch(ext)) return ext;
    }
    return '.bin';
  }

  static Future<String?> cachedPath(String url) async {
    final dir = await _resolveDir();
    if (dir == null) return null;
    final file = File('$dir${Platform.pathSeparator}${_cacheKey(url)}');
    if (file.existsSync() && file.lengthSync() > 0) return file.path;
    return null;
  }

  static Future<String?> download(String url) async {
    final dir = await _resolveDir();
    if (dir == null) return null;
    final target = File('$dir${Platform.pathSeparator}${_cacheKey(url)}');
    final response = await http
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 12));
    if (response.statusCode != 200 || response.bodyBytes.isEmpty) return null;
    await target.writeAsBytes(response.bodyBytes, flush: true);
    return target.path;
  }
}

class WordAudioService {
  static final WordAudioService _instance = WordAudioService._();
  factory WordAudioService() => _instance;

  WordAudioService._();

  final TextToSpeechService _tts = TextToSpeechService();
  final AudioPlayer _player = AudioPlayer();

  static const Duration _audioAttemptTimeout = Duration(seconds: 10);

  Future<bool> play(
    String word, {
    String? audioUrl,
    String? languageCode,
  }) async {
    await stop();

    final url = audioUrl?.trim();
    if (url != null && url.isNotEmpty) {
      try {
        debugLog('WordAudio', 'playing audio URL: $url');

        await _player.play(UrlSource(url)).timeout(_audioAttemptTimeout);
        debugLog('WordAudio', 'audio started: $url');
        return true;
      } on TimeoutException {
        debugLog(
          'WordAudio',
          'audio load timed out (falling back to TTS): $url',
        );
        await _stopPlayerIgnoringErrors();
      } catch (e) {
        debugLog(
          'WordAudio',
          'audio playback failed (falling back to TTS): $e',
        );
        await _stopPlayerIgnoringErrors();
      }
    }

    try {
      final ok = await _tts.speak(word, languageCode: languageCode);
      debugLog(
        'WordAudio',
        'TTS "${word.length > 24 ? '${word.substring(0, 24)}…' : word}" -> $ok',
      );
      return ok;
    } catch (e) {
      debugLog('WordAudio', 'TTS failed: $e');
      return false;
    }
  }

  Future<bool> playReference(
    String word, {
    String? audioUrl,
    String? languageCode,
  }) async {
    await stop();

    final url = audioUrl?.trim();
    if (url != null && url.isNotEmpty) {
      try {
        final cached = await ReferenceAudioCache.cachedPath(url);
        if (cached != null) {
          debugLog('WordAudio', 'reference cache hit: $url');
          return _playDeviceFile(cached);
        }
        final downloaded = await ReferenceAudioCache.download(url);
        if (downloaded != null) {
          debugLog('WordAudio', 'reference downloaded & cached: $url');
          return _playDeviceFile(downloaded);
        }
      } catch (e) {
        debugLog('WordAudio', 'reference download failed ($url): $e');
        await _stopPlayerIgnoringErrors();
      }
    }

    return play(word, languageCode: languageCode);
  }

  Future<bool> playAttempt(String filePath) async {
    await stop();
    return _playDeviceFile(filePath);
  }

  Future<bool> _playDeviceFile(String filePath) async {
    try {
      debugLog('WordAudio', 'playing device file: $filePath');
      await _player
          .play(DeviceFileSource(filePath))
          .timeout(_audioAttemptTimeout);
      debugLog('WordAudio', 'device file audio started: $filePath');
      return true;
    } on TimeoutException {
      debugLog('WordAudio', 'device file audio load timed out: $filePath');
      await _stopPlayerIgnoringErrors();
      return false;
    } catch (e) {
      debugLog('WordAudio', 'device file audio playback failed: $e');
      await _stopPlayerIgnoringErrors();
      return false;
    }
  }

  Future<void> stop() async {
    await _stopPlayerIgnoringErrors();
    try {
      await _tts.stop();
    } catch (_) {}
  }

  Future<void> _stopPlayerIgnoringErrors() async {
    try {
      await _player.stop();
    } catch (_) {}
  }
}
