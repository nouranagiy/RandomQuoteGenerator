import 'package:flutter/material.dart';
import 'package:quoteflow/core/theme/app_theme.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? errorText;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool readOnly;
  final bool autocorrect;
  final bool enableSuggestions;
  final int? maxLines;
  final int? minLines;
  final ValueChanged<String>? onFieldSubmitted;
  final VoidCallback? onTap;
  final AutovalidateMode? autovalidateMode;

  const CustomTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.errorText,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.focusNode,
    this.autofocus = false,
    this.readOnly = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.maxLines,
    this.minLines,
    this.onFieldSubmitted,
    this.onTap,
    this.autovalidateMode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      enabled: enabled,
      readOnly: readOnly,
      autofocus: autofocus,
      autocorrect: autocorrect,
      enableSuggestions: enableSuggestions,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      focusNode: focusNode,
      maxLines: obscureText ? 1 : maxLines,
      minLines: obscureText ? 1 : minLines,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      onTap: onTap,
      autovalidateMode: autovalidateMode,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon == null
            ? null
            : Icon(prefixIcon, size: AppSizes.iconMd),
        suffixIcon: suffixIcon,
        errorText: errorText,
      ),
    );
  }
}
