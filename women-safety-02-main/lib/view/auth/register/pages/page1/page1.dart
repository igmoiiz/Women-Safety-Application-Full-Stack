import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:women_safety/utils/custom_text.dart';
import 'package:women_safety/utils/size.dart';
import 'package:women_safety/widgets/custom_textfield.dart';
import 'package:women_safety/widgets/custom_dropdown.dart';

final firstNameController = TextEditingController();
final lastNameController = TextEditingController();
final fatherNameController = TextEditingController();
final cnicController = TextEditingController();
final genderController = TextEditingController();
final bloodGroupController = TextEditingController();

class Page1 extends StatefulWidget {
  const Page1({super.key});

  @override
  State<Page1> createState() => Page1State();
}

class Page1State extends State<Page1> {
  final firstNameFocusNode = FocusNode();
  final lastNameFocusNode = FocusNode();
  final fatherNameFocusNode = FocusNode();
  final cnicFocusNode = FocusNode();
  final genderFocusNode = FocusNode();
  final bloodGroupFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  // Error states
  String? firstNameError;
  String? lastNameError;
  String? fatherNameError;
  String? cnicError;
  String? genderError;
  String? bloodGroupError;

  final List<String> genderOptions = ['Male', 'Female'];
  final List<String> bloodGroupOptions = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-'
  ];

  @override
  void initState() {
    super.initState();
    firstNameFocusNode
        .addListener(() => _scrollToFocusedField(firstNameFocusNode));
    lastNameFocusNode
        .addListener(() => _scrollToFocusedField(lastNameFocusNode));
    fatherNameFocusNode
        .addListener(() => _scrollToFocusedField(fatherNameFocusNode));
    cnicFocusNode.addListener(() => _scrollToFocusedField(cnicFocusNode));
    genderFocusNode.addListener(() => _scrollToFocusedField(genderFocusNode));
    bloodGroupFocusNode
        .addListener(() => _scrollToFocusedField(bloodGroupFocusNode));
    cnicController.addListener(_formatCNIC);
  }

  @override
  void dispose() {
    firstNameFocusNode.dispose();
    lastNameFocusNode.dispose();
    fatherNameFocusNode.dispose();
    cnicFocusNode.dispose();
    genderFocusNode.dispose();
    bloodGroupFocusNode.dispose();
    _scrollController.dispose();
    cnicController.removeListener(_formatCNIC);
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

  void _formatCNIC() {
    var text = cnicController.text.replaceAll('-', '');
    if (text.length > 13) {
      text = text.substring(0, 13);
    }

    final newText = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      if (i == 5 || i == 12) {
        newText.write('-');
      }
      newText.write(text[i]);
    }

    cnicController.value = TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }

  // Method to validate the form fields
  bool validateFields() {
    bool isValid = true;

    // Reset all error states
    setState(() {
      firstNameError = null;
      lastNameError = null;
      fatherNameError = null;
      cnicError = null;
      genderError = null;
      bloodGroupError = null;
    });

    // Validate each field and set appropriate error messages
    if (firstNameController.text.isEmpty) {
      setState(() {
        firstNameError = 'First name is required';
      });
      isValid = false;
    }

    if (lastNameController.text.isEmpty) {
      setState(() {
        lastNameError = 'Last name is required';
      });
      isValid = false;
    }

    if (fatherNameController.text.isEmpty) {
      setState(() {
        fatherNameError = 'Father name is required';
      });
      isValid = false;
    }

    if (cnicController.text.isEmpty) {
      setState(() {
        cnicError = 'CNIC is required';
      });
      isValid = false;
    } else if (cnicController.text.length != 15) {
      setState(() {
        cnicError = 'Please enter a valid CNIC';
      });
      isValid = false;
    } else if (int.parse(cnicController.text[cnicController.text.length - 1]) %
            2 !=
        0) {
      setState(() {
        cnicError = 'Only women are eligible';
      });
      isValid = false;
    }

    if (genderController.text.isEmpty) {
      setState(() {
        genderError = 'Gender is required';
      });
      isValid = false;
    } else if (genderController.text == 'Male') {
      setState(() {
        genderError = 'Only women can register for this app';
      });
      isValid = false;
    }

    if (bloodGroupController.text.isEmpty) {
      setState(() {
        bloodGroupError = 'Blood group is required';
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
                    controller: firstNameController,
                    hintText: 'First Name*',
                    focusNode: firstNameFocusNode,
                    errorText: firstNameError,
                    onEditingComplete: () => FocusScope.of(context).nextFocus(),
                  ),
                  verticalSpace(10),
                  CustomTextField(
                    controller: lastNameController,
                    hintText: 'Last Name*',
                    focusNode: lastNameFocusNode,
                    errorText: lastNameError,
                    onEditingComplete: () => FocusScope.of(context).nextFocus(),
                  ),
                  verticalSpace(10),
                  CustomTextField(
                    controller: fatherNameController,
                    hintText: 'Father Name*',
                    focusNode: fatherNameFocusNode,
                    errorText: fatherNameError,
                    onEditingComplete: () => FocusScope.of(context).nextFocus(),
                  ),
                  verticalSpace(10),
                  CustomTextField(
                    controller: cnicController,
                    hintText: 'CNIC (00000-0000000-0) *',
                    focusNode: cnicFocusNode,
                    errorText: cnicError,
                    onEditingComplete: () => FocusScope.of(context).nextFocus(),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(13),
                    ],
                  ),
                  verticalSpace(10),
                  CustomDropdown(
                    controller: genderController,
                    hintText: 'Select Gender',
                    items: genderOptions,
                    errorText: genderError,
                    focusNode: genderFocusNode,
                  ),
                  verticalSpace(10),
                  CustomDropdown(
                    controller: bloodGroupController,
                    hintText: 'Select Blood Group',
                    items: bloodGroupOptions,
                    errorText: bloodGroupError,
                    focusNode: bloodGroupFocusNode,
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
