// ignore_for_file: depend_on_referenced_packages

import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:women_safety/services/maps/location_service.dart';

class ReportRedAreaScreen extends StatefulWidget {
  const ReportRedAreaScreen({super.key});

  @override
  State<ReportRedAreaScreen> createState() => _ReportRedAreaScreenState();
}

class _ReportRedAreaScreenState extends State<ReportRedAreaScreen> {
  DateTime selectedDate = DateTime.now();
  Position? _currentPosition;
  XFile? _pickedImage;
  final TextEditingController noteController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  bool isSubmitting = false;
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _checkLocationPermissions();
  }

  Future<void> _checkLocationPermissions() async {
    try {
      await _locationService.checkLocationPermissions();
    } catch (e) {
      log("Location permission error: $e");
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() => isSubmitting = true);
      _currentPosition = await Geolocator.getCurrentPosition();

      final List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition!.latitude, _currentPosition!.longitude);

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;
        addressController.text =
            '${place.street ?? ''}, ${place.locality ?? ''}, ${place.postalCode ?? ''}, ${place.country ?? ''}';
      }

      _showToast('Location selected successfully');
    } catch (e) {
      _showToast('Error getting location: ${e.toString()}');
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    try {
      _pickedImage = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
      );
      setState(() {});
    } catch (e) {
      _showToast('Error picking image: ${e.toString()}');
    }
  }

  Future<void> _takePicture() async {
    final ImagePicker _picker = ImagePicker();
    try {
      _pickedImage = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
      );
      setState(() {});
    } catch (e) {
      _showToast('Error taking picture: ${e.toString()}');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Color(0xFFDA2C2D),
            colorScheme: ColorScheme.light(primary: Color(0xFFDA2C2D)),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<void> _submitReport() async {
    if (_currentPosition == null) {
      _showToast('Please select a location');
      return;
    }

    if (noteController.text.trim().isEmpty) {
      _showToast('Please provide a description');
      return;
    }

    setState(() => isSubmitting = true);

    try {
      // Store image and get URL (not implemented in this example)
      String imageUrl = _pickedImage?.path ?? 'no_image';

      await FirebaseFirestore.instance.collection('redArea').add({
        'note': noteController.text.trim(),
        'location': {
          'latitude': _currentPosition!.latitude,
          'longitude': _currentPosition!.longitude,
          'address': addressController.text,
        },
        'date': selectedDate.toIso8601String(),
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Success! Show toast and pop back to previous screen
      _showToast(
          'Area reported successfully! Thank you for contributing to women\'s safety.');

      // Go back to the Red Area screen after a short delay to ensure the toast is visible
      Future.delayed(const Duration(milliseconds: 800), () {
        Navigator.pop(context);
      });
    } catch (e) {
      _showToast('Error submitting report: ${e.toString()}');
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
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
              Expanded(
                child: _buildForm(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(255, 252, 95, 95),
            Color.fromARGB(255, 248, 109, 109),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFDA2C2D).withOpacity(0.2),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.09),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              Spacer(),
              Text(
                'Report Unsafe Area',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Spacer(),
              SizedBox(width: 44), // Balance the layout
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: Color(0xFFDA2C2D),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Help make the community safer by reporting areas you consider unsafe",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white,
                      height: 1.3,
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

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      physics: BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Location"),
          SizedBox(height: 8),
          _buildLocationSelector(),
          SizedBox(height: 20),
          _buildSectionTitle("Incident Date"),
          SizedBox(height: 8),
          _buildDateSelector(),
          SizedBox(height: 20),
          _buildSectionTitle("Description"),
          SizedBox(height: 8),
          _buildNoteField(),
          SizedBox(height: 20),
          _buildSectionTitle("Photo Evidence"),
          SizedBox(height: 8),
          _buildImageSelector(),
          SizedBox(height: 36),
          _buildSubmitButton(),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF2E3E5C),
      ),
    );
  }

  Widget _buildLocationSelector() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.withOpacity(0.3),
            ),
          ),
          child: TextField(
            controller: addressController,
            readOnly: true,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: Color(0xFF2E3E5C),
            ),
            decoration: InputDecoration(
              hintText: 'Select location on map',
              hintStyle: GoogleFonts.poppins(
                fontSize: 15,
                color: Colors.grey,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              suffixIcon: IconButton(
                icon: Icon(Icons.map_outlined, color: Color(0xFFDA2C2D)),
                onPressed: _getCurrentLocation,
              ),
            ),
          ),
        ),
        if (_currentPosition != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Lat: ${_currentPosition!.latitude.toStringAsFixed(4)}, Lng: ${_currentPosition!.longitude.toStringAsFixed(4)}',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Color(0xFF8F9BB3),
              ),
            ),
          ),
        SizedBox(height: 12),
        if (isSubmitting && _currentPosition == null)
          Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDA2C2D)),
            ),
          ),
        if (_currentPosition == null) _buildLocationHelp(),
      ],
    );
  }

  Widget _buildLocationHelp() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 20,
            color: Colors.grey[700],
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Please tap the map icon to select your current location",
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return InkWell(
      onTap: () => _selectDate(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('MMMM d, yyyy').format(selectedDate),
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: Color(0xFF2E3E5C),
              ),
            ),
            Icon(
              Icons.calendar_today_rounded,
              color: Color(0xFFDA2C2D),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
        ),
      ),
      child: TextField(
        controller: noteController,
        maxLines: 5,
        style: GoogleFonts.poppins(
          fontSize: 15,
          color: Color(0xFF2E3E5C),
        ),
        decoration: InputDecoration(
          hintText: 'Describe why this area is unsafe...',
          hintStyle: GoogleFonts.poppins(
            fontSize: 15,
            color: Colors.grey,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildImageSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_pickedImage != null)
          Container(
            height: 200,
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: FileImage(File(_pickedImage!.path)),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
        if (_pickedImage == null)
          Container(
            height: 170,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.photo_camera_outlined,
                  size: 50,
                  color: Colors.grey[500],
                ),
                SizedBox(height: 10),
                Text(
                  'Add photo evidence',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  'Optional',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: Icon(Icons.photo_library_outlined, size: 18),
              label: Text('Gallery'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Color.fromARGB(255, 233, 72, 72),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: _takePicture,
              icon: Icon(Icons.camera_alt_outlined, size: 18),
              label: Text('Camera'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Color(0xFF36B37E),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isSubmitting ? null : _submitReport,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Color.fromARGB(255, 243, 84, 84),
          padding: EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: Color(0xFFDA2C2D).withOpacity(0.6),
        ),
        child: isSubmitting
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Submit Report',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
