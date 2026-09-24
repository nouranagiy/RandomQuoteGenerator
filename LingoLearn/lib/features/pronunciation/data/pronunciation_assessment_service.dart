import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../core/utils/debug_log.dart';
import 'pronunciation_assessment_result_model.dart';
import 'pronunciation_config.dart';
import 'pronunciation_issues.dart';
import 'pronunciation_token_provider.dart';

abstract interface class PronunciationScoringGateway {
  Future<PronunciationAssessmentResultModel> assess({
    required String target,
    required String audioPath,
    required AzureAccess access,
    required int attempt,
    String? referenceAudioUrl,
  });
}

class PronunciationAssessmentService implements PronunciationScoringGateway {
  PronunciationAssessmentService({http.Client? client})
    : _client = client ?? http.Client();

  static const String _contentType =
      'audio/wav; codecs=audio/pcm; samplerate=16000';

  final http.Client _client;

  @override
  Future<PronunciationAssessmentResultModel> assess({
    required String target,
    required String audioPath,
    required AzureAccess access,
    required int attempt,
    String? referenceAudioUrl,
  }) async {
    final bytes = await _readAudio(audioPath);
    final uri = _buildUri(access.endpoint);

    debugLog('PronunciationAssessment', 'starting');
    debugLog('PronunciationAssessment', 'target: "$target"');
    debugLog(
      'PronunciationAssessment',
      'locale: ${PronunciationConfig.languageCode}',
    );
    debugLog(
      'PronunciationAssessment',
      'audio duration: ${(bytes.length / 32000).toStringAsFixed(2)}s',
    );

    final params = base64Encode(
      utf8.encode(
        jsonEncode({
          'ReferenceText': target,
          'GradingSystem': 'HundredMark',
          'Granularity': 'Phoneme',
          'Dimension': 'Comprehensive',
          'EnableMiscue': 'True',
          'EnableProsodyAssessment': 'True',
        }),
      ),
    );

    late http.Response response;
    try {
      debugLog('PronunciationAssessment', 'request sent');
      response = await _client
          .post(
            uri,
            headers: {
              'Authorization': 'Bearer ${access.token}',
              'Content-Type': _contentType,
              'Accept': 'application/json',
              'Pronunciation-Assessment': params,
            },
            body: bytes,
          )
          .timeout(PronunciationConfig.requestTimeout);
    } on TimeoutException {
      debugLog('PronunciationAssessment', 'status: failed (request timeout)');
      throw const PronunciationTimeoutException();
    } on SocketException {
      debugLog('PronunciationAssessment', 'status: failed (network)');
      throw const PronunciationNetworkException();
    } on http.ClientException {
      debugLog('PronunciationAssessment', 'status: failed (network)');
      throw const PronunciationNetworkException();
    }

    debugLog('PronunciationAssessment', 'HTTP ${response.statusCode}');
    if (response.statusCode == 401 || response.statusCode == 403) {
      debugLog(
        'PronunciationAssessment',
        'status: failed (token rejected, HTTP ${response.statusCode})',
      );
      throw PronunciationHttpException(
        response.statusCode,
        'token rejected by the Speech service',
      );
    }
    if (response.statusCode != 200) {
      debugLog(
        'PronunciationAssessment',
        'status: failed (HTTP ${response.statusCode})',
      );
      throw PronunciationHttpException(response.statusCode);
    }

    final Map<String, dynamic> decoded;
    try {
      decoded = _decode(response);
    } catch (_) {
      debugLog(
        'PronunciationAssessment',
        'status: failed (malformed JSON response)',
      );
      throw const PronunciationMalformedResponseException();
    }

    debugLog('PronunciationAssessment', 'response received');

    final status = (decoded['RecognitionStatus'] as String?) ?? 'Error';
    if (status == 'InitialSilenceTimeout' ||
        status == 'BabbleTimeout' ||
        status == 'Error') {
      debugLog('PronunciationAssessment', 'status: failed ($status)');
      throw PronunciationRecognitionStatusException(status);
    }

    final result = PronunciationAssessmentResultModel.fromAzureJson(
      json: decoded,
      target: target,
      attempt: attempt,
      userAudioPath: audioPath,
      referenceAudioUrl: referenceAudioUrl,
    );
    debugLog('PronunciationAssessment', 'status: success');
    debugLog(
      'PronunciationAssessment',
      'overall: ${result.overallScore} accuracy: ${result.accuracyScore} '
          'fluency: ${result.fluencyScore} completeness: '
          '${result.completenessScore} prosody: ${result.prosodyScore}',
    );
    debugLog(
      'PronunciationAssessment',
      'phonemes: ${result.phonemeResults.map((p) => '${p.phone}@${p.accuracy}').join(', ')}',
    );
    return result;
  }

  Future<List<int>> _readAudio(String audioPath) async {
    final file = File(audioPath);
    if (!await file.exists()) {
      throw const PronunciationMalformedResponseException('audio file missing');
    }
    return file.readAsBytes();
  }

  Map<String, dynamic> _decode(http.Response response) {
    final object = jsonDecode(utf8.decode(response.bodyBytes));
    return (object as Map).cast<String, dynamic>();
  }

  Uri _buildUri(String endpoint) {
    final base = endpoint.trim();
    if (base.isEmpty) {
      throw const PronunciationUnconfiguredException();
    }
    final separator = base.contains('?') ? '&' : '?';
    return Uri.parse(
      '$base${separator}language=${Uri.encodeQueryComponent(PronunciationConfig.languageCode)}&format=detailed',
    );
  }
}
