import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:women_safety/bloc/bottomNavigation/bloc/bottom_navigation_bloc.dart';
import 'package:women_safety/services/firebase_auth/firebase_auth_methods.dart';
import 'package:women_safety/services/maps/location_service.dart';
import 'package:women_safety/view/bottomNavigationBar/custom_bottom_navigation_bar.dart';
import 'package:women_safety/view/bottomNavigationBar/tabs/PostingScreen/Posting_screen.dart';
import 'package:women_safety/view/bottomNavigationBar/tabs/ChatScreen/chat_screen.dart';
import 'package:women_safety/view/bottomNavigationBar/tabs/homeScreen/home_screen.dart';
import 'package:women_safety/view/bottomNavigationBar/tabs/ProfileScreen/Profile_screen.dart';
import 'package:women_safety/view/bottomNavigationBar/tabs/SosScreen/sos_screen.dart';

class BottomNavigationbarScreen extends StatefulWidget {
  const BottomNavigationbarScreen({super.key});

  @override
  State<BottomNavigationbarScreen> createState() =>
      _BottomNavigationbarScreenState();
}

class _BottomNavigationbarScreenState extends State<BottomNavigationbarScreen>
    with WidgetsBindingObserver {
  late BottomNavigationBloc _bottomNavigationBloc;
  DateTime? _lastBackPressTime;
  static const int _autoLogoutTimeInMinutes = 5;
  static const String _lastActiveTimeKey = 'app_last_active_time';

  @override
  void initState() {
    super.initState();
    _bottomNavigationBloc = BottomNavigationBloc();
    LocationService().checkLocationPermissions();

    // Register for app lifecycle changes
    WidgetsBinding.instance.addObserver(this);

    // Set current time as last active time
    _updateLastActiveTime();

    // Check for session timeout immediately when app starts
    _checkSessionTimeout();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    debugPrint('App lifecycle state changed to: $state');

    if (state == AppLifecycleState.resumed) {
      debugPrint('App resumed - checking session timeout');
      _checkSessionTimeout();

      // Update last active time after checking timeout
      _updateLastActiveTime();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      debugPrint('App going to background - updating last active time');
      _updateLastActiveTime();
    }
  }

  /// Updates the timestamp of when the app was last active
  Future<void> _updateLastActiveTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now().millisecondsSinceEpoch;
      await prefs.setInt(_lastActiveTimeKey, now);
      debugPrint('Last active time updated: ${DateTime.now()}');
    } catch (e) {
      debugPrint('Error updating last active time: $e');
    }
  }

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
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        extendBody:
            true, // This allows content to display behind the bottom nav
        body: SafeArea(
          child: BlocProvider(
            create: (context) => _bottomNavigationBloc,
            child: BlocBuilder<BottomNavigationBloc, BottomNavigationState>(
              builder: (context, state) {
                int currentIndex = 0;
                Widget currentScreen = HomeScreen();

                if (state is HomeIconState) {
                  currentIndex = 0;
                  currentScreen = HomeScreen();
                } else if (state is AddIconState) {
                  currentIndex = 1;
                  currentScreen = PostingScreen();
                } else if (state is SOSIconState) {
                  currentIndex = 2;
                  currentScreen = SOSScreen();
                } else if (state is BubbleIconState) {
                  currentIndex = 3;
                  currentScreen = ChatScreen();
                } else if (state is PersonIconState) {
                  currentIndex = 4;
                  currentScreen = ProfileScreen();
                }

                return currentScreen;
              },
            ),
          ),
        ),
        bottomNavigationBar: BlocProvider(
          create: (context) => _bottomNavigationBloc,
          child: BlocBuilder<BottomNavigationBloc, BottomNavigationState>(
            builder: (context, state) {
              int currentIndex = 0;

              if (state is HomeIconState) {
                currentIndex = 0;
              } else if (state is AddIconState) {
                currentIndex = 1;
              } else if (state is SOSIconState) {
                currentIndex = 2;
              } else if (state is BubbleIconState) {
                currentIndex = 3;
              } else if (state is PersonIconState) {
                currentIndex = 4;
              }

              return CustomBottomNavigationBar(currentIndex: currentIndex);
            },
          ),
        ),
      ),
    );
  }

  // Handle back button press
  Future<bool> _onWillPop() async {
    // Get the current state to determine which tab is active
    final currentState = _bottomNavigationBloc.state;

    // If we're not on the home tab, navigate to home instead of exiting the app
    if (!(currentState is HomeIconState)) {
      _bottomNavigationBloc.add(HomeIconTapped());
      return false; // Prevents app from exiting
    }

    // If we're on the home tab, implement double tap to exit feature
    if (_lastBackPressTime == null ||
        DateTime.now().difference(_lastBackPressTime!) > Duration(seconds: 2)) {
      // First tap or more than 2 seconds since last tap
      _lastBackPressTime = DateTime.now();

      // Show toast or snackbar to inform user to tap again to exit
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
        ),
      );

      return false; // Prevents app from exiting
    }

    // User tapped back twice within 2 seconds, exit the app
    return true;
  }
}
