import 'package:flutter/material.dart';

class CustomToast {
  static void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showToast(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 50,
        left: 0,
        right: 0,
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              message,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    Future.delayed(Duration(seconds: 2), () {
      entry.remove();
    });
  }
}
