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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green.shade700)
      ),
      home: const MyHomePage(title: 'MIE Bluetooth Scale App'),
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

  void scan() {
    bool isBluetooth = false;
    QuickBlue.isBluetoothAvailable().then((result) => isBluetooth = result);
    if(!isBluetooth){
        print('device cannot connect');

      return;
    }

    QuickBlue.scanResultStream.listen((event) {
        print('onScanResult $event');
    });


    //QuickBlue.startScan();

   // QuickBlue.
  }

  void connect() {
    scan();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Connect to Bluetooth device\n', 
            ),
            FloatingActionButton(
              onPressed: connect,
              heroTag: null,
              child: const Icon(Icons.bluetooth),
            ),

          ],
        ),
      ), 
    );
  }
}
