import 'package:flutter/foundation.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart' as frb;

class Bluetooth {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  frb.FlutterReactiveBle flutterReactiveBle = frb.FlutterReactiveBle(); 
  List<ScanResult> scanResultList = <ScanResult>[];
  final String heartRateMonitorUUID = '180d';
  final String scaleUUID = '181d';
  final String bloodPressureUUID = '1810';

  Future<bool> checkBluetooth() async {
    if (await flutterBlue.isAvailable && await flutterBlue.isOn) {
      return true;
    }
    return false;
  }

  void scan(int timeInSeconds) {
    checkBluetooth().then((bool result) {
      if (result) {
        flutterBlue.startScan(timeout: Duration(seconds: timeInSeconds));

        flutterBlue.scanResults.listen((results) {
          scanResultList = results;
        });

        flutterBlue.stopScan();
      }
    });
  }

  Future<void> connect(BluetoothDevice device) async {
    if (kDebugMode) {
      print("about to connect\n");
    }
    await device.connect();
    if (kDebugMode) {
      print("connected\n");
    }
  }

  void disconnect(BluetoothDevice device) {
    device.disconnect();
  }

  Future<List<BluetoothService>> findServices(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    return services;
  }
}
