import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';

class Bluetooth {
  FlutterReactiveBle flutterReactiveBle = FlutterReactiveBle();
  List<DiscoveredDevice> devices = <DiscoveredDevice>[];
  final String heartRateMonitorUUIDString = '180d';
  final String scaleUUIDString = '181d';
  final String bloodPressureUUIDString = '1810';
  final String dateTimeUUIDString = '2A08';
  final Uuid hrmUuid = Uuid.parse('180D');
  final Uuid scaleUuid = Uuid.parse('181D');
  final Uuid bloodPressureUuid = Uuid.parse('1810');
  final Uuid dateTimeUuid = Uuid.parse('2A08');
  bool isConnected = false;
  // ignore: avoid_init_to_null
  bool? isConnectable = null;
  // ignore: avoid_init_to_null
  StreamSubscription? subscription = null;
  // ignore: avoid_init_to_null
  StreamSubscription? deviceConnection = null;

  //frbScan was inspired by:
  //https://github.com/epietrowicz/flutter_reactive_ble_example/blob/master/lib/src/ble/ble_scanner.dart
  //and https://github.com/PhilipsHue/flutter_reactive_ble/issues/600

  Future<void> frbScan() async {
    bool scan = false;
    if (Platform.isAndroid) {
      PermissionStatus locationPermission = await Permission.location.request();
      PermissionStatus finePermission =
          await Permission.locationWhenInUse.request();

      if (locationPermission == PermissionStatus.granted &&
          finePermission == PermissionStatus.granted) {
        scan = true;
      }
    } else if (Platform.isIOS) {
      scan = true;
    }

    devices.clear();
    subscription?.cancel();

    if (scan) {
      if (kDebugMode) {
        print('is scanning');
      }
      subscription = flutterReactiveBle.scanForDevices(
        //withServices: [hrmUuid, scaleUuid, bloodPressureUuid],
        withServices: [],
        scanMode: ScanMode.balanced,
      ).listen((device) {
        if (device.name.isNotEmpty) {
          int index = 0;
          while (index != device.serviceUuids.length) {
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
    deviceConnection = flutterReactiveBle
        .connectToDevice(
      id: device.id,
    ) //connectionTimeout: const Duration())
        .listen((update) {
      if (update.connectionState == DeviceConnectionState.connected) {
        isConnected = true;
        if (kDebugMode) {
          print('connected to device');
        }
      }

      if (update.connectionState == DeviceConnectionState.disconnected) {
        if (kDebugMode) {
          print('timed out');
        }
        isConnected = false;
      }
    });
  }

  disconnect() async {
    await deviceConnection?.cancel();
    deviceConnection = null;
    isConnected = false;
  }

  Future<List<DiscoveredService>?> findServices(String deviceId) async {
    try {
      final result = await flutterReactiveBle.discoverServices(deviceId);
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('error occurred: $e');
      }
    }
    return null;
  }
}
