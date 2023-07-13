import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'bluetooth.dart';
import 'package:flutter_blue/flutter_blue.dart';

class ConnectedPage extends StatefulWidget {
  const ConnectedPage(
      {super.key,
      required this.title,
      required this.bluetooth,
      required this.device});

  final String title;
  final Bluetooth bluetooth;
  final BluetoothDevice device;

  @override
  State<ConnectedPage> createState() => _ConnectedPageState();
}

class _ConnectedPageState extends State<ConnectedPage> {
  String servicesText = '\n\nFinding Services...\n\n\n';
  late Timer everySecond;
  changeInfoString(String str) {
    setState(() {
      servicesText = str;
    });
  }

  @override
  void initState() {
    findServices(widget.device, widget.bluetooth, changeInfoString);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
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
                '\n\n\nConnected to ${widget.device.name}\n\n',
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

            //disconnect button
            Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 20)),
                onPressed: () {
                  setState(() {
                    widget.bluetooth.disconnect(widget.device);
                    Navigator.pop(context);
                    Navigator.pop(context);
                  });
                },
                child: Text(
                  'Disconnect from ${widget.title}',
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
      BluetoothDevice device, Bluetooth bluetooth, Function(String str) info) {
    bluetooth.findServices(device).then((services) async {
      for (BluetoothService service in services) {
        String uuid = service.uuid.toString();
        uuid = uuid.substring(4, 8);
        if (uuid.compareTo(bluetooth.heartRateMonitorUUID) == 0) {
          if (kDebugMode) {
            print('connected to a heart monitor');
          }
          heartRateMonitor(service, info);
        } else if (uuid.compareTo(bluetooth.scaleUUID) == 0) {
          if (kDebugMode) {
            print('connected to a scale');
          }
          scale(service, info);
        }
      }
    });
  }

  heartRateMonitor(BluetoothService service, Function(String str) info) async {
    for (BluetoothCharacteristic c in service.characteristics) {
      if (c.properties.notify) {
        await c.setNotifyValue(true);
        c.value.listen((values) async {
          setState(() {
            info('Heart Rate is:\n\n ${findHeartRate(values)}\n\n\n\n\n');
          });
        });
      }
    }
  }

  scale(BluetoothService service, Function(String str) info) async {
    for(BluetoothCharacteristic c in service.characteristics){
      if(c.properties.notify) {
        await c.setNotifyValue(true);
        c.value.listen((values) {
          setState(() {
            info('Weight is:\n\n ${findWeight(values)}\n\n\n\n');
          });
        });
      }
    }
  }

  int findWeight(List<int> values){
    if(values.isEmpty) {
      return 0;
    }
    int weight = 0;
    return weight;
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
