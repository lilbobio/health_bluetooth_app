import 'dart:async';
// import 'dart:developer';
// import 'dart:typed_data';

import 'package:flutter/foundation.dart';
// import 'package:flutter/widgets.dart';
//import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class Bluetooth {
  FlutterReactiveBle flutterReactiveBle = FlutterReactiveBle();
  List<DiscoveredDevice> devices = <DiscoveredDevice>[];
  final String heartRateMonitorUUIDString = '180d';
  final String scaleUUIDString = '181d';
  final String bloodPressureUUIDString = '1810';
  final Uuid hrmUuid = Uuid.parse('180D');
  final Uuid scaleUuid = Uuid.parse('181D');
  final Uuid bloodPressureUuid = Uuid.parse('1810');
  bool isConnected = false;

  // ignore: avoid_init_to_null
  StreamSubscription? subscription = null;
  // ignore: avoid_init_to_null
  StreamSubscription? deviceConnection = null;

  //frbScan was inspired by:
  //https://github.com/epietrowicz/flutter_reactive_ble_example/blob/master/lib/src/ble/ble_scanner.dart

  void frbScan() {
    devices.clear();
    subscription?.cancel();
    subscription = flutterReactiveBle.scanForDevices(
        withServices: [hrmUuid, scaleUuid, bloodPressureUuid],
        scanMode: ScanMode.balanced).listen((device) {
      if (device.name.isNotEmpty) {
        int index = 0;
        if (kDebugMode) {
          print('scanned device: $device');
          print('${device.serviceUuids}');
        }
        while (index != device.serviceUuids.length) {
          if (hrmUuid == device.serviceUuids.elementAt(index)) {
            if (kDebugMode) {
              print('hrmUuid == ${device.serviceUuids.elementAt(index)}');
            }
          }
          index++;
        }

        final deviceIndex =
            devices.indexWhere((element) => element.id == device.id);
        if (deviceIndex >= 0) {
          devices[deviceIndex] = device;
        } else {
          devices.add(device);
        }
      }
    }, onError: (error, stack) {
      if (kDebugMode) {
        print('the scan failed because of: $error');
        print('error stack: $stack');
      }
    });
  }

  fbrEndScan() async {
    await subscription?.cancel();
    subscription = null;
  }

  connect(DiscoveredDevice device) {
    if (kDebugMode) {
      print("about to connect to $device");
    }

    deviceConnection?.cancel();
    if (kDebugMode) {
      print('going into device connection');
    }
    deviceConnection =
        flutterReactiveBle.connectToDevice(id: device.id).listen((update) {
      if (kDebugMode) {
        print('hello');
        print(update.connectionState);
      }
      if (update.connectionState == DeviceConnectionState.connected) {
        if (kDebugMode) {
          print('connected to device');
        }
        isConnected = true;
      }
    });
  }

  disconnect() async {
    await deviceConnection?.cancel();
    deviceConnection = null;
    isConnected = false;
  }

  Future<List<DiscoveredService>> findServices(String deviceId) async {
    final result = await flutterReactiveBle.discoverServices(deviceId);
    return result;
  }
}
