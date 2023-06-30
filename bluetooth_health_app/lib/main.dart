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
  int _widgetNum = 0;
  String connectedString = '\n\n\nClick to Connect to Bluetooth Device\n\n\n';
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
                      connectedString = '\n\n\nScanning for Devices...\n\n\n';
                      bluetooth.scan();
                      Future.delayed(
                        const Duration(seconds: 4),
                        () {
                          setState(() {
                            connectedString = '';
                            int realDeviceNum = 0;
                            for (int i = 0;
                                i < bluetooth.scanResultList.length;
                                i++) {
                              BluetoothDevice bluetoothDevice =
                                  bluetooth.scanResultList.elementAt(i).device;
                              String deviceName = bluetoothDevice.name;
                              if (deviceName.compareTo("") != 0) {
                                realDeviceNum++;
                                connectedString =
                                    '$connectedString $realDeviceNum: $deviceName\n';
                                bleList.add(bluetoothDevice);
                              } //if statement
                            } //for loop
                            connectedString =
                                '\n\n\nFound $realDeviceNum Bluetooth Devices\n$connectedString\n\n\n';

                            for (int i = 0; i < bleList.length; i++) {
                              setState(() {
                                homePageWidgetsList.add(
                                    afterScanButtonRow(bleList.elementAt(i)));
                              });
                              if (kDebugMode) {
                                print("added ${bleList.elementAt(i)}");
                                print(
                                    'home page widget list${homePageWidgetsList.toString()}');
                              } //if statement
                            } //for loop
                          }); //setState
                        }, //Duration
                      );
                    }); //setState
                  }, //onPressed
                  heroTag: null,
                  child: const Icon(Icons.bluetooth),
                ),
                Container(
                  height: 200.0,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: homePageWidgetsList,
                  ),
                ),
              ],
            ),
          )
        ]),
      ),
    );
  }

  void _addNewButton() {
    setState(() {
      _widgetNum++;
    });
  }

  Widget afterScanButtonRow(BluetoothDevice device) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FloatingActionButton(
            onPressed: () {
              bluetooth.connect(device);
            },
            child: Text(device.name)),
      ],
    );
  }
}

class AfterScanButtonRow extends StatefulWidget {
  const AfterScanButtonRow({super.key, required this.devices, required this.bluetooth});
  final List<BluetoothDevice> devices;
  final Bluetooth bluetooth;

  @override
  State<StatefulWidget> createState() => _AfterScanButtonRowState();
}

class _AfterScanButtonRowState extends State<AfterScanButtonRow> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FloatingActionButton(onPressed: () {}, child: Text(device.name)),
        ],
      ),
    );
  }

String onPressedConnect(Bluetooth bluetooth, BluetoothDevice device) {
  bluetooth.connect(device);
  return device.name;
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

        var scanResult = flutterBlue.scanResults.listen((results) {
          scanResultList = results;
        });

        flutterBlue.stopScan();
      }
    });
  }

  void connect(BluetoothDevice device) {
    device.connect().then((value) {
      if (kDebugMode) {
        print("$device is connected");
      }
    });
  }

  void disconnect(BluetoothDevice device) {
    device.disconnect();
  }
}
