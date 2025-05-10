import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart'; // Use this import instead of googleapis
import 'package:maps_launcher/maps_launcher.dart';
import 'package:women_safety/utils/loading_overlay.dart';
import 'package:women_safety/utils/public_washroom.dart';

class WashroomDetailCard extends StatelessWidget {
  final PublicWashroom washroom;
  final GoogleMapController? mapController;
  final double? distance; // Add distance as a separate parameter
  final Position? currentPosition; // Add current position parameter
  final bool isMapInitialized; // Add this flag

  const WashroomDetailCard({
    Key? key,
    required this.washroom,
    this.mapController,
    this.distance,
    this.currentPosition,
    this.isMapInitialized = false, // Default to false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: Color(0xFFF5E9EF),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            _zoomToLocation(context);
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getTypeColor(washroom.type).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        _getTypeIcon(washroom.type),
                        color: _getTypeColor(washroom.type),
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            washroom.name,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2E3E5C),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            washroom.address,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Color(0xFF8F9BB3),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Color(0xFFF9F9F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoItem(
                        icon: Icons.location_on_outlined,
                        label: "${distance?.toStringAsFixed(1) ?? 'N/A'} km",
                        color: Color(0xFF5E6C84),
                      ),
                      _buildDivider(),
                      _buildInfoItem(
                        icon: Icons.access_time_rounded,
                        label: "24/7",
                        color: Color(0xFF5E6C84),
                      ),
                      _buildDivider(),
                      _buildInfoItem(
                        icon: Icons.star_rounded,
                        label: "${washroom.rating.toStringAsFixed(1)}",
                        color: Colors.amber,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _zoomToLocation(context);
                        },
                        icon: Icon(
                          Icons.map_outlined,
                          size: 18,
                          color: const Color.fromARGB(255, 240, 144, 176),
                          // color: Colors.black45,
                        ),
                        label: Text('View on Map'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Color(0xFFE49AB0),
                          side: BorderSide(color: Color(0xFFE49AB0)),
                          padding: EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _openDirections();
                        },
                        icon: Icon(
                          Icons.directions,
                          size: 18,
                          color: Colors.white,
                        ),
                        label: Text('Directions'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFE49AB0),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 10),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 20,
      width: 1,
      color: Colors.grey.withOpacity(0.2),
    );
  }

  void _zoomToLocation(BuildContext context) {
    // Check if map is initialized before trying to use the controller
    if (!isMapInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Map is still initializing, please try again in a moment'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
      return;
    }

    if (mapController != null) {
      // Show a temporary loading indicator
      final loadingOverlay = LoadingOverlay.of(context);
      loadingOverlay.show();

      // Get current position from the map
      mapController!.getVisibleRegion().then((visibleRegion) {
        // Calculate the center of the current view
        LatLng currentCenter = LatLng(
          (visibleRegion.northeast.latitude +
                  visibleRegion.southwest.latitude) /
              2,
          (visibleRegion.northeast.longitude +
                  visibleRegion.southwest.longitude) /
              2,
        );

        // Get target position
        LatLng targetPosition = LatLng(washroom.latitude, washroom.longitude);

        // Calculate the distance between current center and target (in approx meters)
        double distanceInMeters = _calculateDistance(
            currentCenter.latitude,
            currentCenter.longitude,
            targetPosition.latitude,
            targetPosition.longitude);

        // Check if we're already zoomed to this location
        mapController!.getZoomLevel().then((zoom) {
          // Hide loading indicator
          loadingOverlay.hide();

          double currentZoom = zoom;

          // If we're already very close and zoomed in enough
          if (distanceInMeters < 100 && currentZoom > 16.5) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('You are already viewing this location'),
                duration: Duration(seconds: 2),
                backgroundColor: Colors.grey[700],
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: EdgeInsets.all(10),
              ),
            );
          } else {
            // Otherwise, animate to the location
            mapController!.animateCamera(
              CameraUpdate.newLatLngZoom(
                targetPosition,
                17.0,
              ),
            );
          }
        }).catchError((error) {
          loadingOverlay.hide();
          _handleMapError(context);
        });
      }).catchError((error) {
        loadingOverlay.hide();
        _handleMapError(context);

        // Fallback if there's an error getting the visible region
        try {
          mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(
              LatLng(washroom.latitude, washroom.longitude),
              17.0,
            ),
          );
        } catch (e) {
          // If this also fails, we've handled the error already
        }
      });
    } else {
      _handleMapError(context);
    }
  }

  void _handleMapError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Map is not available right now. Please try again.'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        action: SnackBarAction(
          label: 'RETRY',
          textColor: Colors.white,
          onPressed: () {
            // This retry could potentially trigger the parent to reinitialize the map
          },
        ),
      ),
    );
  }

  // Helper method to calculate distance between two coordinates (Haversine formula)
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const int earthRadius = 6371000; // meters
    double latDistance = _toRadians(lat2 - lat1);
    double lonDistance = _toRadians(lon2 - lon1);

    double a = sin(latDistance / 2) * sin(latDistance / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(lonDistance / 2) *
            sin(lonDistance / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c; // distance in meters
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }

  void _openDirections() {
    MapsLauncher.launchCoordinates(
      washroom.latitude,
      washroom.longitude,
      washroom.name,
    );
  }

  IconData _getTypeIcon(String type) {
    // Safeguard against null
    final String typeKey = (type ?? 'public').toLowerCase();
    switch (typeKey) {
      case 'restaurant':
        return Icons.restaurant;
      case 'mall':
        return Icons.shopping_bag_outlined;
      case 'hotel':
        return Icons.hotel;
      case 'public':
      default:
        return Icons.wc;
    }
  }

  Color _getTypeColor(String type) {
    // Safeguard against null
    final String typeKey = (type ?? 'public').toLowerCase();
    switch (typeKey) {
      case 'restaurant':
        return Color(0xFF00B2FF);
      case 'mall':
        return Color(0xFFFF6B00);
      case 'hotel':
        return Color(0xFF6236FF);
      case 'public':
      default:
        return Color(0xFFE49AB0);
    }
  }
}
