import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:women_safety/utils/custom_color.dart';

class CustomText {
  /// [----welcome page----]
  ///
  static final TextStyle customJomhuriaBlack = GoogleFonts.jomhuria(
    fontSize: 64,
    color: CustomColor.secondaryDarkColor,
  );
  static final TextStyle customJomhuriaPink = GoogleFonts.jomhuria(
    fontSize: 60,
    color: CustomColor.primaryPinkColor,
  );

  /// [----login page----]
  ///
  static final TextStyle customUrbanist = GoogleFonts.urbanist(
    fontSize: 30,
    fontWeight: FontWeight.w700,
  );

  static final TextStyle sourceSansPro = GoogleFonts.sourceSans3(
    color: Color(0xFFDA2C2D),
    fontSize: 25,
    fontWeight: FontWeight.w700,
  );

  // static const TextStyle heading1 = TextStyle(
  //   fontSize: 24,
  //   fontWeight: FontWeight.bold,
  //   color: Colors.black,
  // );

  // static const TextStyle heading2 = TextStyle(
  //   fontSize: 20,
  //   fontWeight: FontWeight.bold,
  //   color: Colors.black,
  // );

  // static const TextStyle bodyText = TextStyle(
  //   fontSize: 16,
  //   fontWeight: FontWeight.normal,
  //   color: Colors.black,
  // );

  // static const TextStyle caption = TextStyle(
  //   fontSize: 12,
  //   fontWeight: FontWeight.normal,
  //   color: Colors.grey,
  // );
}
