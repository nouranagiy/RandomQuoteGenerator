import 'package:flutter_test/flutter_test.dart';
import 'package:lingolearn/features/pronunciation/data/pronunciation_assessment_result_model.dart';

Map<String, dynamic> _successResponse() {
  return {
    'RecognitionStatus': 'Success',
    'Offset': 700000,
    'Duration': 8400000,
    'DisplayText': 'Good morning.',
    'NBest': [
      {
        'Confidence': 0.98503506,
        'Lexical': 'good morning',
        'ITN': 'good morning',
        'MaskedITN': 'good morning',
        'Display': 'Good morning.',
        'AccuracyScore': 100.0,
        'FluencyScore': 100.0,
        'ProsodyScore': 87.8,
        'CompletenessScore': 100.0,
        'PronScore': 95.1,
        'Words': [
          {
            'Word': 'good',
            'Offset': 700000,
            'Duration': 2600000,
            'AccuracyScore': 100.0,
            'ErrorType': 'None',
            'Syllables': [
              {
                'Syllable': 'gud',
                'PronunciationAssessment': {'AccuracyScore': 100},
                'Offset': 700000,
                'Duration': 1300000,
              },
            ],
            'Phonemes': [
              {
                'Phoneme': 'g',
                'PronunciationAssessment': {'AccuracyScore': 100},
                'Offset': 700000,
                'Duration': 600000,
              },
              {
                'Phoneme': 'uh',
                'PronunciationAssessment': {'AccuracyScore': 100},
                'Offset': 1400000,
                'Duration': 500000,
              },
              {
                'Phoneme': 'd',
                'PronunciationAssessment': {'AccuracyScore': 55},
                'Offset': 1900000,
                'Duration': 700000,
              },
            ],
          },
          {
            'Word': 'morning',
            'Offset': 3400000,
            'Duration': 5700000,
            'AccuracyScore': 72.0,
            'ErrorType': 'Mispronunciation',
            'Phonemes': [
              {
                'Phoneme': 'm',
                'PronunciationAssessment': {'AccuracyScore': 99},
              },
            ],
          },
        ],
      },
    ],
  };
}

void main() {
  test('parses a detailed Success response with word + phoneme accuracy', () {
    final model = PronunciationAssessmentResultModel.fromAzureJson(
      json: _successResponse(),
      target: 'good morning',
      attempt: 3,
      userAudioPath: r'C:\tmp\a.wav',
      referenceAudioUrl: 'https://example.com/good.mp3',
    );

    expect(model.recognitionStatus, 'Success');
    expect(model.hasScores, isTrue);
    expect(model.overallScore, 95);
    expect(model.accuracyScore, 100);
    expect(model.fluencyScore, 100);
    expect(model.completenessScore, 100);
    expect(model.prosodyScore, 88);
    expect(model.confidence, closeTo(0.98503506, 1e-9));
    expect(model.recognizedText, 'good morning');

    expect(model.wordResults, hasLength(2));
    final morning = model.wordResults[1];
    expect(morning.word, 'morning');
    expect(morning.accuracy, 72);
    expect(morning.errorType, PronunciationErrorType.mispronunciation);
    expect(morning.phonemes.single.phone, 'm');

    final good = model.wordResults[0];
    expect(good.syllables, hasLength(1));
    expect(good.syllables.single.syllable, 'gud');
    expect(good.phonemes, hasLength(3));
    expect(good.phonemes[2].phone, 'd');
    expect(good.phonemes[2].accuracy, 55);
    expect(good.phonemes[0].offset, 700000);

    expect(model.errorTypes, [PronunciationErrorType.mispronunciation]);
    expect(model.phonemeResults, hasLength(4));
    expect(model.userAudioPath, r'C:\tmp\a.wav');
    expect(model.referenceAudioUrl, 'https://example.com/good.mp3');
    expect(model.attempt, 3);
  });

  test('NoMatch returns a model without scores (shape preserved)', () {
    final model = PronunciationAssessmentResultModel.fromAzureJson(
      json: {'RecognitionStatus': 'NoMatch', 'NBest': []},
      target: 'able',
      attempt: 1,
    );

    expect(model.recognitionStatus, 'NoMatch');
    expect(model.hasScores, isFalse);
    expect(model.isScorable, isFalse);
    expect(model.wordResults, isEmpty);
    expect(model.recognizedText, isNull);
    expect(model.score, 0);
  });

  test('missing NBest degrades to an unscored model', () {
    final model = PronunciationAssessmentResultModel.fromAzureJson(
      json: {'RecognitionStatus': 'Success'},
      target: 'able',
      attempt: 1,
    );

    expect(model.recognitionStatus, 'Success');
    expect(model.hasScores, isFalse);
    expect(model.wordResults, isEmpty);
  });

  test('isAcceptable only when scored at or above the threshold', () {
    final low = PronunciationAssessmentResultModel(
      target: 'able',
      recognitionStatus: 'Success',
      overallScore: 60,
      attempt: 1,
    );
    final high = PronunciationAssessmentResultModel(
      target: 'able',
      recognitionStatus: 'Success',
      overallScore: 92,
      attempt: 1,
    );

    expect(low.isAcceptable, isFalse);
    expect(high.isAcceptable, isTrue);
  });

  test('errorType maps from Azure strings', () {
    expect(
      PronunciationErrorType.fromField('Omission'),
      PronunciationErrorType.omission,
    );
    expect(
      PronunciationErrorType.fromField('Insertion'),
      PronunciationErrorType.insertion,
    );
    expect(
      PronunciationErrorType.fromField('Mispronunciation'),
      PronunciationErrorType.mispronunciation,
    );
    expect(PronunciationErrorType.fromField(null), PronunciationErrorType.none);
    expect(
      PronunciationErrorType.fromField('UnexpectedBreak'),
      PronunciationErrorType.none,
    );
  });
}
