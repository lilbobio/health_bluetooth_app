import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:bluetooth_health_app/device_page.dart';
import 'bluetooth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String connectedString = '\n\n\nClick to Connect to Bluetooth Device\n\n';
  Bluetooth bluetooth = Bluetooth();

  @override
  Widget build(BuildContext context) {
    List<Widget> homePageWidgetsList = List.empty(growable: true);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Column(children: [
          Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              child: SizedBox(
                child: Image.asset('assets/images/logo.jpg'),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  connectedString,
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      homePageWidgetsList.clear();
                      List<BluetoothDevice> bleList = [];
                      connectedString = '\n\n\nScanning for Devices...\n\n';
                      bluetooth.scan();
                      Future.delayed(
                        const Duration(seconds: 4),
                        () {
                          setState(() {
                            connectedString = '';
                            for (int i = 0;
                                i < bluetooth.scanResultList.length;
                                i++) {
                              BluetoothDevice bluetoothDevice =
                                  bluetooth.scanResultList.elementAt(i).device;
                              if (bluetoothDevice.name.compareTo("") != 0) {
                                bleList.add(bluetoothDevice);
                              } //if statement
                            } //for loop
                            if (bleList.isEmpty) {
                              connectedString =
                                  '\n\n\n0 Devices Found\nScan Again\n\n';
                            } else {
                              connectedString =
                                  '\n\n\nClick to Connect to Bluetooth Device\n\n';
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: ((context) => AfterScanPage(
                                        devices: bleList,
                                        bluetooth: bluetooth,
                                        title: widget.title)),
                                  ));
                            } //else
                          }); //setState
                        }, //Duration
                      );
                    }); //setState
                  }, //onPressed
                  heroTag: null,
                  child: const Icon(Icons.bluetooth),
                ),
              ],
            ),
          )
        ]),
      ),
    );
  }
}