import 'package:flutter/foundation.dart';

enum PronunciationErrorType {
  none,
  omission,
  insertion,
  mispronunciation;

  static PronunciationErrorType fromField(Object? value) {
    switch (value) {
      case 'Omission':
        return PronunciationErrorType.omission;
      case 'Insertion':
        return PronunciationErrorType.insertion;
      case 'Mispronunciation':
        return PronunciationErrorType.mispronunciation;
      default:
        return PronunciationErrorType.none;
    }
  }
}

@immutable
class AssessmentPhoneme {
  final String phone;
  final int accuracy;

  final int? offset;

  final int? duration;

  const AssessmentPhoneme({
    required this.phone,
    required this.accuracy,
    this.offset,
    this.duration,
  });
}

@immutable
class AssessmentSyllable {
  final String syllable;
  final int accuracy;
  final int? offset;
  final int? duration;

  const AssessmentSyllable({
    required this.syllable,
    required this.accuracy,
    this.offset,
    this.duration,
  });
}

@immutable
class AssessmentWordResult {
  final String word;
  final int accuracy;
  final PronunciationErrorType errorType;
  final int? offset;
  final int? duration;
  final List<AssessmentSyllable> syllables;
  final List<AssessmentPhoneme> phonemes;

  const AssessmentWordResult({
    required this.word,
    required this.accuracy,
    required this.errorType,
    this.offset,
    this.duration,
    this.syllables = const [],
    this.phonemes = const [],
  });
}

@immutable
class PronunciationAssessmentResultModel {
  final String target;

  final String? recognizedText;

  final String recognitionStatus;

  final int? overallScore;

  final int? accuracyScore;

  final int? fluencyScore;

  final int? completenessScore;

  final int? prosodyScore;

  final double? confidence;

  final List<AssessmentWordResult> wordResults;

  final int attempt;

  final String? userAudioPath;

  final String? referenceAudioUrl;

  const PronunciationAssessmentResultModel({
    required this.target,
    required this.recognitionStatus,
    this.recognizedText,
    this.overallScore,
    this.accuracyScore,
    this.fluencyScore,
    this.completenessScore,
    this.prosodyScore,
    this.confidence,
    this.wordResults = const [],
    required this.attempt,
    this.userAudioPath,
    this.referenceAudioUrl,
  });

  bool get hasScores => overallScore != null;

  bool get isScorable => recognitionStatus == 'Success' && hasScores;

  bool get isAcceptable =>
      isScorable && (overallScore ?? 0) >= _acceptableScoreThreshold;

  List<AssessmentPhoneme> get phonemeResults => [
    for (final word in wordResults) ...word.phonemes,
  ];

  List<PronunciationErrorType> get errorTypes => {
    for (final word in wordResults)
      if (word.errorType != PronunciationErrorType.none) word.errorType,
  }.toList(growable: false);

  int? get _pronScore => overallScore ?? accuracyScore;

  int get score => _pronScore ?? 0;

  static const int _acceptableScoreThreshold = 80;

  factory PronunciationAssessmentResultModel.fromAzureJson({
    required Map<String, dynamic> json,
    required String target,
    required int attempt,
    String? userAudioPath,
    String? referenceAudioUrl,
  }) {
    final status = (json['RecognitionStatus'] as String?) ?? 'Error';
    final nbest = _firstNBest(json);

    if (nbest == null) {
      return PronunciationAssessmentResultModel(
        target: target,
        recognitionStatus: status,
        attempt: attempt,
        userAudioPath: userAudioPath,
        referenceAudioUrl: referenceAudioUrl,
      );
    }

    return PronunciationAssessmentResultModel(
      target: target,
      recognitionStatus: status,
      recognizedText: _recognizedText(nbest),
      overallScore: _num(nbest, 'PronScore'),
      accuracyScore: _num(nbest, 'AccuracyScore'),
      fluencyScore: _num(nbest, 'FluencyScore'),
      completenessScore: _num(nbest, 'CompletenessScore'),
      prosodyScore: _num(nbest, 'ProsodyScore'),
      confidence: (nbest['Confidence'] as num?)?.toDouble(),
      wordResults: _parseWords(nbest['Words']),
      attempt: attempt,
      userAudioPath: userAudioPath,
      referenceAudioUrl: referenceAudioUrl,
    );
  }

  static Map<String, dynamic>? _firstNBest(Map<String, dynamic> json) {
    final nbest = json['NBest'];
    if (nbest is List && nbest.isNotEmpty && nbest.first is Map) {
      return (nbest.first as Map).cast<String, dynamic>();
    }
    return null;
  }

  static String? _recognizedText(Map<String, dynamic> nbest) {
    for (final key in const ['Lexical', 'ITN', 'MaskedITN', 'Display']) {
      final value = nbest[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  static int? _num(Map<String, dynamic> map, String key) {
    final direct = map[key];
    if (direct is num) return direct.round();

    final nested = map['PronunciationAssessment'];
    if (nested is Map) {
      final value = nested[key];
      if (value is num) return value.round();
    }
    return null;
  }

  static List<AssessmentWordResult> _parseWords(Object? wordsField) {
    if (wordsField is! List) return const [];
    final words = <AssessmentWordResult>[];
    for (final entry in wordsField) {
      if (entry is! Map) continue;
      final map = entry.cast<String, dynamic>();
      final word = map['Word'];
      if (word is! String || word.trim().isEmpty) continue;
      words.add(
        AssessmentWordResult(
          word: word,
          accuracy: _num(map, 'AccuracyScore') ?? 0,
          errorType: PronunciationErrorType.fromField(
            map['ErrorType'] ?? _nested(map, 'ErrorType'),
          ),
          offset: _rawInt(map, 'Offset'),
          duration: _rawInt(map, 'Duration'),
          syllables: _parseSubUnits<AssessmentSyllable, String>(
            map['Syllables'],
            'Syllable',
            (phone, accuracy, offset, duration) => AssessmentSyllable(
              syllable: phone,
              accuracy: accuracy,
              offset: offset,
              duration: duration,
            ),
          ),
          phonemes: _parseSubUnits<AssessmentPhoneme, String>(
            map['Phonemes'],
            'Phoneme',
            (phone, accuracy, offset, duration) => AssessmentPhoneme(
              phone: phone,
              accuracy: accuracy,
              offset: offset,
              duration: duration,
            ),
          ),
        ),
      );
    }
    return words;
  }

  static Object? _nested(Map<String, dynamic> map, String key) {
    final nested = map['PronunciationAssessment'];
    if (nested is Map) return nested[key];
    return null;
  }

  static int? _rawInt(Map<String, dynamic> map, String key) {
    final value = map[key];
    return value is num ? value.toInt() : null;
  }

  static List<T> _parseSubUnits<T, P>(
    Object? field,
    String label,
    T Function(P unit, int accuracy, int? offset, int? duration) build,
  ) {
    if (field is! List) return const [];
    final result = <T>[];
    for (final entry in field) {
      if (entry is! Map) continue;
      final map = entry.cast<String, dynamic>();
      final unit = map[label];
      if (unit is! String) continue;
      final assessment = map['PronunciationAssessment'];
      final accuracyMap = assessment is Map
          ? assessment.cast<String, dynamic>()
          : const <String, dynamic>{};
      result.add(
        build(
          unit as P,
          (_num(accuracyMap, 'AccuracyScore') ?? 0),
          _rawInt(map, 'Offset'),
          _rawInt(map, 'Duration'),
        ),
      );
    }
    return result;
  }
}
