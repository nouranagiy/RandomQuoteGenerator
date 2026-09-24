import '../../../../../core/localization/app_localizations.dart';

String? validateEmail(String? value, AppLocalizations loc) {
  if (value == null || value.trim().isEmpty) {
    return loc.emailRequired;
  }
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())) {
    return loc.invalidEmail;
  }
  return null;
}
