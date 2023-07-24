import 'package:bluetooth_health_app/connected_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'bluetooth.dart';
import 'package:flutter_blue/flutter_blue.dart';

class ButtonRow extends StatefulWidget {
  const ButtonRow(
      {super.key,
      required this.device,
      required this.bluetooth,
      required this.infoString,
      required this.associatedDevices});
  final BluetoothDevice device;
  final Bluetooth bluetooth;
  final Function(String str) infoString;
  final List<BluetoothDevice> associatedDevices;

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
    if (kDebugMode) {
      print('in first scanButton\n');
    }

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
        widget.associatedDevices.add(device);
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
