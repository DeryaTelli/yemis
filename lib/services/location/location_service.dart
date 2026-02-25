import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  /// Check and request location permission
  Future<bool> checkAndRequestPermission() async {
    final status = await Permission.locationWhenInUse.status;
    
    if (status.isGranted) {
      return true;
    }

    final result = await Permission.locationWhenInUse.request();
    return result.isGranted;
  }

  /// Get current position of the user
  Future<Position?> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    return await Geolocator.getCurrentPosition();
  }

  /// Open app settings for location permission
  Future<void> openSettings() async {
    await openAppSettings();
  }
}
