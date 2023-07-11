import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'bluetooth.dart';
import 'package:flutter_blue/flutter_blue.dart';
//import 'package:flutter_blue_plus/flutter_blue_plus.dart';

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
  bool _isDisable = false;
  String services = '\n\nFinding Services...\n\n\n';
  late Timer everySecond;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Column(
          children: [
            //MIE Logo
            Align(
              alignment: Alignment.center,
              child: Image.asset('assets/images/logo.jpg'),
            ),

            //Name of device
            Align(
              alignment: Alignment.center,
              child: Text(
                '\n\n\nConnected to ${widget.device.name}\n\n',
                style: const TextStyle(fontSize: 20),
              ),
            ),

            //find services text
            Align(
              alignment: Alignment.center,
              child: Text(services),
            ),

            //find service button
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      findServices(widget.device, widget.bluetooth);
                    });
                  },
                  child: const Text('Find Services')),
            ),

            //disconnect button
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 20)),
                onPressed: () {
                  if (_isDisable == true) {
                    return;
                  }
                  setState(() {
                    disconnect(widget.device, widget.bluetooth);
                    Navigator.pop(context);
                    Navigator.pop(context);
                  });
                },
                child: Text(
                  'Disconnect from ${widget.title}',
                  style: const TextStyle(
                    fontSize: 18.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  disconnect(BluetoothDevice device, Bluetooth bluetooth) {
    setState(() {
      _isDisable = true;
    });
    bluetooth.disconnect(device);
    setState(() {
      _isDisable = false;
    });
  }

  findServices(BluetoothDevice device, Bluetooth bluetooth) {
    bluetooth.findServices(device).then((services) {
      for (var service in services) {
        String uuid = service.uuid.toString();
        uuid = uuid.substring(4, 8);
        if (uuid.compareTo(bluetooth.heartRateMonitorUUID) == 0) {
          if (kDebugMode) {
            print('connected to a heart monitor');
          }
        } else if (uuid.compareTo(bluetooth.scaleUUID) == 0) {
          if (kDebugMode) {
            print('connected to a scale');
          }
        }
      }
    });
  }
}
