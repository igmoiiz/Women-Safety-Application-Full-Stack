import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:women_safety/services/firebase_auth/firebase_auth_methods.dart';
import 'package:women_safety/view/WelcomePage/welcome_page.dart';
import 'package:women_safety/view/bottomNavigationBar/bottom_navigationbar.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  static const int _autoLogoutTimeInMinutes = 5;
  static const String _lastActiveTimeKey = 'app_last_active_time';

  /// Checks if the session has timed out and logs out if necessary
  Future<void> _checkSessionTimeout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastActiveTimeMillis = prefs.getInt(_lastActiveTimeKey);

      if (lastActiveTimeMillis != null) {
        final lastActiveTime =
            DateTime.fromMillisecondsSinceEpoch(lastActiveTimeMillis);
        final now = DateTime.now();
        final inactivityDuration = now.difference(lastActiveTime);

        debugPrint('Last active: $lastActiveTime');
        debugPrint('Current time: $now');
        debugPrint('Inactive for: ${inactivityDuration.inMinutes} minutes');

        if (inactivityDuration.inMinutes >= _autoLogoutTimeInMinutes) {
          debugPrint('Session timeout reached - logging out user');

          // Only proceed if context is valid and mounted
          if (mounted) {
            // Use the navigator key to ensure we have a valid context
            await FirebaseAuthMethods().signOut(context);
          }
        } else {
          debugPrint('Session still valid');
        }
      } else {
        debugPrint('No last active time found');
      }
    } catch (e) {
      debugPrint('Error checking session timeout: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _checkSessionTimeout();
    // Create animation controller for fade-in effect
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);

    // Start the animation
    _animationController.forward();

    // Navigate to the appropriate screen after 3 seconds
    Timer(const Duration(seconds: 3), () {
      _navigateToNextScreen();
    });
  }

  Future<void> _navigateToNextScreen() async {
    // Check if user is logged in
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User is already logged in, navigate to home screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => BottomNavigationbarScreen()),
      );
    } else {
      // User is not logged in, navigate to welcome page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => WelcomePage()),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SvgPicture.asset(
            'assets/images/splash.svg',
            width: MediaQuery.of(context).size.width * 0.6,
            height: MediaQuery.of(context).size.height * 0.4,
          ),
        ),
      ),
    );
  }
}
