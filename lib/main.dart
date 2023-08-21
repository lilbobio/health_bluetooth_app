import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';

import 'device_page.dart';

void main() {
  runApp(const BLEApp());
}

class BLEApp extends StatelessWidget {
  const BLEApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GlobalLoaderOverlay(
      child: MaterialApp(
        title: 'MIE Scale App',
        theme: ThemeData(
            fontFamily: 'NexaText',
            brightness: Brightness.light,
            colorScheme:
                ColorScheme.fromSeed(seedColor: Colors.green.shade700)),
        home: const DevicePage(
          title: 'MIE Bluetooth Health App',
        ),
      ),
    );
  } //build
}//BLEApp
