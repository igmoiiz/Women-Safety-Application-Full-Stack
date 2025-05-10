import 'package:flutter/material.dart';
import 'package:women_safety/services/firebase_auth/firebase_auth_methods.dart';
import 'package:women_safety/utils/custom_color.dart';
import 'package:women_safety/utils/custom_text.dart';
import 'package:women_safety/utils/custom_toast.dart';
import 'package:women_safety/utils/size.dart';
import 'package:women_safety/widgets/custom_back_button.dart';
import 'package:women_safety/widgets/custom_button.dart';
import 'package:women_safety/widgets/custom_textfield.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
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
                          'Forgot Password?',
                          style: CustomText.customUrbanist,
                        ),
                      ),
                      verticalSpace(14),
                      Text(
                        "Don't worry! It occurs. Please enter the email address linked with your account.",
                        style: CustomText.customUrbanist.copyWith(
                          fontSize: 15.7,
                          fontWeight: FontWeight.w500,
                          color: CustomColor.lightGreyColor,
                        ),
                      ),
                      verticalSpace(34),
                      CustomTextField(
                          controller: _emailController,
                          hintText: 'Enter your email'),
                      verticalSpace(34),
                      CustomButton(
                        text: 'Send Code',
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          if (_emailController.text.isEmpty) {
                            CustomToast.showSnackbar(
                                context, 'Email cannot be empty');
                          } else {
                            FirebaseAuthMethods().forgotPassword(
                              email: _emailController.text,
                              context: context,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Remember password?',
                    style: CustomText.customUrbanist.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: CustomColor.lightGreyColor,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: Text(
                      ' Login',
                      style: CustomText.customUrbanist.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: CustomColor.primaryPinkColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
