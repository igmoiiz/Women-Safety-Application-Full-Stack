// ignore_for_file: unused_import

import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as permission;
import 'package:location/location.dart';

class LocationService {
  final Location location = Location();

  Future<void> checkLocationPermissions() async {
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return; // User denied enabling location
      }
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return; // User denied location permission
      }
    }
  }

  Future<LocationData> getLocationData() async {
    await checkLocationPermissions();
    return await location.getLocation();
  }

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    return await Geolocator.getCurrentPosition();
  }
}
