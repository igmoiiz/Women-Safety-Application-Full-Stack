import 'package:flutter/material.dart';
import 'package:women_safety/utils/custom_text.dart';
import 'package:women_safety/view/auth/register/pages/page1/page1.dart';
import 'package:women_safety/view/auth/register/pages/page2/page2.dart';
import 'package:women_safety/view/auth/register/pages/page3/page3.dart';
import 'package:women_safety/widgets/custom_button.dart';

class Success extends StatefulWidget {
  const Success({super.key});

  @override
  State<Success> createState() => _SuccessState();
}

class _SuccessState extends State<Success> {
  @override
  void initState() {
    super.initState();
    // Clear all controllers when success screen is shown
    _clearAllControllers();
  }

  // Method to clear all controllers
  void _clearAllControllers() {
    // Clear Page1 controllers
    firstNameController.clear();
    lastNameController.clear();
    fatherNameController.clear();
    cnicController.clear();
    genderController.clear();
    bloodGroupController.clear();

    // Clear Page2 controllers
    userNameController.clear();
    passwordController.clear();
    confirmPasswordController.clear();

    // Clear Page3 controllers
    phoneController.clear();
    emergencyPhoneController.clear();
    emailController.clear();
    emergencyEmailController.clear();
    addressController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(width: 100, image: AssetImage('assets/images/success.png')),
              SizedBox(height: 20),
              Text(
                'Registration Successful',
                style: CustomText.customUrbanist.copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 34),
              CustomButton(
                  text: 'Back to Login',
                  onPressed: () {
                    // Clear controllers again just to be safe
                    _clearAllControllers();
                    Navigator.popUntil(context, (route) => route.isFirst);
                    Navigator.pushNamed(context, '/login');
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
