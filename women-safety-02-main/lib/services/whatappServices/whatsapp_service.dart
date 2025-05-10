import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';

class WhatsAppService {
  final String phoneNumber;
  final String message;
  final BuildContext context;

  WhatsAppService(
      {required this.phoneNumber,
      required this.message,
      required this.context});

  Future<void> sendWhatsAppMessage() async {
    String androidUrl = "whatsapp://send?phone=$phoneNumber&text=$message";
    // String androidUrl = "whatsapp://send?phone=$phoneNumber&text=$message";
    String iosUrl = "https://wa.me/$phoneNumber?text=${Uri.parse(message)}";
    String webUrl = 'https://api.whatsapp.com/send/?phone=$phoneNumber&text=hi';
    try {
      if (Platform.isIOS) {
        if (await canLaunchUrl(Uri.parse(iosUrl))) {
          await launchUrl(Uri.parse(iosUrl));
        }
      } else {
        if (await canLaunchUrl(Uri.parse(androidUrl))) {
          await launchUrl(Uri.parse(androidUrl));
        }
      }
    } catch (e) {
      await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);
    }
  }
}
