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
  int _buttonCount = 1;

  changeInfoString(String str) {
    setState(() {
      infoString = str;
    });
  }

  @override
  Widget build(BuildContext context) {
    int buttonCount = widget.devices.length;

    List<Widget> buttonWidgets2 = List.generate(
      _buttonCount,
      (int i) => ButtonRow(
          device: widget.devices.elementAt(0),
          bluetooth: widget.bluetooth,
          infoString: changeInfoString),
    );

    List<Widget> buttonWidgets = List.filled(
      buttonCount,
      ButtonRow(
        bluetooth: widget.bluetooth,
        device: widget.devices.elementAt(0),
        infoString: changeInfoString,
      ),
    );

    for (int i = 1; i < widget.devices.length; i++) {
      _buttonCount++;
      setState(() {
        buttonWidgets2.add(ButtonRow(
            device: widget.devices.elementAt(i),
            bluetooth: widget.bluetooth,
            infoString: changeInfoString));
      });
    }

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
          ],
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
  bool _isDisable = false;

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
              if (_isDisable == true) {
                return;
              }
              setState(() {
                scanButtonPressed(widget.device);
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

  scanButtonPressed(BluetoothDevice device) {
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
