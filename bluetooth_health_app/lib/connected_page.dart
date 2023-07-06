import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'bluetooth.dart';

class ConnectedPage extends StatefulWidget {
  const ConnectedPage(
      {super.key,
      required this.title,
      required this.bluetooth,
      required this.device});

  final String title;
  final Bluetooth bluetooth;
  final BluetoothDevice device;

  @override
  State<ConnectedPage> createState() => _ConnectedPageState();
}

class _ConnectedPageState extends State<ConnectedPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.center,
              child: Image.asset('assets/images/logo.jpg'),
            ),
          ],
        ),
      ),
    );
  }
}