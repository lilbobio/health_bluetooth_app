import 'package:bluetooth_health_app/connected_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'bluetooth.dart';
import 'package:flutter_blue/flutter_blue.dart';

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

  changeInfoString(String str) {
    setState(() {
      if (kDebugMode) {
        print('changing info string to: $str');
      }
      infoString = str;
    });
  }

  List<Widget> createButtonList(int buttonCount) {
    if (widget.devices.isEmpty) {
      //infoString = '\n\n\n     No Devices Found\n';
      return List.empty();
    } else {
      List<Widget> buttonWidgets = List.filled(
        buttonCount,
        ButtonRow(
          bluetooth: widget.bluetooth,
          device: widget.devices.elementAt(0),
          infoString: changeInfoString,
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
          );
        });
      }
      infoString = '\n\n\n     Click on the Device\nYou Want to Connect to\n\n';
      return buttonWidgets;
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
                child: Column(
                  children: [
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
                  ],
                )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int buttonCount = widget.devices.length;

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
  const ButtonRow(
      {super.key,
      required this.device,
      required this.bluetooth,
      required this.infoString});
  final BluetoothDevice device;
  final Bluetooth bluetooth;
  final Function(String str) infoString;

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

  deviceConnectButtonPressed(BluetoothDevice device) {
    setState(() {
      if (kDebugMode) {
        print('in first scanButton\n');
      }
    });

    widget.infoString('\n\n\nconnecting to ${device.name}...\n\n\n');
    context.loaderOverlay.show();
    if (kDebugMode) {
      print('is visible: ${context.loaderOverlay.visible}\n');
    }
    widget.bluetooth.connect(device).then((value) {
      if (kDebugMode) {
        print('${device.name} is connected\n');
      }
      setState(() {
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
    });
  }
}
