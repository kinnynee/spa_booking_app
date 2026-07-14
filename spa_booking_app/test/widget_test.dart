import 'package:flutter_test/flutter_test.dart';

import 'package:spa_booking_app/app.dart';

void main() {
  testWidgets('shows the login screen on launch', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.textContaining('Email'), findsOneWidget);
    expect(find.text('admin@local.spa'), findsOneWidget);
    expect(find.textContaining('API:'), findsOneWidget);
  });
}
