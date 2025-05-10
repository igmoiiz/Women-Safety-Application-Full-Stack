// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:women_safety/models/onboarding_user_model.dart';
import 'package:women_safety/services/api/mongodb_api_service.dart';
import 'package:women_safety/utils/custom_toast.dart';
import 'package:women_safety/view/WelcomePage/welcome_page.dart';
import 'package:women_safety/view/auth/register/pages/page1/page1.dart';
import 'package:women_safety/view/auth/register/pages/page2/page2.dart';
import 'package:women_safety/view/auth/register/pages/page3/page3.dart';
import 'package:women_safety/widgets/loading_dialog.dart';

import '../../view/bottomNavigationBar/bottom_navigationbar.dart';

class FirebaseAuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final MongoDBApiService mongoDBService = MongoDBApiService();

  // Add a stream getter to expose the authentication state
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current user getter for convenience
  User? get currentUser => _auth.currentUser;

  /// [EMAIL LOGIN]
  ///
  Future<void> loginWithEmail({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        CustomToast.showSnackbar(context, 'Email and password cannot be empty');
        return;
      } else {
        // Show loading dialog before authentication
        showLoadingDialog(context, 'Logging in...');

        try {
          await _auth
              .signInWithEmailAndPassword(
            email: email,
            password: password,
          )
              .then((value) async {
            try {
              value.user!.reload();
              // Get user data from MongoDB
              final userData =
                  await mongoDBService.getUserData(value.user!.uid);

              if (userData != null) {
                SharedPreferences.getInstance().then((prefs) async {
                  await prefs.setString(
                      'phoneNumber', userData['emergencyPhoneNumber']);
                  await prefs.setString('email', userData['emergencyEmail']);
                  await prefs.setString('username', userData['username']);

                  // Handle savedPosts - MongoDB might return it differently
                  // List<String> savedPosts = [];
                  // if (userData['savedPosts'] != null) {
                  //   if (userData['savedPosts'] is List) {
                  //     savedPosts = List<String>.from(userData['savedPosts']);
                  //   }
                  // }
                  // await prefs.setStringList('savedPosts', savedPosts);

                  // Close loading dialog if it's still showing
                  Navigator.popUntil(context, (route) => route.isFirst);
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BottomNavigationbarScreen()));
                });
              } else {
                // Close loading dialog
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
                // Handle case where user exists in Firebase but not in MongoDB
                CustomToast.showSnackbar(
                    context, 'User data not found. Please contact support.');
                await _auth.signOut();
              }
            } catch (e) {
              // Close loading dialog
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
              CustomToast.showSnackbar(
                  context, 'Error loading user data: ${e.toString()}');
              await _auth.signOut();
            }
          });
        } on FirebaseAuthException catch (e) {
          // Close loading dialog
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          CustomToast.showSnackbar(
              context, e.message ?? 'Authentication failed');
        }
      }
    } catch (e) {
      // Close loading dialog
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      CustomToast.showSnackbar(context, e.toString());
    }
  }

  ///[ EMAIL SIGN UP]
  ///
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        CustomToast.showSnackbar(context, 'Email and password cannot be empty');
        return;
      } else {
        // Show loading dialog before authentication
        showLoadingDialog(context, 'Creating account...');

        try {
          await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
          // Process user registration instead of sending verification
          await processRegistration(context);
        } on FirebaseAuthException catch (e) {
          // Close loading dialog
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          // Clear all controllers on error
          _clearRegistrationControllers();

          Navigator.popUntil(context, (route) => route.isFirst);
          Navigator.pushReplacementNamed(context, '/');
          CustomToast.showSnackbar(
              context, e.message ?? 'Failed to create account');
        }
      }
    } catch (e) {
      // Close loading dialog
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      // Clear all controllers on error
      _clearRegistrationControllers();

      CustomToast.showSnackbar(context, e.toString());
    }
  }

  // Helper method to clear all registration controllers
  void _clearRegistrationControllers() {
    // Clear Page1 controllers
    firstNameController.clear();
    lastNameController.clear();
    fatherNameController.clear();
    cnicController.clear();
    genderController.clear();
    bloodGroupController.clear();

    // Clear Page2 controllers
    userNameController.clear();
    passwordController.clear();
    confirmPasswordController.clear();

    // Clear Page3 controllers
    phoneController.clear();
    emergencyPhoneController.clear();
    emailController.clear();
    emergencyEmailController.clear();
    addressController.clear();
  }

  /// Process user registration data
  Future<void> processRegistration(BuildContext context) async {
    try {
      Map<String, dynamic> userModel = OnboardingUserModel(
        fatherName: fatherNameController.text.trim(),
        cnic: cnicController.text.trim(),
        bloodGroup: bloodGroupController.text.trim(),
        username: userNameController.text.trim(),
        password: passwordController.text.trim(),
        phoneNumber: phoneController.text.trim(),
        emergencyPhoneNumber: emergencyPhoneController.text.trim(),
        email: emailController.text.trim(),
        emergencyEmail: emergencyEmailController.text.trim(),
        address: addressController.text.trim(),
      ).toMap();

      // Save user data to MongoDB
      final (bool mongodbSuccess, String message) =
          await mongoDBService.addUser(userModel, _auth.currentUser!.uid);

      if (!mongodbSuccess) {
        // Close loading dialog
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        // Clear controllers on error
        _clearRegistrationControllers();

        CustomToast.showSnackbar(context, message);
        deleteAccount(context);
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      } else {
        SharedPreferences.getInstance().then((prefs) async {
          await prefs.setString(
              'phoneNumber', emergencyPhoneController.text.trim());
          await prefs.setString('email', emergencyEmailController.text.trim());
          await prefs.setString('username', userNameController.text.trim());
          await prefs.setStringList('savedPosts', []);

          // Clear registration controllers after successful registration
          _clearRegistrationControllers();

          // Close loading dialog
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }

          Navigator.pushNamedAndRemoveUntil(
            context,
            '/bottomNavigation',
            (route) => false,
          );
        });
      }
    } catch (e) {
      // Close loading dialog
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      // Clear controllers on error
      _clearRegistrationControllers();

      CustomToast.showSnackbar(context, e.toString());
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }

  ///[ EMAIL VERIFICATION]
  ///
  // Keeping this method in case you need it in the future
  Future<void> sendEmailVerification(BuildContext context, String email) async {
    try {
      await _auth.currentUser!.sendEmailVerification();
      CustomToast.showSnackbar(
          context, 'Email verification sent!. Open your email $email');

      // The rest of this method is now handled by processRegistration
      // ...existing code...
    } on FirebaseAuthException catch (e) {
      CustomToast.showSnackbar(context, e.message!);
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  /// [FORGOT PASSWORD]
  ///
  Future<void> forgotPassword({
    required String email,
    required BuildContext context,
  }) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      CustomToast.showSnackbar(context, 'Password reset email sent!');
    } on FirebaseAuthException catch (e) {
      CustomToast.showSnackbar(context, e.message!);
    }
  }

  ///[ DELETE ACCOUNT]
  ///
  Future<void> deleteAccount(BuildContext context) async {
    try {
      await _auth.currentUser!.delete();
    } on FirebaseAuthException catch (e) {
      CustomToast.showSnackbar(context, e.message!);
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      await SharedPreferences.getInstance().then((prefs) async {
        await prefs.remove('phoneNumber');
        await prefs.remove('email');
        await prefs.remove('username');
        // await prefs.remove('savedPosts');
        await prefs.remove('lastActiveTime');
      });

      // Replace the navigation logic with a more reliable approach
      // that works for both manual logout and auto-logout
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => WelcomePage()),
        (route) => false, // Remove all previous routes
      );
    } on FirebaseAuthException catch (e) {
      CustomToast.showSnackbar(context, e.message!);
    }
  }
}
