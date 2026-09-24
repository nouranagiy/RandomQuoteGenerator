import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_recognition_error.dart';

enum SpeechRecognitionIssue {
  permissionDenied,
  noSpeechDetected,
  recognitionUnavailable,
  networkError,
  recognitionFailed,
  initializationTimedOut,
  recordingTooShort,
  recordingFailed,
}

SpeechRecognitionIssue issueForError(SpeechRecognitionError error) {
  final message = error.errorMsg.toLowerCase();
  if (message.contains('permission') ||
      message.contains('denied') ||
      message.contains('mic')) {
    return SpeechRecognitionIssue.permissionDenied;
  }
  if (message.contains('no_match') || message.contains('speech_timeout')) {
    return SpeechRecognitionIssue.noSpeechDetected;
  }
  if (message.contains('network')) {
    return SpeechRecognitionIssue.networkError;
  }
  if (message.contains('language') ||
      message.contains('recognizer') ||
      message.contains('not_available') ||
      message.contains('not supported')) {
    return SpeechRecognitionIssue.recognitionUnavailable;
  }
  return SpeechRecognitionIssue.recognitionFailed;
}

bool isRecognizerUnavailableCode(PlatformException e) {
  final code = e.code.toLowerCase();
  final message = e.message?.toLowerCase() ?? '';
  return code.contains('recognizer') || message.contains('not available');
}
