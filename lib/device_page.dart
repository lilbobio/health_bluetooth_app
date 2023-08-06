import 'dart:async';

import 'package:bluetooth_health_app/permissions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:loader_overlay/loader_overlay.dart';

import 'bluetooth.dart';
import 'button_row.dart';

class DevicePage extends StatefulWidget {
  const DevicePage({super.key, required this.title});
  final String title;

  @override
  State<StatefulWidget> createState() => _DevicePage();
}

class _DevicePage extends State<DevicePage> {
  String infoString =
      '\n\n\n     Click on the Device\nYou Want to Connect to\n\n';
  String associatedButtonText = 'Change to\n non-Associated Devices';
  bool isOnAssociated = true;
  Bluetooth bluetooth = Bluetooth();
  bool hasBluetoothEnabled = false;

  List<Widget> buttonWidgets = List.empty(growable: true);

  List<DiscoveredDevice> associatedDevices =
      List<DiscoveredDevice>.empty(growable: true);

  List<String> associatedDevicesIds = List<String>.empty(growable: true);
  List<String> devicesIds = List<String>.empty(growable: true);

  @override
  void initState() {
    super.initState();
    Permissions permissions = Permissions();

    permissions.hasBluetooth().then((hasBluetooth) {
      if (hasBluetooth) {
        hasBluetoothEnabled = true;
        setState(() {
          context.loaderOverlay.show();
          changeInfoString('\n\n\nScanning for devices...\n\n');
          bluetooth.frbScan();
          Future.delayed(const Duration(seconds: 4), () {
            bluetooth.fbrEndScan();
            context.loaderOverlay.hide();
            if (bluetooth.devices.isEmpty) {
              setState(() {
                changeInfoString('\n\n\nFound 0 Relevant Devices\n\n');
              });
            } else {
              setState(() {
                changeInfoString(
                    '\n\n\n     Click on the Device\nYou Want to Connect to\n\n');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DevicePage(title: widget.title),
                  ),
                ).then(onGoBack);
              });
            }
          });
        });
      } else {
        hasBluetoothEnabled = false;
        setState(() {
          changeInfoString('\n\n\nBluetooth Disabled\n\n');
        });
      }
    });
  }

  changeInfoString(String str) {
    setState(() {
      if (kDebugMode) {
        print('changing info string to: $str');
      }
      infoString = str;
    });
  }

  FutureOr onGoBack(dynamic value) {
    setState(() {
      if (kDebugMode) {
        print('refreshing page');
      }
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
            changeInfoString('\n\n\nFinding devices again...\n\n');
            context.loaderOverlay.show();
            bluetooth.devices.clear();
            buttonWidgets.clear();

            bluetooth.frbScan();
            Future.delayed(const Duration(seconds: 4), () {
              setState(() {
                bluetooth.fbrEndScan();
              });
              context.loaderOverlay.hide();
              buttonWidgets = createButtonList();
            });
          },
        );
      }
    });
  }

  changeButtonText(String str) {
    setState(() {
      associatedButtonText = str;
    });
  }

  updateIdStrings() {
    for (int i = 0; i < bluetooth.devices.length; i++) {
      devicesIds.add(bluetooth.devices.elementAt(i).id);
    }

    for (int i = 0; i < associatedDevices.length; i++) {
      associatedDevicesIds.add(associatedDevices.elementAt(i).id);
    }
  }

  List<Widget> createButtonList() {
    if (hasBluetoothEnabled) {
      updateIdStrings();
      if (isOnAssociated) {
        if (associatedDevices.isEmpty) {
          setState(() {
            changeInfoString('\n\n\nNo Associated Devices\n');
          });
          return List.empty(growable: true);
        } else {
          List<Widget> buttonWidgets = List.empty(growable: true);

          for (int i = 0; i < associatedDevices.length; i++) {
            if (devicesIds.contains(associatedDevices.elementAt(i).id)) {
              if (kDebugMode) {
                print('device $i: ${associatedDevices[i]}');
              }
              setState(() {
                buttonWidgets.add(ButtonRow(
                    device: associatedDevices.elementAt(i),
                    bluetooth: bluetooth,
                    infoString: changeInfoString,
                    associatedDevices: associatedDevices));
              });
            }
          }
          return buttonWidgets;
        }
      } else {
        if (bluetooth.devices.isEmpty) {
          setState(() {
            changeInfoString('\n\n\nNo Devices Found\n');
          });
          return List.empty(growable: true);
        } else {
          List<Widget> buttonWidgets = List.empty(growable: true);

          for (int i = 0; i < bluetooth.devices.length; i++) {
            if (!associatedDevicesIds
                .contains(bluetooth.devices.elementAt(i).id)) {
              if (kDebugMode) {
                print(
                    'associated devices is $isOnAssociated. device $i: ${bluetooth.devices[i]}');
              }
              setState(() {
                buttonWidgets.add(ButtonRow(
                  bluetooth: bluetooth,
                  device: bluetooth.devices.elementAt(i),
                  infoString: changeInfoString,
                  associatedDevices: associatedDevices,
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
  }

  List<Widget> changeFromAssociated() {
    return createButtonList();
  }

  @override
  Widget build(BuildContext context) {
    buttonWidgets = createButtonList();

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

            //see associated buttons
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        textStyle: const TextStyle(fontSize: 20)),
                    onPressed: () {
                      setState(() {
                        buttonWidgets.clear();
                        isOnAssociated = !isOnAssociated;
                        buttonWidgets = changeFromAssociated();
                        if (isOnAssociated) {
                          setState(() {
                            if (associatedDevices.isEmpty) {
                              changeInfoString(
                                  '\n\n\nNo Associated Devices Found\n\n');
                            } else {
                              changeInfoString(
                                  '\n\n\nClick on the Associated Device\n to Connect to it\n\n');
                            }
                            changeButtonText(
                                'Change to\n non-Associated Devices');
                          });
                        } else {
                          setState(() {
                            if (bluetooth.devices.isNotEmpty) {
                              changeInfoString(
                                  '\n\n\nClick on the Device you want to connect to\n\n');
                            } else {
                              changeInfoString('\n\n\nNo Devices Found\n\n');
                            }
                            changeButtonText('Change to\n Associated Devices');
                          });
                        }
                      });
                    },
                    child: Text(
                      associatedButtonText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            //scan button
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FloatingActionButton(
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
                            context.loaderOverlay.show();
                            bluetooth.devices.clear();
                            buttonWidgets.clear();

                            bluetooth.frbScan();
                            Future.delayed(const Duration(seconds: 4), () {
                              setState(() {
                                bluetooth.fbrEndScan();
                              });
                              context.loaderOverlay.hide();
                              buttonWidgets = createButtonList();
                            });
                          },
                        );
                      }
                    },
                    heroTag: null,
                    child: const Icon(Icons.search),
                  )
                ],
              ),
            ),
          ], //children
        ),
      ),
    );
  }
}
