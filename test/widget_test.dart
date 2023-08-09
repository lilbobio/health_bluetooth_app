import 'package:flutter_test/flutter_test.dart';

import 'package:bluetooth_health_app/device_page.dart';

//TODO: fix this test
void main() {
  testWidgets('Tests if device page has a title', (tester) async {
    await tester.pumpWidget(const DevicePage(title: 'T'));
    final titleFinder = find.text('T');

    expect(titleFinder, findsOneWidget);
  });
}
