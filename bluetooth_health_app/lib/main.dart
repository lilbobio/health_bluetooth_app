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

// class ScanPage extends StatefulWidget {
//   const ScanPage({super.key, required this.title});
//   final String title;

//   @override
//   State<ScanPage> createState() => _ScanPageState();
// }

// class _ScanPageState extends State<ScanPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: SafeArea(
//         child:
//         ),
//     );
//   }
// }

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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            //MIE LOGO
            Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                //width: 130,
                child: SizedBox(
                  child: Image.asset('assets/images/logo.jpg'),
                ),
              ),
            ),

            //Text and Bluetooth Button
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
                        connectedString = '\n\n\nScanning for Devices...\n\n\n';
                        bluetooth.scan();
                        Future.delayed(const Duration(seconds: 4), () {
                          setState(() {
                            connectedString = '';
                            int realDevicesNum = 1;
                            for (int i = 0;
                                i < bluetooth.scanResultList.length;
                                i++) {
                              String deviceName = bluetooth.scanResultList
                                  .elementAt(i)
                                  .device
                                  .name;

                              if (deviceName.compareTo("") != 0) {
                                connectedString =
                                    '$connectedString $realDevicesNum: $deviceName\n';
                                realDevicesNum++;
                              }
                            }
                            connectedString =
                                '\n\n\nFound ${realDevicesNum - 1} Bluetooth Devices\n$connectedString\n\n\n';
                          });
                        });
                      });
                    },

                    //bluetooth button
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

  Container afterScanButtonContainer(BluetoothDevice device, Bluetooth bluetooth){
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextButton(onPressed: setState(() {
            bluetooth.connect(device);
          }),
          child: 
          Text(device.name)
          )
        ]
      ),
    );
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
    device.connect().then((value){
      if (kDebugMode) {
        print("$device is connected");
      }
    });
  }

  void disconnect(BluetoothDevice device){
    device.disconnect();
  }
}
