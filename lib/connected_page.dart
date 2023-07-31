import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'bluetooth.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class ConnectedPage extends StatefulWidget {
  const ConnectedPage(
      {super.key,
      required this.title,
      required this.bluetooth,
      required this.device});

  final String title;
  final Bluetooth bluetooth;
  final DiscoveredDevice device;

  @override
  State<ConnectedPage> createState() => _ConnectedPageState();
}

class _ConnectedPageState extends State<ConnectedPage> {
  String servicesText = '\n\nConnecting to Device...\n\n\n';
  String infoText = '';
  late Timer everySecond;
  changeInfoString(String str) {
    setState(() {
      servicesText = str;
    });
  }

  @override
  void initState() {
    super.initState();
    infoText = '\n\n\nConnecting to ${widget.device.name}\n\n';
    findServices(widget.device, widget.bluetooth, changeInfoString);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            //MIE Logo
            Align(
              alignment: Alignment.center,
              child: Image.asset('assets/images/logo.jpg'),
            ),

            //Name of device
            Align(
              alignment: Alignment.center,
              child: Text(
                infoText,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20),
              ),
            ),

            //find services text
            Align(
              alignment: Alignment.center,
              child: Text(
                servicesText,
                style:
                    const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 20)),
                onPressed: () {
                  if (kDebugMode) {
                    print('wanted to save value\n will implement later');
                  }
                },
                child: const Text(
                  'Save Value',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
              ),
            ),

            //disconnect button
            Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 20)),
                onPressed: () {
                  setState(() {
                    widget.bluetooth.disconnect();
                    Navigator.pop(context, true);
                  });
                },
                child: Text(
                  'Disconnect from ${widget.title}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  findServices(
      DiscoveredDevice device, Bluetooth bluetooth, Function(String str) info) {
    bluetooth.findServices(device.id).then((services) async {
      setState(() {
        info('\n\nFinding Services...\n\n\n\n\n');
        infoText = '\n\n\nConnecting to ${widget.device.name}\n\n';
      });
      for (DiscoveredService service in services) {
        String serviceUUIDString = service.serviceId.toString().substring(4, 8);
        if (kDebugMode) {
          print('UUID: ${service.serviceId}');
          print('UUID String: $serviceUUIDString');
          print('Service characteristics Ids ${service.characteristicIds}');
          print('service characteristics ${service.characteristics}');
          print('hrm UUID: ${bluetooth.hrmUuid}');
          print('');
        }
        if (serviceUUIDString.compareTo(bluetooth.heartRateMonitorUUIDString) ==
            0) {
          if (kDebugMode) {
            print('connecting to: ${service.serviceId}');
          }
          final characteristic = QualifiedCharacteristic(
              characteristicId:
                  service.characteristics.elementAt(0).characteristicId,
              serviceId: service.serviceId,
              deviceId: device.id);
          bluetooth.flutterReactiveBle
              .subscribeToCharacteristic(characteristic)
              .listen((data) {
            if (kDebugMode) {
              print(data);
            }
            if (mounted) {
              setState(() {
                info('Heart Rate is: \n\n ${findHeartRate(data)}\n\n\n\n');
                infoText = '\n\n\nConnected to ${widget.device.name}\n';
              });
            }
          }, onError: (dynamic error) {
            if (kDebugMode) {
              print(error);
            }
          });
        }
      }
    });
  }

  int findWeight(List<int> values, List<String> flagsArray) {
    int weightPart1 = values[1];
    String weightP1Str = weightPart1.toRadixString(2);
    List<String> weightP1Array = weightP1Str.split("");

    int weightPart2 = values[2];
    String weightP2Str = weightPart2.toRadixString(2);
    List<String> weightP2Array = weightP2Str.split("");

    while (weightP2Array.length < 16) {
      weightP1Array.insert(0, "0");
      weightP2Array.insert(0, "0");
    }

    List<int> weightList = List<int>.filled(32, 0);
    for (int i = 0; i < 16; i++) {
      weightList[i] = int.parse(weightP1Array[i]);
    }
    for (int i = 0; i < 16; i++) {
      weightList[i + 16] = int.parse(weightP2Array[i]);
    }

    ByteBuffer buffer = Uint32List.fromList(weightList).buffer;
    ByteData weightBuffer = ByteData.view(buffer);
    int weight = weightBuffer.getInt32(0, Endian.little);
    return weight;
  }

  //TODO: Finish this function
  int findBloodPressure(List<int> values, List<String> flagsArray) {
    if (values.isEmpty) {
      return 0;
    }

    while (flagsArray.length < 4) {
      flagsArray.insert(0, "0");
    }

    return 0;
  }

  //function derived from https://stackoverflow.com/questions/65443033/heart-rate-value-in-ble
  int findHeartRate(List<int> values) {
    if (values.isEmpty) {
      return 0;
    }

    int flags = values[0];
    String flagStr = flags.toRadixString(2);

    List<String> flagsArray = flagStr.split("");
    while (flagsArray.length < 8) {
      flagsArray.insert(0, "0");
    }

    //find if the heart rate is U8 or U16 from the flag
    if (flagsArray[0] == "0" || values.length < 3) {
      //U8
      return values.elementAt(1);
    } else {
      //U16
      if (kDebugMode) {
        print('in else');
      }
      ByteBuffer buffer = Uint8List.fromList(values.sublist(1, 3)).buffer;
      ByteData heartRateBuffer = ByteData.view(buffer);
      int heartRate = heartRateBuffer.getUint16(0, Endian.little);
      return heartRate;
    }
  }
}
