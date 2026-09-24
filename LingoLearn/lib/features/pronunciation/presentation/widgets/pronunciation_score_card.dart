import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/app_card.dart';
import '../../data/pronunciation_assessment_result_model.dart';

class PronunciationScoreCard extends StatelessWidget {
  final PronunciationAssessmentResultModel result;

  const PronunciationScoreCard({super.key, required this.result});

  Color _gradeColor(ColorScheme colorScheme) {
    if (!result.hasScores) return colorScheme.error;
    final score = result.score;
    if (score >= 85) return Colors.green.shade600;
    if (score >= 70) return colorScheme.primary;
    if (score >= 50) return Colors.amber.shade700;
    return colorScheme.error;
  }

  String _gradeMessage(AppLocalizations l) {
    if (!result.hasScores) return l.doesntSoundRight;
    final score = result.score;
    if (score >= 85) return l.excellentPronunciation;
    if (score >= 70) return l.greatPronunciation;
    if (score >= 50) return l.goodPronunciation;
    return l.needsPracticePronunciation;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l = AppLocalizations.of(context);
    final gradeColor = _gradeColor(colorScheme);

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            l.score.toUpperCase(),
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          if (result.hasScores)
            _ScoreCircle(value: result.score, color: gradeColor)
          else
            Text(
              '—',
              style: textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.error,
              ),
            ),
          const SizedBox(height: 16),
          Text(
            _gradeMessage(l),
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(
              color: gradeColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (result.hasScores) ...[
            const SizedBox(height: 18),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                _ScoreFact(label: l.accuracyScore, value: result.accuracyScore),
                _ScoreFact(label: l.fluencyScore, value: result.fluencyScore),
                _ScoreFact(
                  label: l.completenessScore,
                  value: result.completenessScore,
                ),
                if (result.prosodyScore != null)
                  _ScoreFact(label: l.prosodyScore, value: result.prosodyScore),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ScoreCircle extends StatelessWidget {
  final int value;
  final Color color;

  const _ScoreCircle({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: value / 100,
            strokeWidth: 12,
            strokeCap: StrokeCap.round,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest,
            color: color,
          ),
          Center(
            child: Text(
              '$value%',
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreFact extends StatelessWidget {
  final String label;
  final int? value;

  const _ScoreFact({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value == null ? '—' : '$value%',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
