import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:women_safety/repositories/maps/maps_repository.dart';
import 'package:women_safety/repositories/red_area_repository.dart';
import 'package:women_safety/services/maps/location_service.dart';
import 'package:women_safety/utils/constant.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import 'package:women_safety/utils/public_washroom.dart';

class RedArea extends StatefulWidget {
  const RedArea({Key? key}) : super(key: key);

  @override
  _RedAreaState createState() => _RedAreaState();
}

class _RedAreaState extends State<RedArea> with SingleTickerProviderStateMixin {
  final MapsRepository _mapsRepository = MapsRepository();
  final RedAreaRepository _redAreaRepository = RedAreaRepository();
  GoogleMapController? mapController;
  Position? currentPosition;
  bool isLoading = true;
  Set<Marker> markers = {};
  Set<Circle> circles = {};
  final LocationService _locationService = LocationService();
  BitmapDescriptor? redAreaIcon;
  late AnimationController _animationController;
  List<PublicWashroom> firestoreRedAreas = [];
  bool isMapInitialized = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _loadMapAssets();
    _getCurrentLocation();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadMapAssets() async {
    try {
      final Uint8List markerImageBytes =
          await getBytesFromAsset('assets/images/locationMark.png', 80);
      redAreaIcon = BitmapDescriptor.fromBytes(markerImageBytes);
    } catch (e) {
      // Fallback to default marker if asset loading fails
      print("Error loading marker asset: $e");
    }
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await _mapsRepository.getCurrentLocation();
      setState(() {
        currentPosition = position;
        isLoading = false;
      });

      if (mapController != null && isMapInitialized) {
        _updateMap();
      }
    } catch (e) {
      _locationService.checkLocationPermissions();
      setState(() => isLoading = false);
    }
  }

  void _updateMap() {
    if (currentPosition == null) return;

    // Get both predefined and Firestore red areas
    List<PublicWashroom> allRedAreas = [
      ...predefinedWashrooms.where((washroom) => !washroom.isVerified),
      ...firestoreRedAreas
    ];

    // Create circles for danger zones
    circles = allRedAreas
        .map((washroom) => Circle(
              circleId: CircleId(washroom.id),
              center: LatLng(washroom.latitude, washroom.longitude),
              radius: 300, // 300 meters radius
              fillColor: Colors.red.withOpacity(0.25),
              strokeColor: const Color(0xFFDA2C2D),
              strokeWidth: 2,
            ))
        .toSet();

    // Create markers for danger points
    markers = allRedAreas.map((washroom) {
      return Marker(
        markerId: MarkerId(washroom.id),
        position: LatLng(washroom.latitude, washroom.longitude),
        icon: redAreaIcon ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: "⚠️ ${washroom.name}",
          snippet: washroom.description ?? "Avoid this area",
        ),
      );
    }).toSet();

    // Add current position marker
    if (currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('currentLocation'),
          position:
              LatLng(currentPosition!.latitude, currentPosition!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
      );
    }

    // Update map camera position if needed
    if (mapController != null && currentPosition != null) {
      mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(currentPosition!.latitude, currentPosition!.longitude),
          14.0,
        ),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    setState(() {
      isMapInitialized = true;
    });
    _updateMap();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PublicWashroom>>(
      stream: _redAreaRepository.getRedAreasStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            firestoreRedAreas.isEmpty) {
          // Initial load, show loading indicator only if we don't have any data yet
          return _buildScaffold(isLoading: true, redAreas: []);
        } else if (snapshot.hasError) {
          // If there's an error fetching from Firestore, display predefined areas only
          print('Error loading red areas: ${snapshot.error}');
          return _buildScaffold(
            isLoading: false,
            redAreas: predefinedWashrooms.where((w) => !w.isVerified).toList(),
          );
        } else {
          // If we have data from Firestore, update our list and refresh the map
          if (snapshot.hasData) {
            firestoreRedAreas = snapshot.data!;

            // Update map markers and circles with the new data
            if (isMapInitialized) {
              _updateMap();
            }
          }

          // Combine predefined unsafe areas with Firebase ones
          List<PublicWashroom> combinedRedAreas = [
            ...predefinedWashrooms.where((w) => !w.isVerified).toList(),
            ...firestoreRedAreas,
          ];

          return _buildScaffold(
            isLoading: false,
            redAreas: combinedRedAreas,
          );
        }
      },
    );
  }

  Widget _buildScaffold(
      {required bool isLoading, required List<PublicWashroom> redAreas}) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF0F0),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildMapContainer(),
              _buildListHeader(redAreas),
              Expanded(
                child: _buildRedAreasList(redAreas),
              ),
              _buildReportButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        borderRadius: const BorderRadius.only(
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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Color(0xFFDA2C2D),
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
                      const Icon(
                        Icons.warning_rounded,
                        color: Color(0xFFDA2C2D),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Red Areas',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2E3E5C),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Refresh button that now actually refreshes the data
              InkWell(
                onTap: () {
                  // Force refresh location and map
                  _getCurrentLocation();
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.refresh_rounded,
                    color: Color(0xFFDA2C2D),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapContainer() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      height: MediaQuery.of(context).size.height * 0.35,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(const Color(0xFFDA2C2D)),
                ),
              )
            : GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: currentPosition != null
                      ? LatLng(
                          currentPosition!.latitude, currentPosition!.longitude)
                      : const LatLng(30.3753, 69.3451), // Pakistan center
                  zoom: 14.0,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                markers: markers,
                circles: circles,
                mapType: MapType.normal,
              ),
      ),
    );
  }

  Widget _buildListHeader(List<PublicWashroom> redAreas) {
    final redAreaCount = redAreas.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: [
          const Icon(
            Icons.location_on,
            color: Color(0xFFDA2C2D),
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            'Reported Unsafe Areas',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2E3E5C),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFDA2C2D).withOpacity(0.1),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              '$redAreaCount Areas',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFDA2C2D),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRedAreasList(List<PublicWashroom> redAreas) {
    if (redAreas.isEmpty) {
      return _buildShimmerList();
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: redAreas.length,
      itemBuilder: (context, index) {
        final redArea = redAreas[index];

        return _buildRedAreaCard(redArea);
      },
    );
  }

  Widget _buildRedAreaCard(PublicWashroom redArea) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            if (mapController != null) {
              mapController!.animateCamera(
                CameraUpdate.newLatLngZoom(
                  LatLng(redArea.latitude, redArea.longitude),
                  16.0,
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDA2C2D).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_rounded,
                    color: Color(0xFFDA2C2D),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        redArea.name,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2E3E5C),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        redArea.address,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (redArea.description != null &&
                          redArea.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            "Warning: ${redArea.description}",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFFDA2C2D),
                            ),
                          ),
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
  }

  Widget _buildShimmerList() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 200,
                        height: 12,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildReportButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(
              context, '/bottomNavigation/home/RedArea/ReportRedAreaScreen');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFDA2C2D),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          'Report Unsafe Area',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
