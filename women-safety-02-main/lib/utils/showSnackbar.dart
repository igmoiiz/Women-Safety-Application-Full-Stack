import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';

void showFailureSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    content: AwesomeSnackbarContent(
      title: 'Hi There!',
      message: text,
      contentType: ContentType.failure,
    ),
  ));
}

void showSuccessSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    content: AwesomeSnackbarContent(
      title: 'Hi There!',
      message: text,
      contentType: ContentType.success,
    ),
  ));
}
