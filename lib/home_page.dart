import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bluetooth_health_app/device_page.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'bluetooth.dart';
//import 'package:flutter_blue/flutter_blue.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String infoString = '\n\n\nClick on the Device\n you Want to Connect to\n\n';
  Timer? timer;
  Bluetooth bluetooth = Bluetooth();
  List<Widget> deviceButtons = List.empty(growable: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Column(
          children: [
            //logo
            Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                child: Image.asset('assets/images/logo.jpg'),
              ),
            ),

            //info text
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    infoString,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 20.0, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),

            //device buttons
            Align(
              alignment: Alignment.center,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: deviceButtons),
            ),

            //search button
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                children: [
                  FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        context.loaderOverlay.show();
                        infoString = '\n\n\nScanning for devices...\n\n';
                        bluetooth.frbScan();
                        Future.delayed(const Duration(seconds: 4), () {
                          bluetooth.fbrEndScan();
                          context.loaderOverlay.hide();
                          if (bluetooth.devices.isEmpty) {
                            setState(() {
                              infoString = '\n\n\nFound 0 Relevant Devices\n\n';
                            });
                          } else {
                            setState(() {
                              infoString =
                                  '\n\n\nClick to Connect to Bluetooth Device\n\n';
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DevicePage(
                                      bluetooth: bluetooth,
                                      title: widget.title),
                                ),
                              );
                            });
                          }
                        });
                      });
                    },
                    heroTag: null,
                    child: const Icon(Icons.search),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}