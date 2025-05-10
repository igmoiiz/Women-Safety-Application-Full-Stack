import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:women_safety/firebase_options.dart';
import 'package:women_safety/utils/custom_color.dart';
import 'package:geolocator/geolocator.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Channel for communication with native code
const platform = MethodChannel('com.example.women_safety/whatsapp');

Future<void> initializeAppServices() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _checkLocationPermission();
  _setupSystemUI();
  await _initializeNotifications();
  await initializeService();
}

void _setupSystemUI() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
}

Future<void> _initializeNotifications() async {
  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('ic_bg_service_small'),
      iOS: DarwinInitializationSettings(),
    ),
    onDidReceiveNotificationResponse: (response) async {
      await handleNotificationClick();
    },
  );
}

Future<void> handleNotificationClick() async {
  try {
    // First check if location permission is granted
    var permissionStatus = await Permission.location.status;
    if (!permissionStatus.isGranted) {
      permissionStatus = await Permission.location.request();
      if (!permissionStatus.isGranted) {
        return; // Exit if permission not granted
      }
    }

    // Then check if location service is enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Request to enable location service
      serviceEnabled = await Geolocator.openLocationSettings();
      if (!serviceEnabled) {
        return; // Exit if location service not enabled
      }
    }

    // Only proceed to open WhatsApp if both permission and service are enabled
    await platform.invokeMethod('launchWhatsApp');
  } catch (e) {
    debugPrint('Error handling notification click: $e');
  }
}

Future<void> _checkLocationPermission() async {
  var status = await Permission.location.status;
  if (!status.isGranted) {
    status = await Permission.location.request();
    debugPrint(status.isGranted
        ? "Location permission granted"
        : "Location permission not granted");
  }
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground',
    'MY FOREGROUND SERVICE',
    description: 'This channel is used for important notifications.',
    importance: Importance.low,
  );

  if (Platform.isIOS || Platform.isAndroid) {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'AWESOME SERVICE',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: 888,
      foregroundServiceTypes: [AndroidForegroundType.location],
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  Timer.periodic(const Duration(seconds: 1), (timer) async {
    await _updateNotification();

    service.invoke('update', {
      "current_date": DateTime.now().toIso8601String(),
      "device": Platform.operatingSystem,
    });
  });
}

Future<void> _updateNotification() async {
  await flutterLocalNotificationsPlugin.show(
    888,
    'Background Service',
    'Running',
    NotificationDetails(
      android: AndroidNotificationDetails(
        'my_foreground',
        'MY FOREGROUND SERVICE',
        channelDescription: 'This channel is used for important notifications.',
        icon: 'ic_bg_service_small',
        ongoing: true,
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction(
            'whatsapp',
            'Open WhatsApp',
            showsUserInterface: true,
            cancelNotification: false,
          ),
        ],
      ),
    ),
    payload: 'whatsapp',
  );
}
