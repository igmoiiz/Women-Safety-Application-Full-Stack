import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:women_safety/services/firebase_auth/firebase_auth_methods.dart';
import 'package:women_safety/utils/custom_color.dart';
import 'package:women_safety/utils/custom_text.dart';
import 'package:women_safety/utils/size.dart';
import 'package:women_safety/widgets/custom_back_button.dart';
import 'package:women_safety/widgets/custom_button.dart';
import 'package:women_safety/widgets/custom_textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final alphanumericFormatter =
      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]'));

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
                      Text(
                        'Welcome back! Glad to see you, Again!',
                        style: CustomText.customUrbanist,
                      ),
                      verticalSpace(34),
                      CustomTextField(
                          controller: emailController,
                          hintText: 'Enter your email'),
                      verticalSpace(24),
                      CustomTextField(
                        controller: passwordController,
                        hintText: 'Enter your password',
                        isPassword: true,
                        inputFormatters: [alphanumericFormatter],
                      ),
                      verticalSpace(14),
                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/forgotPassword');
                          },
                          child: Text(
                            'Forgot Password?',
                            style: CustomText.customUrbanist.copyWith(
                                fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      verticalSpace(24),
                      CustomButton(
                          text: 'Login',
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            FirebaseAuthMethods().loginWithEmail(
                              email: emailController.text.trim(),
                              password: passwordController.text.trim(),
                              context: context,
                            );
                          }),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Don\'t have an account?',
                    style: CustomText.customUrbanist.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: Text(
                      ' Register Now',
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
