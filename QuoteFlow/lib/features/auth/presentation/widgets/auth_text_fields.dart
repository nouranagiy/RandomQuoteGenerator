import 'package:flutter/material.dart';
import 'package:quoteflow/core/theme/app_theme.dart';
import 'package:quoteflow/shared/widgets/app_icon_button.dart';
import 'package:quoteflow/shared/widgets/custom_text_field.dart';
import 'package:quoteflow/features/auth/presentation/widgets/auth_form_validators.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final FocusNode? focusNode;
  final ValueChanged<String>? onFieldSubmitted;
  final bool autofocus;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final String? errorText;

  const AuthTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.focusNode,
    this.onFieldSubmitted,
    this.autofocus = false,
    this.readOnly = false,
    this.maxLines,
    this.minLines,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      enabled: enabled,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      autofillHints: autofillHints,
      focusNode: focusNode,
      onFieldSubmitted: onFieldSubmitted,
      autofocus: autofocus,
      readOnly: readOnly,
      maxLines: maxLines,
      minLines: minLines,
      errorText: errorText,
    );
  }
}

class AuthEmailField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String requiredMessage;
  final String invalidMessage;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final ValueChanged<String>? onFieldSubmitted;
  final String? errorText;

  const AuthEmailField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    required this.requiredMessage,
    required this.invalidMessage,
    this.onChanged,
    this.enabled = true,
    this.textInputAction = TextInputAction.next,
    this.focusNode,
    this.onFieldSubmitted,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return AuthTextField(
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      validator: (value) => AuthFormValidators.email(
        value,
        requiredMessage: requiredMessage,
        invalidMessage: invalidMessage,
      ),
      onChanged: onChanged,
      enabled: enabled,
      textInputAction: textInputAction,
      autofillHints: const [AutofillHints.email],
      focusNode: focusNode,
      onFieldSubmitted: onFieldSubmitted,
      errorText: errorText,
    );
  }
}

class AuthPasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String showPasswordTooltip;
  final String hidePasswordTooltip;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final FocusNode? focusNode;
  final ValueChanged<String>? onFieldSubmitted;
  final bool initiallyObscured;
  final IconData? prefixIcon;
  final String? errorText;

  const AuthPasswordField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    required this.showPasswordTooltip,
    required this.hidePasswordTooltip,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.textInputAction = TextInputAction.done,
    this.autofillHints = const [AutofillHints.password],
    this.focusNode,
    this.onFieldSubmitted,
    this.initiallyObscured = true,
    this.prefixIcon = Icons.lock_outline_rounded,
    this.errorText,
  });

  @override
  State<AuthPasswordField> createState() => _AuthPasswordFieldState();
}

class _AuthPasswordFieldState extends State<AuthPasswordField> {
  late bool _obscured;

  @override
  void initState() {
    super.initState();
    _obscured = widget.initiallyObscured;
  }

  @override
  Widget build(BuildContext context) {
    final visibilityIcon = _obscured
        ? Icons.visibility_outlined
        : Icons.visibility_off_outlined;
    final visibilityTooltip = _obscured
        ? widget.showPasswordTooltip
        : widget.hidePasswordTooltip;

    return CustomTextField(
      controller: widget.controller,
      labelText: widget.labelText,
      hintText: widget.hintText,
      prefixIcon: widget.prefixIcon,
      obscureText: _obscured,
      keyboardType: TextInputType.visiblePassword,
      validator: widget.validator,
      onChanged: widget.onChanged,
      enabled: widget.enabled,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      focusNode: widget.focusNode,
      onFieldSubmitted: widget.onFieldSubmitted,
      autocorrect: false,
      enableSuggestions: false,
      errorText: widget.errorText,
      suffixIcon: AppIconButton(
        icon: visibilityIcon,
        tooltip: visibilityTooltip,
        onPressed: widget.enabled
            ? () => setState(() => _obscured = !_obscured)
            : null,
        treatment: AppIconButtonTreatment.neutral,
        iconSize: AppSizes.iconSm,
      ),
    );
  }
}
