import 'package:flutter_test/flutter_test.dart';
import 'package:task3/main.dart';

void main() {
  testWidgets('App builds', (WidgetTester tester) async {
    await tester.pumpWidget(const FitTrackApp());
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}