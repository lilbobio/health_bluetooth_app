import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MIE Scale App',
      theme: ThemeData(
          fontFamily: 'NexaText',
          brightness: Brightness.light,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green.shade700)),
      home: const MyHomePage(
        title: 'MIE Bluetooth Scale App',
      ),
    );
  }
}

class ConnectedPage extends StatefulWidget {
  const ConnectedPage({super.key, required this.title});

  final String title;
  @override
  State<ConnectedPage> createState() => _ConnectedPageState();
}

class _ConnectedPageState extends State<ConnectedPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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

class AfterScanPage extends StatefulWidget {
  const AfterScanPage(
      {super.key,
      required this.devices,
      required this.bluetooth,
      required this.title});
  final List<BluetoothDevice> devices;
  final Bluetooth bluetooth;
  final String title;

  @override
  State<StatefulWidget> createState() => _AfterScanPage();
}

class _AfterScanPage extends State<AfterScanPage> {
  String infoString = '\n\n\n     Click on the Device\nYou Want to Connect to\n\n';
  int _buttonCount = 1;

  changeInfoString(String str) {
    setState(() {
      infoString = str;
    });
  }

  @override
  Widget build(BuildContext context) {
    int buttonCount = widget.devices.length;

    List<Widget> buttonWidgets2 = List.generate(
      _buttonCount,
      (int i) => ButtonRow(
          device: widget.devices.elementAt(0),
          bluetooth: widget.bluetooth,
          infoString: changeInfoString),
    );

    List<Widget> buttonWidgets = List.filled(
      buttonCount,
      ButtonRow(
        bluetooth: widget.bluetooth,
        device: widget.devices.elementAt(0),
        infoString: changeInfoString,
      ),
    );

    for (int i = 1; i < widget.devices.length; i++) {
      _buttonCount++;
      setState(() {
        buttonWidgets2.add(ButtonRow(
            device: widget.devices.elementAt(i),
            bluetooth: widget.bluetooth,
            infoString: changeInfoString));
      });
    }

    for (int i = 0; i < widget.devices.length; i++) {
      if (kDebugMode) {
        print('device $i: ${widget.devices[i]}');
      }
      setState(() {
        buttonWidgets[i] = ButtonRow(
          bluetooth: widget.bluetooth,
          device: widget.devices.elementAt(i),
          infoString: changeInfoString,
        );
      });
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                child: SizedBox(
                  child: Image.asset('assets/images/logo.jpg'),
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                child: Text(
                  infoString,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: buttonWidgets,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ButtonRow extends StatefulWidget {
  const ButtonRow(
      {super.key,
      required this.device,
      required this.bluetooth,
      required this.infoString});
  final BluetoothDevice device;
  final Bluetooth bluetooth;
  final Function(String str) infoString;

  @override
  State<StatefulWidget> createState() => _ButtonRow();
}

class _ButtonRow extends State<ButtonRow> {
  bool _isDisable = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170.0,
      child: Column(
        children: <Widget>[
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                textStyle: const TextStyle(fontSize: 20)),
            onPressed: () {
              if (_isDisable == true) {
                return;
              }
              setState(() {
                scanButtonPressed(widget.device);
              });
            },
            child: Text(
              widget.device.name,
              style: const TextStyle(
                fontSize: 18.0,
              ),
            ),
          )
        ],
      ),
    );
  }

  scanButtonPressed(BluetoothDevice device) {
    setState(() {
      _isDisable = true;
    });

    widget.infoString('\n\n\nconnecting to ${device.name}...\n\n\n');

    widget.bluetooth.connect(device).then((value) {
      if (kDebugMode) {
        print('{device.name} is connected');
      }
      widget.infoString('\n\n\nConnected to ${device.name}.\n\n\n');
      setState(() {
        _isDisable = false;
      });
    });
  }
}

class Bluetooth {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  var scanResultList = <ScanResult>[];

  Future<bool> checkBluetooth() async {
    if (await flutterBlue.isAvailable && await flutterBlue.isOn) {
      return true;
    }
    return false;
  }

  void scan() {
    checkBluetooth().then((bool result) {
      if (result) {
        flutterBlue.startScan(timeout: const Duration(seconds: 4));

        flutterBlue.scanResults.listen((results) {
          scanResultList = results;
        });

        flutterBlue.stopScan();
      }
    });
  }

  Future<void> connect(BluetoothDevice device) async {
    await device.connect();
  }

  void disconnect(BluetoothDevice device) {
    device.disconnect();
  }
}
