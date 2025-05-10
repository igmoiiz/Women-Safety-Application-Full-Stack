import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:women_safety/utils/custom_text.dart';
import 'package:women_safety/utils/size.dart';
import 'package:women_safety/widgets/custom_textfield.dart';

final userNameController = TextEditingController();
final passwordController = TextEditingController();
final confirmPasswordController = TextEditingController();

class Page2 extends StatefulWidget {
  const Page2({super.key});

  @override
  State<Page2> createState() => Page2State();
}

class Page2State extends State<Page2> {
  final userNameFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();
  final confirmPasswordFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  // Error states
  String? userNameError;
  String? passwordError;
  String? confirmPasswordError;

  final alphanumericFormatter =
      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]'));

  final passwordFormatter = FilteringTextInputFormatter.allow(
      RegExp(r'[a-zA-Z0-9!@#$%^&*(),.?":{}|<>]'));

  @override
  void initState() {
    super.initState();
    userNameFocusNode
        .addListener(() => _scrollToFocusedField(userNameFocusNode));
    passwordFocusNode
        .addListener(() => _scrollToFocusedField(passwordFocusNode));
    confirmPasswordFocusNode
        .addListener(() => _scrollToFocusedField(confirmPasswordFocusNode));
  }

  @override
  void dispose() {
    userNameFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToFocusedField(FocusNode focusNode) {
    if (focusNode.hasFocus) {
      _scrollController.animateTo(
        _scrollController.position.pixels + 100,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Method to validate the form fields
  bool validateFields() {
    bool isValid = true;

    // Reset all error states
    setState(() {
      userNameError = null;
      passwordError = null;
      confirmPasswordError = null;
    });

    // Validate username
    if (userNameController.text.isEmpty) {
      setState(() {
        userNameError = 'Username is required';
      });
      isValid = false;
    }

    // Validate password
    if (passwordController.text.isEmpty) {
      setState(() {
        passwordError = 'Password is required';
      });
      isValid = false;
    } else if (passwordController.text.trim().length < 8) {
      setState(() {
        passwordError = 'Password must be at least 8 characters long';
      });
      isValid = false;
    } else if (!RegExp(r'(?=.*[A-Z])').hasMatch(passwordController.text)) {
      setState(() {
        passwordError = 'Password must contain at least one uppercase letter';
      });
      isValid = false;
    } else if (!RegExp(r'(?=.*[a-z])').hasMatch(passwordController.text)) {
      setState(() {
        passwordError = 'Password must contain at least one lowercase letter';
      });
      isValid = false;
    } else if (!RegExp(r'(?=.*[0-9])').hasMatch(passwordController.text)) {
      setState(() {
        passwordError = 'Password must contain at least one number';
      });
      isValid = false;
    }

    // Validate confirm password
    if (confirmPasswordController.text.isEmpty) {
      setState(() {
        confirmPasswordError = 'Please confirm your password';
      });
      isValid = false;
    } else if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        confirmPasswordError = 'Passwords do not match';
      });
      isValid = false;
    }

    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Hello! Register to get started',
                    style: CustomText.customUrbanist.copyWith(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  verticalSpace(24),
                  CustomTextField(
                    controller: userNameController,
                    hintText: 'Username*',
                    focusNode: userNameFocusNode,
                    errorText: userNameError,
                    onEditingComplete: () => FocusScope.of(context).nextFocus(),
                    inputFormatters: [alphanumericFormatter],
                  ),
                  verticalSpace(10),
                  CustomTextField(
                    controller: passwordController,
                    hintText: 'Password*',
                    focusNode: passwordFocusNode,
                    errorText: passwordError,
                    onEditingComplete: () => FocusScope.of(context).nextFocus(),
                    isPassword: true,
                    inputFormatters: [passwordFormatter],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4.0, vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Min 8 chars • 1 uppercase • 1 lowercase • 1 number',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  CustomTextField(
                    controller: confirmPasswordController,
                    hintText: 'Confirm Password*',
                    focusNode: confirmPasswordFocusNode,
                    errorText: confirmPasswordError,
                    onEditingComplete: () => FocusScope.of(context).nextFocus(),
                    isPassword: true,
                    inputFormatters: [passwordFormatter],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
