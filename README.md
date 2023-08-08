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
```

### Mac

Install dependencies (cocapods, xcode)

```bash
flutter analyze
flutter run lib/main.dart
```

## Notes

[Google Drive Link](https://docs.google.com/document/d/1tMROo_rObtT972zS42XL3zOv_wVSsJWuNO4OBSkATlc/edit?pli=1)

## Screenshots

### Device Select page

![alt text][bluetoothIsDisabled]
![alt text][AssociatedPageEmpty]
![alt text][deviceSelectPage]
![alt text][loadingScreen2]
![alt text][AssociatedPage]

### Connected to Device Page

![alt text][connectedPage]

<!-- [homeScreenImage]: assets/images/homescreen_screenshot.jpg "home screen"
[loadingScreen1]: assets/images/loadingScreen1.jpg "loading screen between home screen and device page" -->
[loadingScreen2]: assets/images/loadingScreen2.jpg "loading screen between device page and connected page"
[deviceSelectPage]: assets/images/Device_Page.jpg "device select page"
[connectedPage]: assets/images/Cconnected_page.jpg "connected page"
[AssociatedPageEmpty]: assets/images/Assocaited_Page.jpg "Empty Associated Page"
[AssociatedPage]: assets/images/Associated_Page2.jpg "Associated Page After Connection"
[bluetoothIsDisabled]: assets/images/Bluetooth_is_disabled.jpg "Shows when Device has bluetooth disabled"
