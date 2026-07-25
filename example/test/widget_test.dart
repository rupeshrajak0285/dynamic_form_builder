import 'package:flutter_test/flutter_test.dart';
import 'package:json_form_engine_example/main.dart';

void main() {
  testWidgets('demo app builds', (tester) async {
    await tester.pumpWidget(const DemoApp());
    expect(find.text('json_form_engine'), findsOneWidget);
  });
}
