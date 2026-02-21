import 'package:flutter_test/flutter_test.dart';
import 'package:kite_co/main.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const KiteCoApp());
    await tester.pumpAndSettle();

    expect(find.text('KITE & CO.'), findsWidgets);
  });
}
