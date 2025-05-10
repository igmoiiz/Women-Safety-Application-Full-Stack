import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as maps;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:women_safety/repositories/maps/maps_repository.dart';
import 'package:women_safety/services/maps/location_service.dart';
import 'package:women_safety/utils/public_washroom.dart';
import 'package:women_safety/utils/constant.dart';
import 'package:women_safety/utils/custom_color.dart';
import 'package:women_safety/view/bottomNavigationBar/tabs/homeScreen/Screen/PinkArea/widgets/washroom_detail_card.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:math'; // Add this import for math functions

class PinkArea extends StatefulWidget {
  @override
  _PinkAreaState createState() => _PinkAreaState();
}

class _PinkAreaState extends State<PinkArea>
    with SingleTickerProviderStateMixin {
  final MapsRepository _mapsRepository = MapsRepository();
  final LocationService _locationService = LocationService();
  maps.GoogleMapController? mapController;
  Position? currentPosition;
  bool isLoading = true;
  bool isShowWashroom = false;
  bool isLocationServiceEnabled = false;
  String locationMessage = 'Please enable location services';
  Set<maps.Marker> markers = <maps.Marker>{};
  List<PublicWashroom> washrooms = predefinedWashrooms;
  late AnimationController _animationController;
  Map<String, double> washroomDistances = {}; // Store distances separately
  bool isMapInitialized = false; // Add a flag to track map initialization

  List<PublicWashroom> get filteredWashrooms => washrooms;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );
    _animationController.forward();
    _checkLocationService();
  }

  Future<void> _checkLocationService() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    setState(() {
      isLocationServiceEnabled = serviceEnabled;
      if (!serviceEnabled) {
        locationMessage = 'Please enable location services';
      } else {
        locationMessage = 'Checking location permission...';
        _locationService.checkLocationPermissions().whenComplete(() {
          _getCurrentLocation();
        });
      }
    });

    // Listen to location service status changes
    Geolocator.getServiceStatusStream().listen((status) {
      setState(() {
        isLocationServiceEnabled = status == ServiceStatus.enabled;
        if (isLocationServiceEnabled) {
          locationMessage = 'Checking location permission...';
          _getCurrentLocation();
        } else {
          locationMessage = 'Please enable location services';
        }
      });
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await _mapsRepository.getCurrentLocation();
      setState(() {
        isShowWashroom = true;
        currentPosition = position;
        isLoading = false;

        // Calculate and store distances separately
        for (var washroom in washrooms) {
          double distanceInKm = Geolocator.distanceBetween(
                position.latitude,
                position.longitude,
                washroom.latitude,
                washroom.longitude,
              ) /
              1000; // Convert meters to kilometers

          washroomDistances[washroom.id] = distanceInKm;
        }

        markers = _createMarkers();
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      Geolocator.getServiceStatusStream().listen((status) {
        if (status == ServiceStatus.enabled) {
          _getCurrentLocation();
        }
      });
    }
  }

  // Create a custom method to create markers
  Set<maps.Marker> _createMarkers() {
    Set<maps.Marker> allMarkers = {};

    // Add user's current position marker
    if (currentPosition != null) {
      allMarkers.add(
        maps.Marker(
          markerId: maps.MarkerId('currentLocation'),
          position: maps.LatLng(
              currentPosition!.latitude, currentPosition!.longitude),
          infoWindow: maps.InfoWindow(title: 'Your Location'),
          icon: maps.BitmapDescriptor.defaultMarkerWithHue(
              maps.BitmapDescriptor.hueBlue),
        ),
      );
    }

    // Add washroom markers
    for (var washroom in washrooms) {
      allMarkers.add(
        maps.Marker(
          markerId: maps.MarkerId(washroom.id),
          position: maps.LatLng(washroom.latitude, washroom.longitude),
          infoWindow: maps.InfoWindow(
            title: washroom.name,
            snippet: washroom.address,
          ),
        ),
      );
    }

    return allMarkers;
  }

  void _onMapCreated(maps.GoogleMapController controller) {
    mapController = controller;
    _customizeMap(controller);

    // Set a short delay to ensure the map is fully loaded
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        isMapInitialized = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Sort washrooms by distance
    final sortedWashrooms = List<PublicWashroom>.from(washrooms);
    sortedWashrooms.sort((a, b) {
      double distA = washroomDistances[a.id] ?? double.infinity;
      double distB = washroomDistances[b.id] ?? double.infinity;
      return distA.compareTo(distB);
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFBE8EE),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildMapContainer(),
              _buildListHeader(sortedWashrooms),
              Expanded(
                child: _buildWashroomList(sortedWashrooms),
              ),
            ],
          ),
        ),
      ),
      // floatingActionButton: isShowWashroom ? _buildRefreshButton() : null,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Top row with back button and actions
          Row(
            children: [
              // Back button with animation
              InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Color(0xFFE49AB0),
                    size: 20,
                  ),
                ),
              ),

              Expanded(
                child: Center(
                  // Title with stylish design
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        color: Color(0xFFE49AB0),
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Pink Areas',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E3E5C),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Refresh button
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.refresh_rounded,
                  color: Colors.transparent,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapContainer() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
      height: MediaQuery.of(context).size.height * 0.35,
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
            ? _buildShimmerMap()
            : Stack(
                children: [
                  maps.GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: maps.CameraPosition(
                      target: maps.LatLng(
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
                  if (!isLocationServiceEnabled)
                    Container(
                      color: Colors.black.withOpacity(0.6),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_off,
                              color: Colors.white,
                              size: 40,
                            ),
                            SizedBox(height: 16),
                            Text(
                              "Location services disabled",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                Geolocator.openLocationSettings();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFE49AB0),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Text("Enable Location"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Add a loading overlay when map is not yet initialized
                  if (!isMapInitialized && !isLoading)
                    Container(
                      color: Colors.black.withOpacity(0.2),
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFFE49AB0)),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  void _customizeMap(GoogleMapController controller) async {
    // Optional: Customize map style
    // String mapStyle = await rootBundle.loadString('assets/map_style.json');
    // controller.setMapStyle(mapStyle);
  }

  Widget _buildListHeader(List<PublicWashroom> sortedWashrooms) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isShowWashroom
                ? "Nearby Pink Areas"
                : "Finding nearby locations...",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E3E5C),
            ),
          ),
          if (isShowWashroom)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Color(0xFFE49AB0).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "${sortedWashrooms.length} Found",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFE49AB0),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWashroomList(List<PublicWashroom> sortedWashrooms) {
    if (isLoading || !isShowWashroom) {
      return _buildLoadingListState();
    }

    if (sortedWashrooms.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
      physics: BouncingScrollPhysics(),
      itemCount: sortedWashrooms.length,
      itemBuilder: (context, index) {
        final washroom = sortedWashrooms[index];
        final distance = washroomDistances[washroom.id];

        return Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: WashroomDetailCard(
            washroom: washroom,
            mapController: mapController,
            distance: distance,
            currentPosition: currentPosition,
            isMapInitialized: isMapInitialized, // Pass this flag to the card
          ),
        );
      },
    );
  }

  Widget _buildLoadingListState() {
    return Center(
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/images/location_loading.json',
              width: 150,
              height: 150,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return CircularProgressIndicator(
                  color: Color(0xFFE49AB0),
                  strokeWidth: 3,
                );
              },
            ),
            SizedBox(height: 24),
            Text(
              isLocationServiceEnabled
                  ? "Finding nearby locations..."
                  : "Location services disabled",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2E3E5C),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              isLocationServiceEnabled
                  ? "We're locating the nearest women's washrooms for you"
                  : "Please enable location services to find nearby washrooms",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Color(0xFF8F9BB3),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/no_results.png',
            width: 120,
            height: 120,
            errorBuilder: (context, error, stackTrace) =>
                Icon(Icons.location_off, size: 80, color: Colors.grey[300]),
          ),
          SizedBox(height: 24),
          Text(
            "No locations found nearby",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E3E5C),
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "We couldn't find any women's washrooms in your current area",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Color(0xFF8F9BB3),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerMap() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }

  Widget _buildRefreshButton() {
    return FloatingActionButton(
      onPressed: _getCurrentLocation,
      backgroundColor: Color(0xFFE49AB0),
      child: Icon(Icons.my_location, color: Colors.white),
    );
  }

  @override
  void dispose() {
    mapController?.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
