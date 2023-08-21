import 'dart:async';
import 'bluetooth.dart';
import 'button_row.dart';
import 'package:bluetooth_health_app/permissions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class DevicePage extends StatefulWidget {
  const DevicePage({super.key, required this.title});
  final String title;

  @override
  State<StatefulWidget> createState() => _DevicePage();
} //DevicePage

class _DevicePage extends State<DevicePage> {
  String infoString =
      '\n\n\n     Click on the Device\nYou Want to Connect to\n\n';
  String associatedButtonText = 'Other Devices';
  bool isOnAssociated = true;
  Bluetooth bluetooth = Bluetooth();
  bool hasBluetoothEnabled = false;

  List<Widget> buttonWidgets = List.empty(growable: true);

  List<DiscoveredDevice> associatedDevices =
      List<DiscoveredDevice>.empty(growable: true);

  List<String> associatedDevicesIds = List<String>.empty(growable: true);
  List<String> devicesIds = List<String>.empty(growable: true);

  changeInfoString(String str) {
    setState(() {
      infoString = str;
    });
  }

  changeButtonText(String str) {
    setState(() {
      associatedButtonText = str;
    }); //setState
  } //changeButtonText

  updateIdStrings() {
    for (int i = 0; i < bluetooth.devices.length; i++) {
      devicesIds.add(bluetooth.devices.elementAt(i).id);
    }

    for (int i = 0; i < associatedDevices.length; i++) {
      associatedDevicesIds.add(associatedDevices.elementAt(i).id);
    }
  } //updateIdStrings

  Future<List<Widget>> createButtonList() async {
    Permissions permissions = Permissions();
    hasBluetoothEnabled = await permissions.hasBluetooth();

    if (hasBluetoothEnabled) {
      updateIdStrings();
      if (isOnAssociated) {
        if (associatedDevices.isEmpty) {
          setState(() {
            changeInfoString(
                '\n\n\nNo Associated Devices\n\nClick the search button\nto search for more Bluetooth devices\n');
          });
          return List.empty(growable: true);
        } else {
          List<Widget> buttonWidgets = List.empty(growable: true);

          for (int i = 0; i < associatedDevices.length; i++) {
            if (devicesIds.contains(associatedDevices.elementAt(i).id)) {
              setState(() {
                buttonWidgets.add(ButtonRow(
                  device: associatedDevices.elementAt(i),
                  bluetooth: bluetooth,
                  infoString: changeInfoString,
                  associatedDevices: associatedDevices,
                  isAssociated: isOnAssociated,
                ));
              });
            }
          }
          return buttonWidgets;
        }
      } else {
        if (bluetooth.devices.isEmpty) {
          setState(() {
            changeInfoString(
                '\n\n\nNo Devices Found\n\nClick the Search to\nFind More Devices\n');
          });
          return List.empty(growable: true);
        } else {
          List<Widget> buttonWidgets = List.empty(growable: true);

          for (int i = 0; i < bluetooth.devices.length; i++) {
            if (!associatedDevicesIds
                .contains(bluetooth.devices.elementAt(i).id)) {
              setState(() {
                buttonWidgets.add(ButtonRow(
                  bluetooth: bluetooth,
                  device: bluetooth.devices.elementAt(i),
                  infoString: changeInfoString,
                  associatedDevices: associatedDevices,
                  isAssociated: isOnAssociated,
                ));
              });
            }
          }
          changeInfoString(
              '\n\n\nClick on the Device\nYou Want to Connect to\n\n');
          return buttonWidgets;
        }
      }
    } else {
      changeInfoString('\n\n\nBluetooth Disabled\n\n');
      return List.empty(growable: true);
    }
  } //createButtonList

  @override
  Widget build(BuildContext context) {
    createButtonList().then((value) => buttonWidgets = value);

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: Column(
          children: [
            //logo
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                child: Image.asset('assets/images/logo.jpg'),
              ),
            ),

            //info text
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                child: Text(
                  infoString,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            //buttons
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: buttonWidgets,
              ),
            ),

            //scan button
            if (!isOnAssociated)
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey),
                      onPressed: () {
                        Permissions permissions = Permissions();

                        permissions.hasBluetooth().then((hasBluetooth) {
                          if (hasBluetooth) {
                            hasBluetoothEnabled = true;
                          } else {
                            hasBluetoothEnabled = false;
                          }
                        });

                        if (!hasBluetoothEnabled) {
                          changeInfoString('\n\n\nBluetooth Disconnected\n\n');
                        } else {
                          setState(
                            () {
                              bluetooth.devices.clear();
                              buttonWidgets.clear();

                              bluetooth.frbScan();
                              Future.delayed(const Duration(seconds: 4),
                                  () async {
                                setState(() {
                                  bluetooth.fbrEndScan();
                                });
                                buttonWidgets = await createButtonList();
                              });
                            },
                          );
                        }
                      },
                      child: const Text(
                        'Search',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  ],
                ),
              ),

            //see associated buttons
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    onPressed: () {
                      setState(() {
                        buttonWidgets.clear();
                        isOnAssociated = !isOnAssociated;
                        createButtonList()
                            .then((value) => buttonWidgets = value);
                        if (isOnAssociated) {
                          setState(() {
                            if (associatedDevices.isEmpty) {
                              changeInfoString(
                                  '\n\n\nNo Associated Devices Found\n\n');
                            } else {
                              changeInfoString(
                                  '\n\n\nClick on the Associated Device\n to Connect to it\n\n');
                            }
                            changeButtonText('Other Devices');
                          }); //setState
                        } else {
                          
                          setState(
                            () {
                              bluetooth.devices.clear();
                              buttonWidgets.clear();

                              bluetooth.frbScan();
                              Future.delayed(const Duration(seconds: 4),
                                  () async {
                                setState(() {
                                  bluetooth.fbrEndScan();
                                });
                                buttonWidgets = await createButtonList();
                              });
                            },
                          );

                          setState(() {
                            if (bluetooth.devices.isNotEmpty) {
                              changeInfoString(
                                  '\n\n\nClick on the Device you want to connect to\n\n');
                            } else {
                              changeInfoString('\n\n\nNo Devices Found\n\n');
                            }
                            changeButtonText('Associated Devices');
                          }); //setState
                        } //else
                      }); //setState
                    }, //on pressed
                    child: Text(
                      associatedButtonText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ], //children
        ),
      ),
    );
  } //build
} //_devicePage
