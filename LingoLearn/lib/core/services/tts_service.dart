import 'package:flutter_tts/flutter_tts.dart';

import '../utils/debug_log.dart';
import '../utils/text_script.dart';

class TextToSpeechService {
  static final TextToSpeechService _instance = TextToSpeechService._();
  factory TextToSpeechService() => _instance;

  TextToSpeechService._() {
    _initTts();
  }

  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;
  bool _isInitialized = false;
  List<String> _availableLanguages = [];

  bool get isSpeaking => _isSpeaking;

  Future<void> _initTts() async {
    try {
      await _tts.setVolume(1.0);
      await _tts.setSpeechRate(0.45);
      await _tts.setPitch(1.0);
      final langs = await _tts.getLanguages;
      if (langs != null) {
        _availableLanguages = List<String>.from(
          langs,
        ).map((l) => l.toLowerCase()).toList();
      }
      _tts.setCompletionHandler(() => _isSpeaking = false);
      _tts.setErrorHandler((_) => _isSpeaking = false);
      _tts.setCancelHandler(() => _isSpeaking = false);
      _isInitialized = true;
    } catch (_) {
      _isInitialized = false;
    }
  }

  bool _isLanguageAvailable(String langPrefix) {
    return _availableLanguages.any(
      (l) => l.startsWith(langPrefix.toLowerCase()),
    );
  }

  String? _getLanguageCode(String langPrefix) {
    final prefix = langPrefix.toLowerCase().replaceAll('_', '-');
    try {
      return _availableLanguages
          .map((l) => l.replaceAll('_', '-'))
          .firstWhere((l) => l.startsWith(prefix));
    } catch (_) {
      return null;
    }
  }

  Future<bool> speak(String text, {String? languageCode}) async {
    if (!_isInitialized) {
      await _initTts();
      if (!_isInitialized) return false;
    }

    if (_isSpeaking) {
      await stop();
    }

    final requested = languageCode?.trim().toLowerCase();
    if (requested != null && requested.isNotEmpty) {
      final exact = _getLanguageCode(requested);
      if (exact != null) return _speak(text, exact);
      final family = _getLanguageCode(requested.split('-').first);
      if (family != null) {
        debugLog(
          'TextToSpeech',
          'exact voice "$languageCode" unavailable; using "$family"',
        );
        return _speak(text, family);
      }
      debugLog('TextToSpeech', 'language "$languageCode" not available');
      return false;
    }

    final langPrefix = TextScriptDetector.languagePrefix(text);
    if (!_isLanguageAvailable(langPrefix)) {
      return false;
    }

    final langCode = _getLanguageCode(langPrefix);
    if (langCode == null) return false;
    return _speak(text, langCode);
  }

  Future<bool> _speak(String text, String langCode) async {
    try {
      await _tts.setLanguage(langCode);
      _isSpeaking = true;
      await _tts.speak(text);
      return true;
    } catch (_) {
      _isSpeaking = false;
      return false;
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
      _isSpeaking = false;
    } catch (_) {
      _isSpeaking = false;
    }
  }

  Future<void> dispose() async {
    await stop();
  }
}
