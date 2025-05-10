import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class MongoDBApiService {
  // Base URL of the Express API
  // final String baseUrl = 'https://bm6vbp62-3000.inc1.devtunnels.ms/api';
  final String baseUrl =
      'https://womensafetyapis-production.up.railway.app/api';

  // Save user data to MongoDB
  Future<(bool, String)> addUser(
      Map<String, dynamic> userData, String firebaseUid) async {
    try {
      // Create a new map with all user data plus the Firebase UID
      final Map<String, dynamic> completeUserData = {
        ...userData,
        'firebaseUid': firebaseUid,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(completeUserData),
      );

      // Parse response as JSON
      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 201 && responseBody['success'] == true) {
        log('User successfully saved to MongoDB');
        return (true, 'User created successfully');
      } else {
        log('Failed to save user to MongoDB: ${response.body}');
        return (false, 'Failed to save user data');
      }
    } catch (e) {
      log('Exception when saving user to MongoDB: $e');
      return (false, 'Exception occurred while saving user data');
    }
  }

  // Get user data from MongoDB
  Future<Map<String, dynamic>?> getUserData(String firebaseUid) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$firebaseUid'),
      );

      // Parse response as JSON
      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == true) {
        // Return the data field which contains the actual user data
        return responseBody['data'];
      } else {
        log('Failed to get user data: ${response.body}');
        return null;
      }
    } catch (e) {
      log('Exception when getting user data: $e');
      return null;
    }
  }

  // Update user data in MongoDB
  Future<(bool, String)> updateUserData(
      Map<String, dynamic> userData, String firebaseUid) async {
    try {
      // Get existing user data first to avoid overwriting other fields
      final existingData = await getUserData(firebaseUid);
      if (existingData == null) {
        return (false, 'User not found');
      }

      // Only update the fields provided in userData
      final response = await http.put(
        Uri.parse('$baseUrl/users/$firebaseUid'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
            userData), // Only sending the fields that need to be updated
      );

      // Parse response as JSON
      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == true) {
        log('MongoDB > ${responseBody['message']}');
        return (true, 'User data updated successfully');
      } else {
        log('MongoDB > ${responseBody['message']}');
        return (false, 'Failed to update user data');
      }
    } catch (e) {
      log('Exception when updating user data in MongoDB: $e');
      return (false, 'Exception occurred while updating user data');
    }
  }
}
