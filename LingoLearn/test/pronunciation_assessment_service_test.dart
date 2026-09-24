import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lingolearn/features/pronunciation/data/pronunciation_assessment_service.dart';
import 'package:lingolearn/features/pronunciation/data/pronunciation_issues.dart';
import 'package:lingolearn/features/pronunciation/data/pronunciation_token_provider.dart';

const _endpoint =
    'https://my-speech.cognitiveservices.azure.com/stt/speech/recognition/conversation/cognitiveservices/v1';

AzureAccess _access() {
  return AzureAccess(
    token: 'jwt',
    endpoint: _endpoint,
    expiresAt: DateTime.now().add(const Duration(hours: 1)),
  );
}

Map<String, dynamic> _successJson() {
  return {
    'RecognitionStatus': 'Success',
    'NBest': [
      {
        'Confidence': 0.9,
        'Lexical': 'able',
        'Display': 'able.',
        'AccuracyScore': 92.0,
        'FluencyScore': 90.0,
        'ProsodyScore': 85.0,
        'CompletenessScore': 100.0,
        'PronScore': 91.0,
        'Words': [
          {
            'Word': 'able',
            'AccuracyScore': 92.0,
            'ErrorType': 'None',
            'Phonemes': [
              {
                'Phoneme': 'ey',
                'PronunciationAssessment': {'AccuracyScore': 90},
              },
              {
                'Phoneme': 'b',
                'PronunciationAssessment': {'AccuracyScore': 95},
              },
              {
                'Phoneme': 'l',
                'PronunciationAssessment': {'AccuracyScore': 88},
              },
            ],
          },
        ],
      },
    ],
  };
}

void main() {
  late Directory tempDir;
  late File wavFile;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('lingo_service_test');
    wavFile = File('${tempDir.path}${Platform.pathSeparator}attempt.wav');
    await wavFile.writeAsBytes(List.filled(16000, 1));
    addTearDown(() => tempDir.delete(recursive: true));
  });

  test('posts WAV with pronunciation headers and parses the result', () async {
    http.Request? captured;
    final client = MockClient((request) async {
      captured = request;
      return http.Response(
        jsonEncode(_successJson()),
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    final service = PronunciationAssessmentService(client: client);

    final result = await service.assess(
      target: 'able',
      audioPath: wavFile.path,
      access: _access(),
      attempt: 2,
      referenceAudioUrl: 'https://example.com/able.mp3',
    );

    expect(captured, isNotNull);
    expect(captured!.method, 'POST');
    expect(
      captured!.url.toString(),
      '$_endpoint?language=${Uri.encodeQueryComponent('en-US')}&format=detailed',
    );
    expect(captured!.headers['Authorization'], 'Bearer jwt');
    expect(
      captured!.headers['Content-Type'],
      'audio/wav; codecs=audio/pcm; samplerate=16000',
    );
    expect(captured!.headers.containsKey('Pronunciation-Assessment'), isTrue);

    final params =
        jsonDecode(
              utf8.decode(
                base64Decode(captured!.headers['Pronunciation-Assessment']!),
              ),
            )
            as Map<String, dynamic>;
    expect(params['ReferenceText'], 'able');
    expect(params['GradingSystem'], 'HundredMark');
    expect(params['Granularity'], 'Phoneme');
    expect(params['Dimension'], 'Comprehensive');
    expect(params['EnableMiscue'], 'True');
    expect(params['EnableProsodyAssessment'], 'True');

    expect(captured!.bodyBytes, wavFile.readAsBytesSync());

    expect(result.recognitionStatus, 'Success');
    expect(result.overallScore, 91);
    expect(result.recognizedText, 'able');
    expect(result.wordResults.single.phonemes, hasLength(3));
    expect(result.userAudioPath, wavFile.path);
    expect(result.referenceAudioUrl, 'https://example.com/able.mp3');
  });

  test('a 401 raises a token-rejected PronunciationHttpException', () async {
    final client = MockClient(
      (request) async => http.Response('unauthorized', 401),
    );
    final service = PronunciationAssessmentService(client: client);

    expect(
      service.assess(
        target: 'able',
        audioPath: wavFile.path,
        access: _access(),
        attempt: 1,
      ),
      throwsA(
        isA<PronunciationHttpException>().having(
          (e) => e.statusCode,
          'statusCode',
          401,
        ),
      ),
    );
  });

  test('InitialSilenceTimeout raises a status exception', () async {
    final client = MockClient(
      (request) async => http.Response(
        jsonEncode({'RecognitionStatus': 'InitialSilenceTimeout'}),
        200,
      ),
    );
    final service = PronunciationAssessmentService(client: client);

    expect(
      service.assess(
        target: 'able',
        audioPath: wavFile.path,
        access: _access(),
        attempt: 1,
      ),
      throwsA(
        isA<PronunciationRecognitionStatusException>().having(
          (e) => e.status,
          'status',
          'InitialSilenceTimeout',
        ),
      ),
    );
  });

  test(
    'NoMatch is returned as a valid (unscored) result, not an error',
    () async {
      final client = MockClient(
        (request) async => http.Response(
          jsonEncode({'RecognitionStatus': 'NoMatch', 'NBest': []}),
          200,
        ),
      );
      final service = PronunciationAssessmentService(client: client);

      final result = await service.assess(
        target: 'able',
        audioPath: wavFile.path,
        access: _access(),
        attempt: 1,
      );

      expect(result.hasScores, isFalse);
      expect(result.recognitionStatus, 'NoMatch');
    },
  );
}
