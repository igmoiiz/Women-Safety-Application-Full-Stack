import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:women_safety/utils/custom_text.dart';
import 'package:women_safety/utils/size.dart';
import 'package:women_safety/widgets/custom_textfield.dart';

final TextEditingController phoneController = TextEditingController();
final TextEditingController emergencyPhoneController = TextEditingController();
final TextEditingController emailController = TextEditingController();
final TextEditingController emergencyEmailController = TextEditingController();
final TextEditingController addressController = TextEditingController();

class Page3 extends StatefulWidget {
  const Page3({super.key});

  @override
  State<Page3> createState() => Page3State();
}

// Changed from _Page3State to Page3State (removing underscore to make it public)
class Page3State extends State<Page3> {
  final phoneFocusNode = FocusNode();
  final emergencyPhoneFocusNode = FocusNode();
  final emailFocusNode = FocusNode();
  final emergencyEmailFocusNode = FocusNode();
  final addressFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  // Error states
  String? phoneError;
  String? emergencyPhoneError;
  String? emailError;
  String? emergencyEmailError;
  String? addressError;

  final phoneFormatter = FilteringTextInputFormatter.digitsOnly;

  @override
  void initState() {
    super.initState();
    phoneFocusNode.addListener(() => _scrollToFocusedField(phoneFocusNode));
    emergencyPhoneFocusNode
        .addListener(() => _scrollToFocusedField(emergencyPhoneFocusNode));
    emailFocusNode.addListener(() => _scrollToFocusedField(emailFocusNode));
    emergencyEmailFocusNode
        .addListener(() => _scrollToFocusedField(emergencyEmailFocusNode));
    addressFocusNode.addListener(() => _scrollToFocusedField(addressFocusNode));
  }

  @override
  void dispose() {
    phoneFocusNode.dispose();
    emergencyPhoneFocusNode.dispose();
    emailFocusNode.dispose();
    emergencyEmailFocusNode.dispose();
    addressFocusNode.dispose();
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

  // Email validation regex
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Method to validate the form fields
  bool validateFields() {
    bool isValid = true;

    // Reset all error states
    setState(() {
      phoneError = null;
      emergencyPhoneError = null;
      emailError = null;
      emergencyEmailError = null;
      addressError = null;
    });

    // Validate phone number
    if (phoneController.text.isEmpty) {
      setState(() {
        phoneError = 'Phone number is required';
      });
      isValid = false;
    } else if (phoneController.text.length != 11) {
      setState(() {
        phoneError = 'Phone number must be 11 digits';
      });
      isValid = false;
    }

    // Validate emergency phone number
    if (emergencyPhoneController.text.isEmpty) {
      setState(() {
        emergencyPhoneError = 'Emergency phone number is required';
      });
      isValid = false;
    } else if (emergencyPhoneController.text.length != 11) {
      setState(() {
        emergencyPhoneError = 'Emergency phone number must be 11 digits';
      });
      isValid = false;
    } else if (phoneController.text == emergencyPhoneController.text) {
      setState(() {
        emergencyPhoneError = 'Cannot be the same as your phone number';
      });
      isValid = false;
    }

    // Validate email
    if (emailController.text.isEmpty) {
      setState(() {
        emailError = 'Email is required';
      });
      isValid = false;
    } else if (!_isValidEmail(emailController.text)) {
      setState(() {
        emailError = 'Please enter a valid email address';
      });
      isValid = false;
    }

    // Validate emergency email
    if (emergencyEmailController.text.isEmpty) {
      setState(() {
        emergencyEmailError = 'Emergency email is required';
      });
      isValid = false;
    } else if (!_isValidEmail(emergencyEmailController.text)) {
      setState(() {
        emergencyEmailError = 'Please enter a valid email address';
      });
      isValid = false;
    } else if (emailController.text == emergencyEmailController.text) {
      setState(() {
        emergencyEmailError = 'Cannot be the same as your email';
      });
      isValid = false;
    }

    // Validate address
    if (addressController.text.isEmpty) {
      setState(() {
        addressError = 'Address is required';
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
                    controller: phoneController,
                    hintText: 'Phone No*',
                    focusNode: phoneFocusNode,
                    errorText: phoneError,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [phoneFormatter],
                    maxLength: 11,
                    onEditingComplete: () => FocusScope.of(context).nextFocus(),
                  ),
                  verticalSpace(10),
                  CustomTextField(
                    controller: emergencyPhoneController,
                    hintText: 'Emergency Phone No*',
                    focusNode: emergencyPhoneFocusNode,
                    errorText: emergencyPhoneError,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [phoneFormatter],
                    maxLength: 11,
                    onEditingComplete: () => FocusScope.of(context).nextFocus(),
                  ),
                  verticalSpace(10),
                  CustomTextField(
                    controller: emailController,
                    hintText: 'Email*',
                    focusNode: emailFocusNode,
                    errorText: emailError,
                    keyboardType: TextInputType.emailAddress,
                    onEditingComplete: () => FocusScope.of(context).nextFocus(),
                  ),
                  verticalSpace(10),
                  CustomTextField(
                    controller: emergencyEmailController,
                    hintText: 'Emergency Email*',
                    focusNode: emergencyEmailFocusNode,
                    errorText: emergencyEmailError,
                    keyboardType: TextInputType.emailAddress,
                    onEditingComplete: () => FocusScope.of(context).nextFocus(),
                  ),
                  verticalSpace(10),
                  CustomTextField(
                    controller: addressController,
                    hintText: 'Address*',
                    focusNode: addressFocusNode,
                    errorText: addressError,
                    onEditingComplete: () => FocusScope.of(context).nextFocus(),
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
