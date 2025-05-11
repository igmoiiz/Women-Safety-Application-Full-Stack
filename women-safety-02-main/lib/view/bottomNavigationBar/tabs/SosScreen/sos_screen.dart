import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:women_safety/repositories/maps/maps_repository.dart';
import 'package:women_safety/services/maps/location_service.dart';
import 'package:women_safety/utils/custom_color.dart';
import 'package:women_safety/utils/custom_toast.dart';
import 'package:women_safety/utils/size.dart';
import 'package:flutter/services.dart';

class SOSScreen extends StatefulWidget {
  @override
  _SOSScreenState createState() => _SOSScreenState();
}

class _SOSScreenState extends State<SOSScreen> {
  final MapsRepository _mapsRepository = MapsRepository();
  GoogleMapController? mapController;
  Position? currentPosition;
  bool isLoading = true;
  String? emergencyPhoneNumber;
  String? emergencyEmail;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _getSPvalue();
    _updateEmergencyContactInfo();

    LocationService().checkLocationPermissions().whenComplete(() {
      _getCurrentLocation();
    });
  }

  Future<void> _getSPvalue() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      emergencyPhoneNumber = prefs.getString('phoneNumber');
      emergencyEmail = prefs.getString('email');
    });
  }

  Future<void> _updateEmergencyContactInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Set the new phone number and email as default emergency contacts
    await prefs.setString('phoneNumber', "03067892235");
    await prefs.setString('email', "moaiz3110@gmail.com");

    setState(() {
      emergencyPhoneNumber = "03067892235";
      emergencyEmail = "moaiz3110@gmail.com";
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await _mapsRepository.getCurrentLocation();
      setState(() {
        currentPosition = position;
        isLoading = false;
      });
    } catch (e) {
      CustomToast.showSnackbar(context, 'Location services are disabled');
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    mapController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          isLoading ? _buildLoadingView() : _buildMainContent(),
          _buildSOSButton(),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: CustomColor.buttonColor,
            ),
            SizedBox(height: 20),
            Text(
              "Loading your location...",
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Please wait while we get your current position",
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return SafeArea(
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSOSHeader(),
            verticalSpace(20),
            _buildSectionTitle('Your Current Location'),
            verticalSpace(8),
            _buildMapCard(),
            verticalSpace(20),
            _buildSectionTitle('Emergency Contacts'),
            verticalSpace(8),
            _buildContactsList(),
            // Add padding at the bottom to ensure content doesn't get hidden behind the SOS button
            SizedBox(height: 100 + MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      scrolledUnderElevation: 0,
      elevation: 0,
      backgroundColor: Colors.white,
      centerTitle: true,
      title: Text(
        "Emergency SOS",
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: CustomColor.buttonColor,
        ),
      ),
      actions: [
        Container(
          margin: EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              Icons.settings_outlined,
              size: 22,
              color: Colors.grey[800],
            ),
            onPressed: () {
              Geolocator.openLocationSettings();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSOSHeader() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            CustomColor.buttonColor,
            CustomColor.buttonColor.withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CustomColor.buttonColor.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Emergency Mode',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Send alert to your emergency contacts',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 16,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your exact GPS location will be sent with the alert',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            height: 18,
            width: 4,
            decoration: BoxDecoration(
              color: CustomColor.buttonColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            spreadRadius: 1,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            GoogleMap(
              onMapCreated: (controller) {
                mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  currentPosition?.latitude ?? 30.3753,
                  currentPosition?.longitude ?? 69.3451,
                ),
                zoom: 15.0,
              ),
              myLocationEnabled: true,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
            ),
            Positioned(
              right: 10,
              bottom: 10,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(Icons.my_location, color: CustomColor.buttonColor),
                  onPressed: () {
                    if (mapController != null && currentPosition != null) {
                      mapController!.animateCamera(
                        CameraUpdate.newLatLng(
                          LatLng(
                            currentPosition!.latitude,
                            currentPosition!.longitude,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactsList() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildContactTile(
            icon: CupertinoIcons.phone_fill,
            title: 'Phone Number',
            value: emergencyPhoneNumber ?? 'Not set',
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey.withOpacity(0.1),
          ),
          _buildContactTile(
            icon: CupertinoIcons.mail_solid,
            title: 'Email Address',
            value: emergencyEmail ?? 'Not set',
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    bool isSet = value != 'Not set';

    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSet
                  ? CustomColor.buttonColor.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isSet ? CustomColor.buttonColor : Colors.grey,
              size: 20,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isSet ? Colors.black87 : Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),
          if (isSet)
            Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                color: Colors.green,
                size: 16,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSOSButton() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: Offset(0, -2),
              blurRadius: 6,
            )
          ],
        ),
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 16,
          bottom: 16 + MediaQuery.of(context).padding.bottom,
        ),
        child: ElevatedButton(
          onPressed: _showSosOptions,
          style: ElevatedButton.styleFrom(
            backgroundColor: CustomColor.primaryPinkColor
                .withOpacity(0.9), // Simple red color
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'SEND SOS ALERT',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSosOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: EdgeInsets.zero,
        title: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
          child: Row(
            children: [
              Icon(
                CupertinoIcons.exclamationmark_triangle,
                color: Colors.red[400],
                size: 22,
              ),
              SizedBox(width: 10),
              Text(
                "Send Alert Via",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: FaIcon(
                        FontAwesomeIcons.whatsapp,
                        color: Colors.green,
                        size: 20,
                      ),
                      // backgroundColor: Colors.green.shade800,
                    ),
                    title: Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        "WhatsApp",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    subtitle: Text(
                      "Send location via WhatsApp",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      sendSosAlert();
                    },
                  ),
                  Divider(height: 12, thickness: 0.5),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.phone,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                    title: Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        "Phone Call",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    subtitle: Text(
                      "Call emergency contact directly",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _makeEmergencyCall();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 16, 16),
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Cancel",
                  style: GoogleFonts.poppins(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _makeEmergencyCall() async {
    // Get emergency phone number
    String phoneNumber = emergencyPhoneNumber ?? "03067892235";

    // Format phone number if needed
    if (phoneNumber.startsWith('+') == false && phoneNumber.startsWith('0')) {
      phoneNumber = '+92' + phoneNumber.substring(1);
    }

    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        CustomToast.showSnackbar(context, 'Could not launch dialer');
      }
    } catch (e) {
      CustomToast.showSnackbar(context, 'Error making emergency call: $e');
    }
  }

  Future<void> sendSosAlert() async {
    // First check if location services are enabled
    bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();

    if (!isLocationEnabled) {
      // Show dialog if location is disabled
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.location_off,
                color: Colors.red,
              ),
              SizedBox(width: 10),
              Text(
                "Location Disabled",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Text(
            "Your location services are disabled. Please enable them to send accurate location with your SOS alert.",
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "Cancel",
                style: GoogleFonts.poppins(
                  color: Colors.grey[800],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Geolocator.openLocationSettings();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomColor.buttonColor,
              ),
              child: Text(
                "Enable Location",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
      return;
    }

    // If location is enabled but currentPosition is null, try to get it
    if (currentPosition == null) {
      try {
        CustomToast.showSnackbar(context, 'Getting your current location...');
        await _getCurrentLocation();
        if (currentPosition == null) {
          CustomToast.showSnackbar(context,
              'Could not determine your location. Sending alert with last known location.');
        }
      } catch (e) {
        CustomToast.showSnackbar(context,
            'Location error. Sending alert with approximate location.');
      }
    }

    String text =
        "EMERGENCY ALERT! I need help immediately! My current location is: https://www.google.com/maps?q=${currentPosition?.latitude ?? 0},${currentPosition?.longitude ?? 0}";
    String encodedText = Uri.encodeComponent(text);

    // Phone number logic
    String phoneNumber = emergencyPhoneNumber ?? "03067892235";
    if (phoneNumber.startsWith('+') == false && phoneNumber.startsWith('0')) {
      phoneNumber = '+92' + phoneNumber.substring(1);
    }

    String androidUrl = "whatsapp://send?phone=$phoneNumber&text=$encodedText";
    String iosUrl = "https://wa.me/$phoneNumber?text=$encodedText";
    String webUrl =
        'https://api.whatsapp.com/send/?phone=$phoneNumber&text=$encodedText';

    try {
      // Show alert dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                CupertinoIcons.exclamationmark_triangle,
                color: CustomColor.buttonColor,
              ),
              SizedBox(width: 10),
              Text(
                "Sending Alert",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Row(
            children: [
              CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(CustomColor.buttonColor),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Text(
                  "Preparing your emergency alert...",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      if (Platform.isIOS) {
        if (await canLaunchUrl(Uri.parse(iosUrl))) {
          await launchUrl(Uri.parse(iosUrl));
        } else {
          throw PlatformException(code: 'WhatsApp not installed');
        }
      } else {
        if (await canLaunchUrl(Uri.parse(androidUrl))) {
          await launchUrl(Uri.parse(androidUrl));
        } else {
          throw PlatformException(code: 'WhatsApp not installed');
        }
      }

      // Dismiss dialog
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } catch (e) {
      // Dismiss dialog if showing
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      try {
        await launchUrl(Uri.parse(webUrl),
            mode: LaunchMode.externalApplication);
      } catch (e) {
        CustomToast.showSnackbar(
            context, 'Failed to send emergency alert. Please try again.');
      }
    }
  }
}
