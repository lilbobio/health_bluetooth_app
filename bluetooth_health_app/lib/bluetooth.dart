import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

//import 'package:flutter_blue_plus/flutter_blue_plus.dart';

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

  findCharacteristics(BluetoothService service) async {
    var characteristics = service.characteristics;
    for(BluetoothCharacteristic c in characteristics){
     // List<int> value = await c.read();
      if (kDebugMode) {
        //print('c.read of $service: $value');
        print('descriptors of $service: ${c.descriptors}');
        print('properties of $service: ${c.properties}');
        print('');
      }
    }
  }

}