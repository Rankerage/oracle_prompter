import 'package:flutter_test/flutter_test.dart';
import 'package:oracle_prompter/main.dart';

void main() {
  testWidgets('OraclePrompter app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const OraclePrompterApp());
    expect(find.text('OraclePrompter'), findsOneWidget);
    expect(find.text('Hi friend!! I am always with you.'), findsOneWidget);
  });
}
