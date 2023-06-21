// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quick_blue/quick_blue.dart';

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
  String connectedString = 'Click to Connect to Bluetooth Device\n\n\n';
  _BlueTooth blueTooth = _BlueTooth();

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
                    onPressed: () async {
                        // ignore: await_only_futures, unrelated_type_equality_checks
                        if(await blueTooth.connect == true){
                          setState(() {
                            connectedString = 'Bluetooth Device can be connected\n\n\n';
                          });
                        }else{
                          setState(() {
                            connectedString = 'Bluetooth is not enabled on device\n\n\n';
                          });
                        }
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

class _ConnectedPageState extends State<ConnectedPage>{

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}

class _BlueTooth {
  Future<bool> checkIfBTIsEnabled() async {
    if (await QuickBlue.isBluetoothAvailable()) {
      print('device cannot connect');
      return false;
    } else {
      print('device can connect');
      return true;
    }
  }

  Future<bool> connect() async {
    if (!await checkIfBTIsEnabled()) {
      return false;
    }
    // QuickBlue.scanResultStream.listen((event) {
    //     print('onScanResult $event');
    // });

    //QuickBlue.startScan();

    // QuickBlue.

    return true;
  }
}
