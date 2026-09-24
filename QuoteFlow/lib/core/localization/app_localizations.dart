import 'package:flutter/material.dart';
import 'package:quoteflow/core/localization/l10n.dart';
import 'package:quoteflow/core/localization/l10n_en.dart';
import 'package:quoteflow/core/localization/l10n_ar.dart';

class AppLocalizations {
  AppLocalizations._();

  static L10n of(Locale locale) {
    switch (locale.languageCode) {
      case 'ar':
        return L10nAr();
      default:
        return L10nEn();
    }
  }
}

extension BuildContextLocalization on BuildContext {
  L10n get l10n => AppLocalizations.of(Localizations.localeOf(this));
}
