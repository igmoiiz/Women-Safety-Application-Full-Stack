import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:women_safety/utils/public_washroom.dart';

class GoogleMapsService {
  Set<Marker> createMarkers({
    required Position? currentPosition,
    required List<PublicWashroom> washrooms,
  }) {
    Set<Marker> markers = {};

    if (currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('currentLocation'),
          position: LatLng(currentPosition.latitude, currentPosition.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
      );
    }

    for (var washroom in washrooms) {
      markers.add(
        Marker(
          markerId: MarkerId(washroom.id),
          position: LatLng(washroom.latitude, washroom.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            washroom.isVerified
                ? BitmapDescriptor.hueGreen
                : BitmapDescriptor.hueViolet,
          ),
          infoWindow: InfoWindow(
            title: washroom.name,
            snippet: washroom.address,
          ),
        ),
      );
    }
    return markers;
  }
}
