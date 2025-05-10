import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart' show Lottie;
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:women_safety/repositories/maps/maps_repository.dart';
import 'package:women_safety/services/maps/location_service.dart';
import 'package:women_safety/widgets/custom_back_button.dart';

class LocateScreen extends StatefulWidget {
  @override
  _LocateScreenState createState() => _LocateScreenState();
}

class _LocateScreenState extends State<LocateScreen>
    with SingleTickerProviderStateMixin {
  final MapsRepository _mapsRepository = MapsRepository();
  GoogleMapController? mapController;
  Position? currentPosition;
  bool isLoading = true; // Initial loading state for map
  bool isLoadingPlaces = true; // Start with places loading as well
  Set<Marker> markers = {};
  List<Map<String, dynamic>> nearbyPlaces = [];
  final LocationService _locationService = LocationService();
  String currentLocationName = "Finding your location...";
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );
    _animationController.forward();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      isLoading = true;
      isLoadingPlaces = true; // Always set loading to true when starting
    });

    try {
      Position position = await _mapsRepository.getCurrentLocation();
      setState(() {
        currentPosition = position;
        isLoading = false;
        // Keep isLoadingPlaces true until API calls complete
      });

      // Get the address of current location
      await _getAddressFromLatLng(position.latitude, position.longitude);

      // Fetch nearby places
      await _fetchNearbyPlacesUsingOverpass(
          position.latitude, position.longitude);

      // Places loading finishes when API calls are done
      setState(() {
        isLoadingPlaces = false;
      });
    } catch (e) {
      print("Error getting current location: $e");
      _locationService.checkLocationPermissions();
      setState(() {
        isLoading = false;
        isLoadingPlaces = false; // Stop loading if there was an error
      });
    }
  }

  // Get address from latitude & longitude
  Future<void> _getAddressFromLatLng(double lat, double lng) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1'),
        headers: {
          'User-Agent': 'WomenSafetyApp/1.0',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Format the location name
        String address = data['display_name'] ?? "Unknown location";
        List<String> addressParts = address.split(',');

        // Take first 2-3 parts of the address for cleaner display
        String formattedAddress = addressParts.length > 2
            ? "${addressParts[0]}, ${addressParts[1]}"
            : address;

        setState(() {
          currentLocationName = formattedAddress;
        });
      }
    } catch (e) {
      print("Error fetching address: $e");
      setState(() {
        currentLocationName = "Your Current Location";
      });
    }
  }

  // Fetch places using OpenStreetMap's Overpass API (free)
  Future<void> _fetchNearbyPlacesUsingOverpass(double lat, double lng) async {
    // Don't set isLoadingPlaces to true here, it's already set in _getCurrentLocation

    try {
      // Define search radius (in meters)
      final radius = 3000; // 3km radius

      // Define all important safety places to search for
      Map<String, String> safetyPlaces = {
        'Police Station': 'amenity=police',
        'Hospital': 'amenity=hospital',
        'Pharmacy': 'amenity=pharmacy',
        'Bus Station': 'public_transport=station',
        'Metro Station': 'railway=station',
        'Shopping Mall': 'shop=mall',
        'Fire Station': 'amenity=fire_station',
      };

      List<Map<String, dynamic>> allPlaces = [];

      // Query each place type separately
      for (var entry in safetyPlaces.entries) {
        String placeName = entry.key;
        String query = entry.value;

        // Build Overpass query
        String overpassQuery = """
          [out:json];
          (
            node[$query](around:$radius,$lat,$lng);
            way[$query](around:$radius,$lat,$lng);
            relation[$query](around:$radius,$lat,$lng);
          );
          out center;
        """;

        // Encode query for URL
        String encodedQuery = Uri.encodeComponent(overpassQuery);

        // Call Overpass API
        final response = await http.get(
          Uri.parse(
              'https://overpass-api.de/api/interpreter?data=$encodedQuery'),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          if (data['elements'] != null) {
            // Process results
            for (var element in data['elements']) {
              double placeLat = element['lat'] ?? element['center']?['lat'];
              double placeLng = element['lon'] ?? element['center']?['lon'];

              if (placeLat != null && placeLng != null) {
                // Calculate distance
                double distanceInMeters =
                    Geolocator.distanceBetween(lat, lng, placeLat, placeLng);

                String distanceText;
                if (distanceInMeters < 1000) {
                  distanceText = '${distanceInMeters.round()} m';
                } else {
                  distanceText =
                      '${(distanceInMeters / 1000).toStringAsFixed(1)} km';
                }

                String locationName = element['tags']?['name'] ?? '$placeName';

                allPlaces.add({
                  "name": locationName,
                  "vicinity": element['tags']?['address'] ??
                      element['tags']?['operator'] ??
                      'Near ${currentLocationName}',
                  "lat": placeLat,
                  "lng": placeLng,
                  "type": placeName,
                  "distance": distanceText,
                });
              }
            }
          }
        }
      }

      // Sort places by distance
      allPlaces.sort((a, b) {
        // Extract numeric values from distance strings
        double extractDistance(String dist) {
          double value = double.parse(dist.replaceAll(RegExp(r'[^0-9.]'), ''));
          return dist.contains('km') ? value * 1000 : value;
        }

        double distA = extractDistance(a['distance']);
        double distB = extractDistance(b['distance']);

        return distA.compareTo(distB);
      });

      // If no places found with Overpass, fall back to Nominatim
      if (allPlaces.isEmpty) {
        await _fetchNearbyPlacesUsingNominatim(lat, lng);
      } else {
        _addMarkersFromPlaces(allPlaces);
      }
    } catch (e) {
      print("Error fetching places from Overpass API: $e");
      // Fallback to Nominatim if Overpass fails
      await _fetchNearbyPlacesUsingNominatim(lat, lng);
    }
    // We don't set isLoadingPlaces to false here because we do it in _getCurrentLocation
    // after all API calls are complete
  }

  // Alternative using Nominatim (another free service)
  Future<void> _fetchNearbyPlacesUsingNominatim(double lat, double lng) async {
    try {
      List<Map<String, dynamic>> allPlaces = [];

      // Important safety locations to search
      Map<String, String> safetySearchTerms = {
        'Police Station': 'police',
        'Hospital': 'hospital',
        'Pharmacy': 'pharmacy',
        'Bus Station': 'bus_station',
        'Metro Station': 'train_station',
        'Shopping Mall': 'mall',
        'Fire Station': 'fire_station',
      };

      for (var entry in safetySearchTerms.entries) {
        String placeType = entry.key;
        String searchTerm = entry.value;

        final response = await http.get(
          Uri.parse(
              'https://nominatim.openstreetmap.org/search.php?q=$searchTerm&format=json&limit=5&lat=$lat&lon=$lng&addressdetails=1'),
          headers: {
            'User-Agent': 'WomenSafetyApp/1.0',
          },
        );

        if (response.statusCode == 200) {
          final List data = json.decode(response.body);

          for (var place in data) {
            double placeLat = double.parse(place['lat']);
            double placeLng = double.parse(place['lon']);

            // Calculate distance
            double distanceInMeters =
                Geolocator.distanceBetween(lat, lng, placeLat, placeLng);

            String distanceText;
            if (distanceInMeters < 1000) {
              distanceText = '${distanceInMeters.round()} m';
            } else {
              distanceText =
                  '${(distanceInMeters / 1000).toStringAsFixed(1)} km';
            }

            // Add to places list
            allPlaces.add({
              "name": place['name'] ??
                  place['display_name']?.split(',')[0] ??
                  placeType,
              "vicinity": place['display_name'] ?? 'Address unavailable',
              "lat": placeLat,
              "lng": placeLng,
              "type": placeType,
              "distance": distanceText,
            });
          }
        }
      }

      // Sort by distance
      allPlaces.sort((a, b) {
        double extractDistance(String dist) {
          double value = double.parse(dist.replaceAll(RegExp(r'[^0-9.]'), ''));
          return dist.contains('km') ? value * 1000 : value;
        }

        return extractDistance(a['distance'])
            .compareTo(extractDistance(b['distance']));
      });

      _addMarkersFromPlaces(allPlaces);
    } catch (e) {
      print("Error fetching places from Nominatim API: $e");
      setState(() {
        nearbyPlaces = [];
      });
    }
  }

  void _addMarkersFromPlaces(List<Map<String, dynamic>> places) {
    if (places.isEmpty) {
      setState(() {
        markers = {};
        nearbyPlaces = [];
      });
      return;
    }

    Set<Marker> newMarkers = {};

    // Add current location marker first
    if (currentPosition != null) {
      newMarkers.add(
        Marker(
          markerId: MarkerId("currentLocation"),
          position:
              LatLng(currentPosition!.latitude, currentPosition!.longitude),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: InfoWindow(
            title: "You are here",
            snippet: currentLocationName,
          ),
        ),
      );
    }

    // Add other place markers
    for (var place in places) {
      final lat = place["lat"];
      final lng = place["lng"];
      final name = place["name"];
      final address = place["vicinity"];
      final type = place["type"];

      final BitmapDescriptor markerIcon = _getMarkerIcon(type);

      newMarkers.add(
        Marker(
          markerId: MarkerId(name + lat.toString() + lng.toString()),
          position: LatLng(lat, lng),
          icon: markerIcon,
          infoWindow: InfoWindow(
            title: name,
            snippet: address,
          ),
        ),
      );
    }

    setState(() {
      markers = newMarkers;
      nearbyPlaces = places;
    });
  }

  BitmapDescriptor _getMarkerIcon(String type) {
    if (type.contains('Police')) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    } else if (type.contains('Hospital') || type.contains('Pharmacy')) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    } else if (type.contains('Station')) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    } else if (type.contains('Mall')) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
    } else if (type.contains('Fire')) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    } else {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
    }
  }

  // Get icon for each type
  IconData _getTypeIcon(String type) {
    if (type.contains('Police')) {
      return Icons.local_police;
    } else if (type.contains('Hospital')) {
      return Icons.local_hospital;
    } else if (type.contains('Pharmacy')) {
      return Icons.medication_outlined;
    } else if (type.contains('Bus') || type.contains('Metro')) {
      return Icons.directions_bus;
    } else if (type.contains('Mall')) {
      return Icons.shopping_cart;
    } else if (type.contains('Fire')) {
      return Icons.local_fire_department;
    } else {
      return Icons.place;
    }
  }

  // Get color for each type
  Color _getTypeColor(String type) {
    if (type.contains('Police')) {
      return Colors.blue;
    } else if (type.contains('Hospital') || type.contains('Pharmacy')) {
      return Colors.red;
    } else if (type.contains('Station')) {
      return Colors.green;
    } else if (type.contains('Mall')) {
      return Colors.amber;
    } else if (type.contains('Fire')) {
      return Colors.orange;
    } else {
      return Colors.purple;
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE49AB0),
            Color(0xFFE49AB0).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFE49AB0).withOpacity(0.2),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              Spacer(),
              Text(
                'Safe Places',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Spacer(),
              SizedBox(width: 28), // Balance the layout
            ],
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.location_on_rounded,
                    size: 16,
                    color: Color(0xFFE49AB0),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Your Location",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        currentLocationName,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                isLoadingPlaces
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : IconButton(
                        icon: Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        constraints: BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          if (currentPosition != null) {
                            _fetchNearbyPlacesUsingOverpass(
                                currentPosition!.latitude,
                                currentPosition!.longitude);
                          }
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapContainer() {
    final screenHeight = MediaQuery.of(context).size.height;
    // Calculate a responsive height for the map
    final mapHeight =
        screenHeight < 600 ? screenHeight * 0.25 : screenHeight * 0.3;

    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      margin: EdgeInsets.fromLTRB(16, 12, 16, 0),
      height: mapHeight, // Responsive height
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: isLoading
            ? _buildLoadingAnimation()
            : GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  mapController = controller;
                },
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    currentPosition?.latitude ?? 30.3753,
                    currentPosition?.longitude ?? 69.3451,
                  ),
                  zoom: 15.0,
                ),
                markers: markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                compassEnabled: false,
              ),
      ),
    );
  }

  Widget _buildListHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Nearby Safe Places",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E3E5C),
            ),
          ),
          if (nearbyPlaces.isNotEmpty && !isLoadingPlaces)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Color(0xFFE49AB0).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                "${nearbyPlaces.length} Found",
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFE49AB0),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingAnimation() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/images/location_loading.json',
            width: 100, // reduced size
            height: 100, // reduced size
            fit: BoxFit.contain,
            controller: _animationController,
            onLoaded: (composition) {
              _animationController.duration = composition.duration;
              _animationController.forward();
            },
            errorBuilder: (context, error, stackTrace) {
              return CircularProgressIndicator(
                color: Color(0xFFE49AB0),
                strokeWidth: 3,
              );
            },
          ),
          SizedBox(height: 8),
          Text(
            "Searching for safe places...",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2E3E5C),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPlacesList() {
    // Important change: check if places are still loading first
    if (isLoadingPlaces) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 40,
              width: 40,
              child: CircularProgressIndicator(
                color: Color(0xFFE49AB0),
              ),
            ),
            SizedBox(height: 16),
            Text(
              "Finding safe places nearby...",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Color(0xFF8F9BB3),
              ),
            )
          ],
        ),
      );
    }

    // Only after loading is complete, check if places were found
    return nearbyPlaces.isEmpty
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_off,
                    size: 48,
                    color: Colors.grey[300],
                  ),
                  SizedBox(height: 16),
                  Text(
                    "No safe places found nearby",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E3E5C),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "We couldn't find any safe places in your current area",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Color(0xFF8F9BB3),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _getCurrentLocation, // Reload everything
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFE49AB0),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: Text(
                      "Retry",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        : ListView.builder(
            itemCount: nearbyPlaces.length,
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16, 4, 16, 16),
            itemBuilder: (context, index) {
              final place = nearbyPlaces[index];
              return Container(
                margin: EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      mapController?.animateCamera(
                        CameraUpdate.newLatLngZoom(
                          LatLng(place["lat"], place["lng"]),
                          17.0,
                        ),
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color:
                                  _getTypeColor(place["type"]).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Icon(
                                _getTypeIcon(place["type"]),
                                size: 24,
                                color: _getTypeColor(place["type"]),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  place["name"],
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Color(0xFF2E3E5C),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 2),
                                Text(
                                  place["type"],
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: _getTypeColor(place["type"]),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  place["vicinity"] ?? "",
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.directions,
                                            size: 12,
                                            color: Colors.blue,
                                          ),
                                          SizedBox(width: 2),
                                          Text(
                                            place["distance"],
                                            style: GoogleFonts.poppins(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Spacer(),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 14,
                                      color: Colors.grey[400],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFBE8EE),
                Colors.white,
              ],
              stops: [0.0, 0.3],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMapContainer(),
                      _buildListHeader(),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.45,
                        child: _buildPlacesList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: !isLoading
          ? FloatingActionButton(
              onPressed: () {
                if (currentPosition != null) {
                  mapController?.animateCamera(
                    CameraUpdate.newLatLngZoom(
                      LatLng(currentPosition!.latitude,
                          currentPosition!.longitude),
                      15.0,
                    ),
                  );
                }
              },
              backgroundColor: Color(0xFFE49AB0),
              mini: true,
              child: Icon(Icons.my_location, color: Colors.white, size: 20),
            )
          : null,
    );
  }

  @override
  void dispose() {
    mapController?.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
