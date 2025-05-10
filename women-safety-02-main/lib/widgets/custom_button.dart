import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:women_safety/utils/custom_color.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;

  const CustomButton({
    Key? key,
    required this.text,
    this.color,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 1,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: (color == null)
              ? Color.fromARGB(255, 224, 153, 174)
              : Colors.white,
          minimumSize: Size(200, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: (color != null)
                  ? CustomColor.secondaryDarkColor
                  : Colors.transparent,
              width: 1,
            ),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: GoogleFonts.urbanist(
            color: (color == null) ? CustomColor.whiteColor : Colors.black,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
