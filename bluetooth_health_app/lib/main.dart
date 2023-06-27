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
          brightness: Brightness.light,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green.shade700)),
      home: const MyHomePage(
        title: 'MIE Bluetooth Scale App',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String connectedString = '\n\n\nClick to Connect to Bluetooth Device\n\n\n';
  FlutterBlue flutterBlue = FlutterBlue.instance;

  Future<bool> checkBluetooth() async {
    if (await flutterBlue.isAvailable && await flutterBlue.isOn) {
      return true;
    }
    return false;
  }

  void scan() {
    setState(() {
      connectedString = '\n\n\nScanning for Devices...\n\n\n';
    });

    String newConnectedString = '';
    checkBluetooth().then((bool result) {
      if (result) {
        flutterBlue.startScan(timeout: const Duration(seconds: 4));
        int numberOfDevices = 0;

        var scanResult = flutterBlue.scanResults.listen((results) {
          for (ScanResult r in results) {
            if (r.device.name.compareTo("") != 0) {
              numberOfDevices++;
              newConnectedString =
                  '$newConnectedString ${r.device.name} found! \n';
            }

            if (kDebugMode) {
              print('${r.device.name} found! rssi: ${r.rssi}');
            }
          }
        });

        flutterBlue.stopScan();

        Future.delayed(const Duration(seconds: 4), () {
          newConnectedString = '\n\n\nfound $numberOfDevices bluetooth devices \n$newConnectedString\n\n\n';
          setState(() {
            connectedString = newConnectedString;
          });
          if (kDebugMode) {
            print('newCSTring $newConnectedString');
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                //width: 130,
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
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        scan();
                      });
                    },
                    heroTag: null,
                    child: const Icon(Icons.bluetooth),
                  ),
                ],
              ),
            ),
          ],
        ),
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
