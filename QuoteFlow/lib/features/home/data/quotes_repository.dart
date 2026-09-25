import 'dart:math';
import 'dart:ui';
import 'package:quoteflow/core/localization/l10n.dart';
import 'package:quoteflow/core/localization/app_localizations.dart';
import 'package:quoteflow/models/quote.dart';

class QuotesRepository {
  static final QuotesRepository instance = QuotesRepository._();
  QuotesRepository._();

  static const List<String> _quoteIds = [
    'q1',
    'q2',
    'q3',
    'q4',
    'q5',
    'q6',
    'q7',
    'q8',
    'q9',
    'q10',
  ];

  final Random _random = Random();

  Quote getRandomQuote(Locale locale, {Quote? exclude}) {
    final L10n context = AppLocalizations.of(locale);
    if (_quoteIds.length <= 1) return _quote(context, _random, 0);
    Quote quote;
    do {
      quote = _quote(context, _random, _random.nextInt(_quoteIds.length));
    } while (exclude != null && quote.text == exclude.text);
    return quote;
  }

  Quote _quote(L10n context, Random random, int index) {
    final id = _quoteIds[index];
    return Quote(text: context.quoteBody(id), author: context.quoteAuthor(id));
  }
}
