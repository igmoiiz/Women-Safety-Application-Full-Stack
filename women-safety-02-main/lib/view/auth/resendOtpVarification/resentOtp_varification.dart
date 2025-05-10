import 'package:flutter/material.dart';
import 'package:women_safety/utils/custom_color.dart';
import 'package:women_safety/utils/custom_text.dart';
import 'package:women_safety/utils/size.dart';
import 'package:women_safety/widgets/custom_back_button.dart';
import 'package:women_safety/widgets/custom_button.dart';
import 'package:women_safety/widgets/custom_textfield.dart';

class ResendOtpVarification extends StatefulWidget {
  const ResendOtpVarification({super.key});

  @override
  State<ResendOtpVarification> createState() => _ResendOtpVarificationState();
}

class _ResendOtpVarificationState extends State<ResendOtpVarification> {
  final TextEditingController _emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: CustomColor.whiteColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            children: [
              CustomBackButton(context),
              verticalSpace(34),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Email Verification',
                          style: CustomText.customUrbanist,
                        ),
                      ),
                      verticalSpace(14),
                      Text(
                        "Don't worry! It occurs. Please enter the email address linked with your account.",
                        style: CustomText.customUrbanist.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: CustomColor.lightGreyColor,
                        ),
                      ),
                      verticalSpace(34),
                      CustomTextField(
                          controller: _emailController,
                          hintText: 'Enter your email'),
                      verticalSpace(34),
                      CustomButton(text: 'Verify', onPressed: () {}),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
