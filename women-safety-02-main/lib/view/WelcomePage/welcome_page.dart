import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:women_safety/utils/custom_color.dart';
import 'package:women_safety/utils/custom_text.dart';
import 'package:women_safety/utils/size.dart';
import 'package:women_safety/widgets/custom_button.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.whiteColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        handleTitle(context),
                        verticalSpace(33),
                        Image.asset(
                          'assets/images/welcome.png',
                          height: 199,
                          width: 280,
                        ),
                      ],
                    ),
                  ),
                ),
                CustomButton(
                  text: 'Login',
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                    // Navigator.pushNamed(context, '/bottomNavigation');
                  },
                ),
                verticalSpace(14),
                CustomButton(
                  text: 'Register',
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  color: Colors.white,
                ),
                verticalSpace(4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  SizedBox handleTitle(BuildContext context) {
    return SizedBox(
      height: 141,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 1,
            child: Text(
              'Welcome to',
              style: GoogleFonts.jomhuria(
                fontSize: screenWidth(context) * (2.6 / 15),
                // fontSize: 64,
                color: CustomColor.secondaryDarkColor,
              ),
            ),
          ),
          Positioned(
            bottom: 1,
            child: Text(
              "She's own safety",
              style: GoogleFonts.jomhuria(
                fontSize: screenWidth(context) * (2.5 / 15),
                // fontSize: 60,
                color: CustomColor.primaryPinkColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
