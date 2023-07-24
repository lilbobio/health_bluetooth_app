import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'bluetooth.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'button_row.dart';

class DevicePage extends StatefulWidget {
  const DevicePage(
      {super.key,
      required this.devices,
      required this.bluetooth,
      required this.title});
  final List<BluetoothDevice> devices;
  final Bluetooth bluetooth;
  final String title;

  @override
  State<StatefulWidget> createState() => _DevicePage();
}

class _DevicePage extends State<DevicePage> {
  String infoString =
      '\n\n\n     Click on the Device\nYou Want to Connect to\n\n';
  bool isOnAssociated = true;

  List<BluetoothDevice> associatedDevices =
      List<BluetoothDevice>.empty(growable: true);

  changeInfoString(String str) {
    setState(() {
      if (kDebugMode) {
        print('changing info string to: $str');
      }
      infoString = str;
    });
  }

  List<Widget> createButtonList(int buttonCount, int associatedCount) {
    if (isOnAssociated) {
      if (associatedDevices.isEmpty) {
        setState(() {
          infoString = '\n\n\n     No Associated Devices\n';
        });
        return List.empty();
      } else {
        List<Widget> buttonWidgets = List.filled(
          associatedCount,
          ButtonRow(
            bluetooth: widget.bluetooth,
            device: associatedDevices.elementAt(0),
            infoString: changeInfoString,
            associatedDevices: associatedDevices,
          ),
          growable: true,
        );

        for (int i = 0; i < associatedDevices.length; i++) {
          if (kDebugMode) {
            print('device $i: ${associatedDevices[i]}');
          }
          setState(() {
            buttonWidgets[i] = ButtonRow(
                device: associatedDevices.elementAt(i),
                bluetooth: widget.bluetooth,
                infoString: changeInfoString,
                associatedDevices: associatedDevices);
          });
        }
        return buttonWidgets;
      }
    } else {
      if (widget.devices.isEmpty) {
        setState(() {
          infoString = '\n\n\n     No Devices Found\n';
        });
        return List.empty();
      } else {
        List<Widget> buttonWidgets = List.filled(
          buttonCount - associatedCount,
          ButtonRow(
            bluetooth: widget.bluetooth,
            device: widget.devices.elementAt(0),
            infoString: changeInfoString,
            associatedDevices: associatedDevices,
          ),
          growable: true,
        );

        for (int i = 0; i < widget.devices.length; i++) {
          if (kDebugMode) {
            print('device $i: ${widget.devices[i]}');
          }
          setState(() {
            buttonWidgets[i] = ButtonRow(
              bluetooth: widget.bluetooth,
              device: widget.devices.elementAt(i),
              infoString: changeInfoString,
              associatedDevices: associatedDevices,
            );
          });
        }
        infoString =
            '\n\n\n     Click on the Device\nYou Want to Connect to\n\n';
        return buttonWidgets;
      }
    }
  }

  Widget loadingScreen() {
    return const Opacity(
      opacity: 0.2,
      child: Align(
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Opacity(
              opacity: 1,
              child: Column(children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: CircularProgressIndicator(),
                ),
                SizedBox(
                  height: 12,
                ),
                Text(
                  'Finding new Devices...',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w700,
                  ),
                )
              ]),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> changeFromAssociated(int buttonCount, int associatedCount) {
    return createButtonList(buttonCount, associatedCount);
  }

  @override
  Widget build(BuildContext context) {
    int buttonCount = widget.devices.length;
    String associatedButtonText = 'Change to\n non-Associated Devices';

    List<Widget> buttonWidgets =
        createButtonList(buttonCount, associatedDevices.length);

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
                        if (kDebugMode) {
                          print('isOnAssociated: $isOnAssociated');
                        }
                        buttonWidgets.clear();
                        isOnAssociated = !isOnAssociated;
                        buttonWidgets = changeFromAssociated(
                            widget.devices.length, associatedDevices.length);
                        if (kDebugMode) {
                          print('isOnAssociated: $isOnAssociated');
                        }
                        if (isOnAssociated) {
                          associatedButtonText =
                              'Change to\n non-Associated Devices';
                        } else {
                          associatedButtonText =
                              'Change to\n Associated Devices';
                        }
                      });
                    },
                    child: Text(
                      associatedButtonText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18.0,
                        backgroundColor: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            //scan button
            Align(
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FloatingActionButton(
                    onPressed: () {
                      setState(
                        () {
                          infoString = '\n\n\nFinding devices again...\n\n';
                          context.loaderOverlay.show();
                          widget.devices.clear();
                          buttonWidgets.clear();
                          buttonCount = 0;
                          widget.bluetooth.scan(4);
                          Future.delayed(const Duration(seconds: 4), () {
                            setState(() {
                              for (int i = 0;
                                  i < widget.bluetooth.scanResultList.length;
                                  i++) {
                                BluetoothDevice bluetoothDevice = widget
                                    .bluetooth.scanResultList
                                    .elementAt(i)
                                    .device;
                                if (bluetoothDevice.name.compareTo("") != 0) {
                                  widget.devices.add(bluetoothDevice);
                                  buttonCount++;
                                }
                              }
                            });
                            context.loaderOverlay.hide();
                            buttonWidgets = createButtonList(
                                buttonCount, associatedDevices.length);
                          });
                        },
                      );
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