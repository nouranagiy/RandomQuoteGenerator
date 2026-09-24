enum PronunciationIssue {
  permissionDenied,

  micUnavailable,

  recordingFailed,

  recordingTooShort,

  audioTooQuiet,

  recordingClipped,

  noSpeechDetected,

  unclearAudio,

  invalidAudioFormat,

  assessmentUnavailable,

  tokenFailed,

  networkError,

  assessmentTimedOut,

  assessmentFailed,

  malformedResponse,
}

sealed class PronunciationServiceException implements Exception {
  final String? detail;

  const PronunciationServiceException([this.detail]);

  @override
  String toString() => '$runtimeType${detail == null ? '' : ': $detail'}';
}

class PronunciationUnconfiguredException extends PronunciationServiceException {
  const PronunciationUnconfiguredException();
}

class PronunciationTokenException extends PronunciationServiceException {
  const PronunciationTokenException([super.detail]);
}

class PronunciationNetworkException extends PronunciationServiceException {
  const PronunciationNetworkException([super.detail]);
}

class PronunciationTimeoutException extends PronunciationServiceException {
  const PronunciationTimeoutException([super.detail]);
}

class PronunciationHttpException extends PronunciationServiceException {
  final int statusCode;

  const PronunciationHttpException(this.statusCode, [super.detail]);
}

class PronunciationMalformedResponseException
    extends PronunciationServiceException {
  const PronunciationMalformedResponseException([super.detail]);
}

class PronunciationRecognitionStatusException
    extends PronunciationServiceException {
  final String status;

  const PronunciationRecognitionStatusException(this.status, [super.detail]);
}
