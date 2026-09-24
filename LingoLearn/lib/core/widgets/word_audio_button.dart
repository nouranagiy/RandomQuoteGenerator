import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import '../services/word_audio_service.dart';
import '../utils/debug_log.dart';

class WordAudioButton extends StatefulWidget {
  final String text;

  final String? audioUrl;

  final Future<bool> Function()? playOverride;

  final String? label;

  final double iconSize;

  final bool compact;

  final bool enabled;

  final IconData idleIcon;

  final IconData activeIcon;

  const WordAudioButton({
    super.key,
    required this.text,
    this.audioUrl,
    this.playOverride,
    this.label,
    this.iconSize = 24,
    this.compact = true,
    this.enabled = true,
    this.idleIcon = Icons.volume_up_outlined,
    this.activeIcon = Icons.volume_up_rounded,
  });

  @override
  State<WordAudioButton> createState() => _WordAudioButtonState();
}

class _WordAudioButtonState extends State<WordAudioButton> {
  final WordAudioService _audio = WordAudioService();
  bool _isPlaying = false;

  Future<void> _play() async {
    if (_isPlaying) {
      await _audio.stop();
      if (mounted) setState(() => _isPlaying = false);
      return;
    }

    setState(() => _isPlaying = true);
    var success = false;
    try {
      final override = widget.playOverride;
      success = override != null
          ? await override()
          : await _audio.play(widget.text, audioUrl: widget.audioUrl);
    } catch (e) {
      debugLog('WordAudioButton', 'play threw: $e');
    }
    if (!mounted) return;

    if (!success) {
      setState(() => _isPlaying = false);
      final l = AppLocalizations.of(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.pronunciationUnavailable)));
      return;
    }

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    if (widget.compact) {
      return IconButton(
        onPressed: widget.enabled ? _play : null,
        tooltip: l.listen,
        icon: Icon(
          _isPlaying ? widget.activeIcon : widget.idleIcon,
          size: widget.iconSize,
          color: _isPlaying
              ? colorScheme.primary
              : colorScheme.onSurfaceVariant,
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: widget.enabled ? _play : null,
      icon: Icon(
        _isPlaying ? widget.activeIcon : widget.idleIcon,
        size: 20,
        color: _isPlaying ? colorScheme.primary : null,
      ),
      label: Text(widget.label ?? l.listen),
      style: OutlinedButton.styleFrom(
        foregroundColor: _isPlaying ? colorScheme.primary : null,
      ),
    );
  }
}
