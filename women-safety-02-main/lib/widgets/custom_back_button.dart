import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Align CustomBackButton(BuildContext context) {
  return Align(
    alignment: Alignment.centerLeft,
    child: GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: SizedBox(
        width: 40,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Icon(
            CupertinoIcons.back,
            size: 26,
          ),
        ),
      ),
    ),
  );
}
