// ignore_for_file: unused_local_variable

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:women_safety/utils/public_washroom.dart';

class RedAreaRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Helper method to extract city from address string
  String _extractCityFromAddress(String? address) {
    if (address == null || address.isEmpty) return 'Unknown city';

    List<String> parts = address.split(',');
    if (parts.isNotEmpty) {
      String lastPart = parts.last.trim();
      return lastPart.isNotEmpty ? lastPart : 'Unknown city';
    }
    return 'Unknown city';
  }

  // Stream that provides real-time updates of red areas from Firestore
  Stream<List<PublicWashroom>> getRedAreasStream() {
    return _firestore
        .collection('redArea')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();

        // Extract location data
        Map<String, dynamic> location = data['location'] ?? {};

        // Handle the case when imageUrl is not a string (it could be a File object from report screen)
        String imageUrl = 'no_image';
        if (data['imageUrl'] != null && data['imageUrl'] is String) {
          imageUrl = data['imageUrl'];
        }

        // Create a new PublicWashroom object from the Firestore data
        return PublicWashroom(
          id: doc.id,
          name: data['note'] ?? 'Unsafe Area',
          latitude: location['latitude'] ?? 0.0,
          longitude: location['longitude'] ?? 0.0,
          address: location['address'] ?? 'Unknown location',
          city: _extractCityFromAddress(location['address']),
          isVerified: false, // Red areas are unsafe by definition
          type: 'red_area',
          rating: 1.0, // Low rating for unsafe areas
          description: data['note'],
        );
      }).toList();
    });
  }

  // Single fetch method if needed
  Future<List<PublicWashroom>> getRedAreas() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('redArea')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Extract location data
        Map<String, dynamic> location = data['location'] ?? {};

        return PublicWashroom(
          id: doc.id,
          name: data['note'] ?? 'Unsafe Area',
          latitude: location['latitude'] ?? 0.0,
          longitude: location['longitude'] ?? 0.0,
          address: location['address'] ?? 'Unknown location',
          city: _extractCityFromAddress(location['address']),
          isVerified: false,
          type: 'red_area',
          rating: 1.0,
          description: data['note'],
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching red areas: $e');
      return [];
    }
  }
}
