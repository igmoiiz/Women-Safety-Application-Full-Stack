// ignore_for_file: unused_local_variable

import 'dart:developer';
import 'dart:io';
import 'package:android_intent_plus/android_intent.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/services.dart';

class BatteryOptimizationUtil {
  static const MethodChannel _channel =
      MethodChannel('battery_optimization_channel');

  /// Requests the user to disable battery optimizations for the app
  static Future<void> requestIgnoreBatteryOptimizations() async {
    if (Platform.isAndroid) {
      try {
        final PackageInfo packageInfo = await PackageInfo.fromPlatform();
        final String packageName = packageInfo.packageName;

        // Check if already ignoring battery optimizations
        bool isIgnoring = await isIgnoringBatteryOptimizations();
        if (!isIgnoring) {
          final AndroidIntent intent = AndroidIntent(
            action: 'android.settings.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS',
            data: 'package:$packageName',
          );
          await intent.launch();
        }
      } catch (e) {
        log('Failed to request battery optimization exemption: $e');
      }
    }
  }

  /// Checks if battery optimizations are currently disabled for the app
  static Future<bool> isIgnoringBatteryOptimizations() async {
    if (!Platform.isAndroid) return true; // iOS doesn't need this check

    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String packageName = packageInfo.packageName;

      final AndroidIntent intent = AndroidIntent(
        action: 'android.settings.IGNORE_BATTERY_OPTIMIZATION_SETTINGS',
        data: 'package:$packageName',
        arguments: {'extra_package_name': packageName},
      );

      // Use method channel to check if battery optimization is disabled
      final bool isIgnoring =
          await _channel.invokeMethod('isIgnoringBatteryOptimization', {
        'packageName': packageName,
      }).catchError((_) => false);

      return isIgnoring;
    } catch (e) {
      log('Error checking battery optimization status: $e');
      return false;
    }
  }

  /// Opens battery optimization settings directly
  static Future<void> openBatteryOptimizationSettings() async {
    if (Platform.isAndroid) {
      final AndroidIntent intent = AndroidIntent(
        action: 'android.settings.BATTERY_SAVER_SETTINGS',
      );
      await intent.launch();
    }
  }

  /// Request all possible optimizations to keep the service alive
  static Future<void> requestAllBatteryOptimizations() async {
    if (Platform.isAndroid) {
      await requestIgnoreBatteryOptimizations();

      // Request don't kill my app setting (for some manufacturers)
      try {
        await _requestManufacturerSpecificSettings();
      } catch (e) {
        log('Error requesting manufacturer-specific settings: $e');
      }
    }
  }

  static Future<void> _requestManufacturerSpecificSettings() async {
    // This would require implementation in native code through a method channel
    // Basic implementation to handle manufacturer-specific settings
    try {
      await _channel.invokeMethod('requestManufacturerSpecificSettings');
    } catch (e) {
      log('Manufacturer-specific settings not available: $e');
    }
  }
}
