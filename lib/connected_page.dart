import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import 'bluetooth.dart';

class ConnectedPage extends StatefulWidget {
  const ConnectedPage(
      {super.key,
      required this.title,
      required this.bluetooth,
      required this.device,
      required this.isAssociated});

  final String title;
  final Bluetooth bluetooth;
  final DiscoveredDevice device;
  final bool isAssociated;

  @override
  State<ConnectedPage> createState() => _ConnectedPageState();
}

class _ConnectedPageState extends State<ConnectedPage> {
  String servicesText = '\n\nConnecting to Device...\n\n\n';
  late Timer everySecond;
  int isFirstConnect = 0;
  String title = 'Connected';
  String infoText = '';
  bool showPlusButton = false;

  changeInfoString(String str) {
    setState(() {
      servicesText = str;
    });
  }

  @override
  void initState() {
    super.initState();
    infoText = '\n${widget.device.name}';
    if (kDebugMode) {
      print('isConnected: ${widget.bluetooth.isConnected}');
    }

    widget.bluetooth.deviceConnection?.onData((data) {
      if (kDebugMode) {
        print('data: $data\ndata[0]');
      }

      if (data.toString().contains('DeviceConnectionState.connected')) {
        setState(() {
          showPlusButton = true;
        });
        if (!widget.device.name.contains('A&D') || widget.isAssociated) {
          findServices(widget.device, widget.bluetooth, changeInfoString);
        } else {
          setState(() {
            changeInfoString('\n\n\nPress the plus button to pair device\n\n');
          });
        }
      }

      if(data.toString().contains('DeviceConnectionState.disconnected')) {
        widget.bluetooth.disconnect();
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          //MIE Logo
          Align(
            alignment: Alignment.center,
            child: Image.asset('assets/images/logo.jpg'),
          ),
        ],
        title: Text(title),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
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

            //get scale weight button
            if (widget.device.name.contains('A&D') &&
                (isFirstConnect == 0 || isFirstConnect == 1) &&
                !widget.isAssociated &&
                showPlusButton)
              Align(
                alignment: Alignment.bottomCenter,
                child: FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      if (kDebugMode) {
                        print('implement this button ');
                      }

                      if (isFirstConnect == 0) {
                        if (kDebugMode) {
                          print('in first connect');
                        }
                        isFirstConnect = 1;
                        addButton();
                      } else {
                        if (kDebugMode) {
                          print('in second connect');
                        }
                        isFirstConnect = 2;
                        findServices(
                            widget.device, widget.bluetooth, changeInfoString);
                      }
                    }); //setState
                  }, //onPressed
                  heroTag: null,
                  child: const Icon(Icons.add),
                ),
              ),

            //save value button
            if (!(widget.device.name.contains('A&D') &&
                (isFirstConnect == 0 || isFirstConnect == 1) &&
                !widget.isAssociated))
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
                child: const Text(
                  'Disconnect',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
              ),
            ),
          ], //children
        ),
      ),
    );
  }

  addButton() {
    widget.bluetooth.findServices(widget.device.id).then((services) async {
      for (DiscoveredService service in services!) {
        String serviceUUIDString = service.serviceId.toString().substring(4, 8);

        if (serviceUUIDString.compareTo('4100') == 0) {
          if (kDebugMode) {
            print('in Weight Scale Service: 0x4100');
            print('service: $service');
          }

          final dateTime = QualifiedCharacteristic(
              characteristicId: service.characteristics.last.characteristicId,
              serviceId: service.serviceId,
              deviceId: widget.device.id);

          final responseBefore = await widget.bluetooth.flutterReactiveBle
              .readCharacteristic(dateTime);

          if (kDebugMode) {
            print('before write: $responseBefore');
          }

          DateTime currentDate = DateTime.now();
          int year = currentDate.year;
          int month = currentDate.month;
          int day = currentDate.day;
          int hour = currentDate.hour;
          int minute = currentDate.minute;
          int second = currentDate.second;
          String yearHexString = year.toRadixString(16);
          while (yearHexString.length < 4) {
            yearHexString = '0$yearHexString';
          }

          String year1 = yearHexString.substring(2, 4);
          String year2 = yearHexString.substring(0, 2);

          int year1Int = int.parse(year1, radix: 16);
          int year2Int = int.parse(year2, radix: 16);

          if (kDebugMode) {
            print(
                'hex: $yearHexString\ndate: $year $month $day $hour:$minute:$second');
          }

          await widget.bluetooth.flutterReactiveBle
              .writeCharacteristicWithResponse(dateTime, value: [
            year1Int,
            year2Int,
            month,
            day,
            hour,
            minute,
            second
          ]);

          final response = await widget.bluetooth.flutterReactiveBle
              .readCharacteristic(dateTime);
          if (kDebugMode) {
            print('after write: $response');
          }
        }
      }
      changeInfoString(
          '\n\nDevice Paired\nStep on Scale and\nget weight\n Press the plus button\nto record weight\n');
      widget.bluetooth.disconnect();
    });
  }

  findServices(
      DiscoveredDevice device, Bluetooth bluetooth, Function(String str) info) {
    bluetooth.findServices(device.id).then((services) async {
      if (services == null) {
        return;
      }
      setState(() {
        info('\n\nFinding Services...\n\n\n\n\n');
        //infoText = '\n\n\nConnecting to ${widget.device.name}\n\n';
      });
      for (DiscoveredService service in services) {
        String serviceUUIDString = service.serviceId.toString().substring(4, 8);
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
                info('\n\n\nHeart Rate is: \n\n ${findHeartRate(data)}\n\n\n');
              });
            }
          }, onError: (dynamic error) {
            if (kDebugMode) {
              print(error);
            }
          });
        } else if (serviceUUIDString
                .compareTo(bluetooth.bloodPressureUUIDString) ==
            0) {
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
                info(
                    '\n\n\nBlood Pressure is: \n\n ${findBloodPressure(data)}\n\n\n');
              });
            }
          }, onError: (dynamic error) {
            if (kDebugMode) {
              print(error);
            }
          });
        } else if (serviceUUIDString.compareTo(bluetooth.scaleUUIDString) ==
            0) {
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
                info('\n\n\nWeight is: \n\n ${findWeight(data)}\n\n');
              });
            }
          });
        } else if (serviceUUIDString.compareTo(bluetooth.andScaleUuidString) ==
            0) {
          final characteristic = QualifiedCharacteristic(
              characteristicId: service.characteristicIds.first,
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
                info('\n\n\nWeight is: \n\n ${findWeightAnd(data)}\n\n\n');
              });
            }
          });
        } else if (serviceUUIDString.compareTo(bluetooth.microLifeUuidString) ==
            0) {
          final characteristic = QualifiedCharacteristic(
              characteristicId: service.characteristicIds.last,
              serviceId: service.serviceId,
              deviceId: device.id);

          bluetooth.flutterReactiveBle
              .subscribeToCharacteristic(characteristic)
              .listen((data) {
            if (kDebugMode) {
              print(data);
            }
          });
        } else {
          if (kDebugMode) {
            print('service: $service');
          }
        } //else
      } //for
    }); //then
  } //findServices

  //got inspiration from https://stackoverflow.com/questions/68233478/flutter-ble-read-weight-scale-characteristic-value
  String findWeightAnd(List<int> values) {
    String returnStr = 'ERROR';
    if (values.isEmpty) {
      return returnStr;
    }

    if (values[1] == 0x00 && values[2] == 0x00) {
      return returnStr;
    }

    int flags = values[0];

    double weight = ((0xff & values[2]) << 8 | (0xff & values[1]) << 0) / 10;

    if (kDebugMode) {
      print('weight is $weight');
    }

    switch (flags) {
      case 0:
        if (kDebugMode) {
          print('SI no timestamp');
        }
        returnStr = '$weight Kgs';
        break;
      case 1:
        if (kDebugMode) {
          print('lbs no time stamp');
        }
        returnStr = '$weight lbs';
        break;
      case 2:
        if (kDebugMode) {
          print('SI time stamp');
        }
        int year1 = values[4];
        int year2 = values[3];

        String hexYear1 = year1.toRadixString(16);
        String hexYear2 = year2.toRadixString(16);
        String hexYear = '$hexYear1$hexYear2';

        int year = int.parse(hexYear, radix: 16);
        int month = values[5];
        int day = values[6];
        int hour = values[7];
        int minute = values[8];
        int second = values[9];
        returnStr =
            '$weight Kgs\n Date: $year.$month.$day $hour:$minute:$second';
        break;
      default:
        if (kDebugMode) {
          print('lbs timestamp');
        }

        int year1 = values[4];
        int year2 = values[3];

        String hexYear1 = year1.toRadixString(16);
        String hexYear2 = year2.toRadixString(16);
        String hexYear = '$hexYear1$hexYear2';

        int year = int.parse(hexYear, radix: 16);
        int month = values[5];
        int day = values[6];
        int hour = values[7];
        int minute = values[8];
        int second = values[9];
        returnStr =
            '$weight lbs\n\nDate:\n$year.$month.$day $hour:$minute:$second';
    }
    return returnStr;
  }

  //this function is untested due to lack of equipment
  String findWeight(List<int> values) {
    String returnStr = '0 lbs';

    if (values.isEmpty) {
      return returnStr;
    }

    int flags = values[0];
    String flagStr = flags.toRadixString(2);

    List<String> flagsArray = flagStr.split("");
    while (flagsArray.length < 8) {
      flagsArray.insert(0, "0");
    }

    if (values.length >= 3) {
      int weightPart1 = values[1];
      String weightP1Str = weightPart1.toRadixString(2);
      List<String> weightP1Array = weightP1Str.split("");

      int weightPart2 = values[2];
      String weightP2Str = weightPart2.toRadixString(2);
      List<String> weightP2Array = weightP2Str.split("");

      while (weightP2Array.length < 8) {
        weightP2Array.insert(0, "0");
      }

      while (weightP1Array.length < 8) {
        weightP1Array.insert(0, "0");
      }

      List<int> weightList = List<int>.filled(16, 0);
      for (int i = 0; i < 8; i++) {
        weightList[i] = int.parse(weightP1Array[i]);
      }
      for (int i = 0; i < 8; i++) {
        weightList[i + 8] = int.parse(weightP2Array[i]);
      }

      if (kDebugMode) {
        print('weight list is: $weightList');
      }

      ByteBuffer buffer = Uint16List.fromList(weightList).buffer;
      ByteData weightBuffer = ByteData.view(buffer);
      int weight = weightBuffer.getInt16(0, Endian.little);

      if (kDebugMode) {
        print('weight is $weight');
      }

      if (flagsArray[7] == "0") {
        returnStr = '$weight Kgs';
      } else {
        returnStr = '$weight lbs';
      }
    }

    return returnStr;
  }

  //this function is untested due to lack of equipment
  String findBloodPressure(List<int> values) {
    if (values.isEmpty) {
      return "0 kPa";
    }

    String returnStr = '0 kPa';

    int flags = values[0];
    String flagStr = flags.toRadixString(2);

    List<String> flagsArray = flagStr.split("");
    while (flagsArray.length < 8) {
      flagsArray.insert(0, "0");
    }

    if (values.length >= 3) {
      ByteBuffer buffer = Uint8List.fromList(values.sublist(1, 3)).buffer;
      ByteData bloodPressureBuffer = ByteData.view(buffer);
      int bloodPressure = bloodPressureBuffer.getInt16(0, Endian.little);

      if (flagsArray[0] == "0") {
        returnStr = '$bloodPressure mmHg';
      } else {
        returnStr = '$bloodPressure kPa';
      }
    }
    return returnStr;
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
      ByteBuffer buffer = Uint8List.fromList(values.sublist(1, 3)).buffer;
      ByteData heartRateBuffer = ByteData.view(buffer);
      int heartRate = heartRateBuffer.getUint16(0, Endian.little);
      return heartRate;
    }
  }
}
