import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';

class PronunciationRecordButton extends StatefulWidget {
  final bool isRecording;
  final bool enabled;
  final VoidCallback onPressed;
  final String liveText;

  const PronunciationRecordButton({
    super.key,
    required this.isRecording,
    required this.enabled,
    required this.onPressed,
    this.liveText = '',
  });

  @override
  State<PronunciationRecordButton> createState() =>
      _PronunciationRecordButtonState();
}

class _PronunciationRecordButtonState extends State<PronunciationRecordButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
    lowerBound: 0,
    upperBound: 1,
  );

  @override
  void didUpdateWidget(PronunciationRecordButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !oldWidget.isRecording) {
      _pulse.repeat(reverse: true);
    } else if (!widget.isRecording && oldWidget.isRecording) {
      _pulse.stop();
      _pulse.value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _pulse,
          builder: (context, _) {
            final scale = widget.isRecording ? 1 + 0.05 * _pulse.value : 1.0;
            return Transform.scale(
              scale: scale,
              child: Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.isRecording
                        ? colorScheme.error.withValues(alpha: 0.4)
                        : colorScheme.primary.withValues(alpha: 0.25),
                    width: 2,
                  ),
                ),
                child: Material(
                  shape: const CircleBorder(),
                  color: widget.isRecording
                      ? colorScheme.errorContainer
                      : colorScheme.primary,
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: widget.enabled ? widget.onPressed : null,
                    child: Icon(
                      widget.isRecording
                          ? Icons.stop_rounded
                          : Icons.mic_rounded,
                      size: 44,
                      color: widget.isRecording
                          ? colorScheme.onErrorContainer
                          : colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Text(
          widget.isRecording ? l.tapToStop : l.tapToRecord,
          style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        if (widget.isRecording && widget.liveText.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            '"${widget.liveText.trim()}"',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}
