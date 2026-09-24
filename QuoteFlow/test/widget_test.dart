import 'package:flutter_test/flutter_test.dart';
import 'package:quoteflow/models/quote.dart';

void main() {
  group('Quote Model', () {
    test('should create a Quote with text and author', () {
      const quote = Quote(
        text: 'Test quote',
        author: 'Test Author',
      );
      expect(quote.text, 'Test quote');
      expect(quote.author, 'Test Author');
    });

    test('should support const constructor', () {
      const quote1 = Quote(text: 'A', author: 'B');
      const quote2 = Quote(text: 'A', author: 'B');
      expect(quote1.text, equals(quote2.text));
      expect(quote1.author, equals(quote2.author));
    });
  });
}
