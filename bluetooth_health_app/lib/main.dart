import 'package:flutter/material.dart';
import 'home_page.dart';

void main() {
  runApp(const BLEApp());
}

class BLEApp extends StatelessWidget {
  const BLEApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MIE Scale App',
      theme: ThemeData(
          fontFamily: 'NexaText',
          brightness: Brightness.light,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green.shade700)),
      home: const HomePage(
        title: 'MIE Bluetooth Scale App',
      ),
    );
  }
}