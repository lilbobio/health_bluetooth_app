import 'package:bluetooth_health_app/connected_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:loader_overlay/loader_overlay.dart';

import 'bluetooth.dart';

class ButtonRow extends StatefulWidget {
  const ButtonRow(
      {super.key,
      required this.device,
      required this.bluetooth,
      required this.infoString,
      required this.associatedDevices});
  final DiscoveredDevice device;
  final Bluetooth bluetooth;
  final Function(String str) infoString;
  final List<DiscoveredDevice> associatedDevices;

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
              textAlign: TextAlign.center,
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
      if (!widget.associatedDevices.contains(device)) {
        widget.associatedDevices.add(device);
      }
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
