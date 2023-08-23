# MIE Bluetooth Health App

A flutter app for Medical Informatics Engineering (MIE).

## About

This app is for connecting bluetooth scales and blood pressure tests.
The app will have a button to connect to the bluetooth device and you have to specify whether the device is a bluetooth scale or a bluetooth blood pressure monitor. then once the device is connected it should show the realtime weight or heart rate on the phone.

## Author

This App was created by Dominic Oaldon with help from Doug Horner.

## Building

Install flutter

On PC: <https://docs.flutter.dev/get-started/install/windows>

On Mac: <https://docs.flutter.dev/get-started/install/macos>

### Android

```bash
flutter analyze
flutter run lib/main.dart
h
```

### IOS

Install dependencies (cocapods, xcode)

```bash
flutter analyze
flutter run lib/main.dart
h
```

## Notes

[Google Drive Link](https://docs.google.com/document/d/1tMROo_rObtT972zS42XL3zOv_wVSsJWuNO4OBSkATlc/edit?pli=1)

## Video Of App

[Video Link](https://www.youtube.com/shorts/dOg5BTFkDEM)

## Screenshots

### Device Select Page

![alt text][bluetoothIsDisabled]
![alt text][AssociatedPageEmpty]
![alt text][deviceSelectPage]
![alt text][loadingScreen2]

### Connected Page

![alt text][connectedPage]
![alt text][weightPage]
![alt text][weightPagePair]
![alt text][weightPageBeforeWeight]

[loadingScreen2]: assets/images/loadingScreen2.png "loading screen between device page and connected page"
[deviceSelectPage]: assets/images/Device_Page.png "device select page"
[connectedPage]: assets/images/Connected_page.png "connected page"
[AssociatedPageEmpty]: assets/images/Assocaited_Page.png "Empty Associated Page"
[bluetoothIsDisabled]: assets/images/Bluetooth_is_disabled.jpg "Shows when Device has bluetooth disabled"
[weightPage]: assets/images/weight_page3.png "The Connected Page when Connected to AND Scale"
[weightPagePair]: assets/images/weight_page1.png "The Page to Pair the AND Scale"
[weightPageBeforeWeight]: assets/images/weight_page2.png "The page right before you stand on scale"
