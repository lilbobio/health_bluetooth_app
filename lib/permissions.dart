import 'package:permission_handler/permission_handler.dart';

class Permissions {
  Future<bool> hasLocationEnabled() async {
    if (await Permission.location.serviceStatus.isEnabled) {
      return true;
    } else if (await Permission.locationAlways.serviceStatus.isEnabled) {
      return true;
    } else if (await Permission.locationWhenInUse.serviceStatus.isEnabled) {
      return true;
    }
    return false;
  }

  Future<bool> hasBluetooth() async {
    return await Permission.bluetooth.serviceStatus.isEnabled;
  }
}
