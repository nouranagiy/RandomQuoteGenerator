import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../utils/text_script.dart';
import 'speech_recognition_issues.dart';

class SpeechRecognitionService {
  static final SpeechRecognitionService _instance =
      SpeechRecognitionService._();
  factory SpeechRecognitionService() => _instance;

  SpeechRecognitionService._();

  static const Duration _initTimeout = Duration(seconds: 15);
  static const Duration _localesTimeout = Duration(seconds: 6);

  final SpeechToText _speech = SpeechToText();
  bool _isInitializing = false;
  bool _isAvailable = false;
  bool _isListening = false;
  String _latestText = '';
  double _latestConfidence = -1;
  List<String> _availableLocales = [];
  SpeechRecognitionError? _lastError;
  SpeechRecognitionIssue? _initIssue;
  ValueChanged<String>? _onSessionError;

  bool get isAvailable => _isAvailable;

  SpeechRecognitionError? get lastError => _lastError;

  SpeechRecognitionIssue? get initIssue => _initIssue;

  double? get lastConfidence {
    if (_latestConfidence < 0) return null;
    return _latestConfidence.clamp(0.0, 1.0);
  }

  Future<bool> initialize() async {
    if (_isAvailable) return true;
    if (_isInitializing) return _isAvailable;

    _isInitializing = true;
    _initIssue = null;
    debugPrint('[Pronunciation] initializing speech recognition...');
    try {
      unawaited(_refreshLocales());

      _isAvailable = await _speech
          .initialize(onError: _onError, onStatus: _onStatus)
          .timeout(_initTimeout);
      if (!_isAvailable) {
        _initIssue = SpeechRecognitionIssue.permissionDenied;
        debugPrint('[Pronunciation] initialize returned false (permission)');
      } else {
        debugPrint('[Pronunciation] initialize succeeded');
      }
    } on TimeoutException {
      _isAvailable = false;
      _initIssue = SpeechRecognitionIssue.initializationTimedOut;
      debugPrint('[Pronunciation] initialize timed out after $_initTimeout');
    } on PlatformException catch (e) {
      _isAvailable = false;
      _initIssue = isRecognizerUnavailableCode(e)
          ? SpeechRecognitionIssue.recognitionUnavailable
          : SpeechRecognitionIssue.recognitionFailed;
      debugPrint(
        '[Pronunciation] initialize PlatformException: '
        '${e.code} - ${e.message}',
      );
    } catch (e) {
      _isAvailable = false;
      _initIssue = SpeechRecognitionIssue.recognitionFailed;
      debugPrint('[Pronunciation] initialize error: $e');
    } finally {
      _isInitializing = false;
    }
    return _isAvailable;
  }

  Future<void> _refreshLocales() async {
    try {
      final locales = await _speech.locales().timeout(_localesTimeout);
      _availableLocales = locales
          .map((locale) => locale.localeId)
          .toList(growable: false);
      debugPrint(
        '[Pronunciation] available locales (${_availableLocales.length}): '
        '${_availableLocales.take(12).join(', ')}',
      );
    } catch (e) {
      _availableLocales = [];
      debugPrint('[Pronunciation] locale fetch failed/timed out: $e');
    }
  }

  String? resolveLocaleForText(String text) {
    final prefix = TextScriptDetector.languagePrefix(text);
    try {
      return _availableLocales.firstWhere(
        (id) => id.toLowerCase().startsWith(prefix),
      );
    } catch (_) {
      return null;
    }
  }

  Future<bool> startListening({
    required String? localeId,
    required ValueChanged<String> onPartial,
    ValueChanged<String>? onSessionError,
  }) async {
    if (_isListening) return true;

    final available = _isAvailable || await initialize();
    if (!available) return false;

    _latestText = '';
    _lastError = null;
    _latestConfidence = -1;
    _onSessionError = onSessionError;
    try {
      await _speech.listen(
        onResult: (result) {
          _latestText = result.recognizedWords;
          _latestConfidence = result.confidence;
          debugPrint(
            '[Pronunciation] partial result: "${result.recognizedWords}" '
            '(confidence: ${result.confidence.toStringAsFixed(2)})',
          );
          onPartial(result.recognizedWords);
        },
        listenOptions: SpeechListenOptions(
          localeId: localeId,
          partialResults: true,
          cancelOnError: true,
          listenFor: const Duration(seconds: 35),
          pauseFor: const Duration(seconds: 3),
        ),
      );
      _isListening = true;
      debugPrint('[Pronunciation] listening started (locale: $localeId)');
      return true;
    } catch (e) {
      _isListening = false;
      debugPrint('[Pronunciation] listen failed: $e');
      return false;
    }
  }

  Future<String> stopListening() async {
    if (!_isListening) return _latestText;
    _isListening = false;
    try {
      await _speech.stop();
    } catch (e) {
      debugPrint('[Pronunciation] stop failed: $e');
    }
    await Future<void>.delayed(const Duration(milliseconds: 350));
    debugPrint('[Pronunciation] stop: final text "$_latestText"');
    return _latestText;
  }

  Future<void> cancel() async {
    _isListening = false;
    try {
      await _speech.cancel();
    } catch (e) {
      debugPrint('[Pronunciation] cancel failed: $e');
    }
  }

  void _onStatus(String status) {
    _isListening = status == SpeechToText.listeningStatus;
    debugPrint('[Pronunciation] status: $status');
  }

  void _onError(SpeechRecognitionError error) {
    _lastError = error;
    _isListening = false;
    debugPrint(
      '[Pronunciation] session error: ${error.errorMsg} '
      '(permanent: ${error.permanent})',
    );
    _onSessionError?.call(error.errorMsg);
  }
}
