import 'package:bluetooth_health_app/connected_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'bluetooth.dart';
import 'package:flutter_blue/flutter_blue.dart';
//import 'button_row.dart';

class DevicePage extends StatefulWidget {
  const DevicePage({super.key, required this.bluetooth, required this.title});
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

  List<Widget> createButtonList(int buttonCount) {
    // if (isOnAssociated) {
    //   if (associatedDevices.isEmpty) {
    //     setState(() {
    //       infoString = '\n\n\n     No Associated Devices\n';
    //     });
    //     return List.empty();
    //   } else {
    //     List<Widget> buttonWidgets = List.filled(
    //       associatedCount,
    //       ButtonRow(
    //         bluetooth: widget.bluetooth,
    //         device: associatedDevices.elementAt(0),
    //         infoString: changeInfoString,
    //         associatedDevices: associatedDevices,
    //       ),
    //       growable: true,
    //     );

    //     for (int i = 0; i < associatedDevices.length; i++) {
    //       if (kDebugMode) {
    //         print('device $i: ${associatedDevices[i]}');
    //       }
    //       setState(() {
    //         buttonWidgets[i] = ButtonRow(
    //             device: associatedDevices.elementAt(i),
    //             bluetooth: widget.bluetooth,
    //             infoString: changeInfoString,
    //             associatedDevices: associatedDevices);
    //       });
    //     }
    //     return buttonWidgets;
    //   }
    // } else {
    if (widget.bluetooth.devices.isEmpty) {
      setState(() {
        infoString = '\n\n\n     No Devices Found\n';
      });
      return List.empty(growable: true);
    } else {
      List<Widget> buttonWidgets = List.filled(
        buttonCount,
        ButtonRow(
          bluetooth: widget.bluetooth,
          device: widget.bluetooth.devices.elementAt(0),
          infoString: changeInfoString,
        ),
        growable: true,
      );

      for (int i = 0; i < widget.bluetooth.devices.length; i++) {
        if (kDebugMode) {
          print('device $i: ${widget.bluetooth.devices[i]}');
        }
        setState(() {
          buttonWidgets[i] = ButtonRow(
            bluetooth: widget.bluetooth,
            device: widget.bluetooth.devices.elementAt(i),
            infoString: changeInfoString,
          );
        });
      }
      infoString = '\n\n\n     Click on the Device\nYou Want to Connect to\n\n';
      return buttonWidgets;
      //  }
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

  // List<Widget> changeFromAssociated(int buttonCount, int associatedCount) {
  //   return createButtonList(buttonCount, associatedCount);
  // }

  @override
  Widget build(BuildContext context) {
    int buttonCount = widget.bluetooth.devices.length;
    //String associatedButtonText = 'Change to\n non-Associated Devices';

    List<Widget> buttonWidgets = createButtonList(buttonCount);

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
            // Align(
            //   alignment: Alignment.center,
            //   child: Column(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: <Widget>[
            //       ElevatedButton(
            //         style: ElevatedButton.styleFrom(
            //             backgroundColor: Colors.blue,
            //             textStyle: const TextStyle(fontSize: 20)),
            //         onPressed: () {
            //           setState(() {
            //             if (kDebugMode) {
            //               print('isOnAssociated: $isOnAssociated');
            //             }
            //             buttonWidgets.clear();
            //             isOnAssociated = !isOnAssociated;
            //             buttonWidgets = changeFromAssociated(
            //                 widget.devices.length, associatedDevices.length);
            //             if (kDebugMode) {
            //               print('isOnAssociated: $isOnAssociated');
            //             }
            //             if (isOnAssociated) {
            //               associatedButtonText =
            //                   'Change to\n non-Associated Devices';
            //             } else {
            //               associatedButtonText =
            //                   'Change to\n Associated Devices';
            //             }
            //           });
            //         },
            //         child: Text(
            //           associatedButtonText,
            //           textAlign: TextAlign.center,
            //           style: const TextStyle(
            //             fontSize: 18.0,
            //             backgroundColor: Colors.blue,
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),

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
                          widget.bluetooth.devices.clear();
                          buttonWidgets.clear();
                          buttonCount = 0;
                          widget.bluetooth.frbScan();
                          Future.delayed(const Duration(seconds: 4), () {
                            setState(() {
                              widget.bluetooth.fbrEndScan();
                            });
                            context.loaderOverlay.hide();
                            buttonWidgets = createButtonList(buttonCount);
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

class ButtonRow extends StatefulWidget {
  const ButtonRow({
    super.key,
    required this.device,
    required this.bluetooth,
    required this.infoString,
    // required this.associatedDevices
  });
  final DiscoveredDevice device;
  final Bluetooth bluetooth;
  final Function(String str) infoString;
  // final List<DiscoveredDevice> associatedDevices;

  @override
  State<StatefulWidget> createState() => _ButtonRow();
}

class _ButtonRow extends State<ButtonRow> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170.0,
      child: Column(
        children: <Widget>[
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                textStyle: const TextStyle(fontSize: 20)),
            onPressed: () {
              setState(() {
                widget.infoString('\n\n\nConnecting to\n${widget.device}\n\n');
                deviceConnectButtonPressed(widget.device);
              });
            },
            child: Text(
              widget.device.name,
              style: const TextStyle(
                fontSize: 18.0,
              ),
            ),
          )
        ],
      ),
    );
  }

  deviceConnectButtonPressed(DiscoveredDevice device) {
    setState(() {
      if (kDebugMode) {
        print('in first scanButton\n');
      }

      widget.infoString('\n\n\nconnecting to ${device.name}...\n\n\n');
      context.loaderOverlay.show();
      if (kDebugMode) {
        print('is visible: ${context.loaderOverlay.visible}\n');
      }
      widget.bluetooth.connect(device);

    });

    setState(() {
      // widget.associatedDevices.add(device);
      context.loaderOverlay.hide();
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: ((context) => ConnectedPage(
                  bluetooth: widget.bluetooth,
                  title: device.name,
                  device: device,
                )),
          ));
    });
  }
}
