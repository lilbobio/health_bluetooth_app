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
  String services = '\n\nFinding Services...\n\n\n';
  late Timer everySecond;

  @override
  void initState() {
    findServices(widget.device, widget.bluetooth, services);
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
              child: Text(services),
            ),

            //disconnect button
            Align(
              alignment: Alignment.center,
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

  findServices(BluetoothDevice device, Bluetooth bluetooth, String info) {
    bluetooth.findServices(device).then((services) async {
      for (BluetoothService service in services) {
        String uuid = service.uuid.toString();
        uuid = uuid.substring(4, 8);
        if (uuid.compareTo(bluetooth.heartRateMonitorUUID) == 0) {
          if (kDebugMode) {
            print('connected to a heart monitor');
            print('service: $service');
            print(
                'number of characteristics: ${service.characteristics.length}');
            for (BluetoothCharacteristic c in service.characteristics) {
              if (c.properties.notify) {
                await c.setNotifyValue(true);
                c.value.listen((values) async {
                  if (kDebugMode) {
                    print('values: $values');
                    print('Heart Rate: ${findHeartRate(values).toInt()}');
                  }
                });
              }
            }
          }
        } else if (uuid.compareTo(bluetooth.scaleUUID) == 0) {
          if (kDebugMode) {
            print('connected to a scale');
          }
        }
      }
    });
  }

  //function derived from https://stackoverflow.com/questions/65443033/heart-rate-value-in-ble 
  int findHeartRate(List<int> values){
    if(values.isEmpty){
      return 0;
    }

    int flags = values[0];
    String flagStr = flags.toRadixString(2);
    List<String> flagsArray = flagStr.split("");

    //find if the heart rate is U8 or U16 from the flag
    if(flagsArray[0] == "0" || flagsArray.length <= 3){
      //U8
      return values[1];
    } else {
      //U16
      ByteBuffer buffer = Uint8List.fromList(values.sublist(1,3)).buffer;
      ByteData heartRateBuffer = ByteData.view(buffer);
      int heartRate = heartRateBuffer.getUint16(0, Endian.little);
      return heartRate;
    }
  }
}
