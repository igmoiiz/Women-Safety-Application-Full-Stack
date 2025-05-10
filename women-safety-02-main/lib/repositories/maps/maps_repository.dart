import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:women_safety/services/maps/google_maps_service.dart';
import 'package:women_safety/services/maps/location_service.dart';
import 'package:women_safety/utils/public_washroom.dart';

class MapsRepository {
  final LocationService _locationService = LocationService();
  final GoogleMapsService _mapsService = GoogleMapsService();

  Future<Position> getCurrentLocation() async {
    return await _locationService.getCurrentLocation();
  }

  Set<Marker> createMarkers({
    Position? currentPosition,
    required List<PublicWashroom> washrooms,
  }) {
    return _mapsService.createMarkers(
      currentPosition: currentPosition,
      washrooms: washrooms,
    );
  }
}
