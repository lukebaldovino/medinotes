import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medinotes/main.dart';

void main() {
  testWidgets('App smoke test builds cleanly', (WidgetTester tester) async {
    await tester.pumpWidget(const MediNotesApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
