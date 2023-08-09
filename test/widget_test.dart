import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bluetooth_health_app/main.dart';
import 'package:bluetooth_health_app/device_page.dart';

void main() {
  testWidgets('Tests of device_page has all buttons', (tester) async {
    await tester.pumpWidget(const DevicePage(title: 'T'));
  });
}
