import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:women_safety/utils/custom_color.dart';

/// Shows an improved loading dialog with animated spinner and message
void showLoadingDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black45,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.white,
        elevation: 10.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 27),
          child: Row(
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(seconds: 1),
                builder: (context, value, _) => Container(
                  width: 15,
                  height: 15,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      CustomColor.primaryPinkColor,
                    ),
                    strokeWidth: 2.0,
                  ),
                ),
                child: null,
              ),
              const SizedBox(width: 12),

              // Message text with animation
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.8, end: 1.0),
                duration: const Duration(milliseconds: 400),
                builder: (context, value, child) => Transform.scale(
                  scale: value,
                  child: child,
                ),
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Shows a custom loading dialog with a branded look
void showBrandedLoadingDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black54,
    builder: (BuildContext context) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 40),
        backgroundColor: Colors.white,
        elevation: 12.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.0),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.pink.shade50,
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // App logo or icon could be added here
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: CustomColor.primaryPinkColor.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      CustomColor.primaryPinkColor,
                    ),
                    strokeWidth: 4.0,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                message,
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),
              LinearProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  CustomColor.primaryPinkColor,
                ),
                backgroundColor: Colors.grey,
              ),
              const SizedBox(height: 8),

              // You could show elapsed time or other information here
              const Text(
                "This may take a moment",
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    },
  );
}
