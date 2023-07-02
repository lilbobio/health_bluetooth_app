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
                                  '\n\n\n0 Devices Found\nScan Again\n\n\n';
                            } else {
                              connectedString =
                                  '\n\n\nClick to Connect to Bluetooth Device\n\n\n';
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
  int _buttonCount = 1;
  String infoString = '\n\n\nClick on the Device You Want to Connect to\n\n\n';

  @override
  Widget build(BuildContext context) {
    List<Widget> buttonWidgets = List.generate(
      _buttonCount,
      ((int i) => ButtonRow(
          device: widget.devices.elementAt(0), bluetooth: widget.bluetooth,)),
    );

    for (int i = 1; i < widget.devices.length; i++) {
      _buttonCount++;
      setState(() {
        buttonWidgets.add(ButtonRow(
            device: widget.devices.elementAt(i), bluetooth: widget.bluetooth,));
      });
    }

    if (kDebugMode) {
      print(widget.bluetooth);
      print(widget.devices);
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
                child: SizedBox(
                  child: Text(infoString),
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
  const ButtonRow({super.key, required this.device, required this.bluetooth});
  final BluetoothDevice device;
  final Bluetooth bluetooth;
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
            child: Text(widget.device.name),
          )
        ],
      ),
    );
  }

  scanButtonPressed(BluetoothDevice device) {
    setState(() {
    //  widget.infoString = 'Connecting to Device';
      _isDisable = true;
    });



    widget.bluetooth.connect(device);

    setState(() {
      _isDisable = false;
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
