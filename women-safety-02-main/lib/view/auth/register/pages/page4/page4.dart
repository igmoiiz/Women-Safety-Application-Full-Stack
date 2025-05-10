import 'package:cnic_scanner/cnic_scanner.dart';
import 'package:cnic_scanner/model/cnic_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:women_safety/services/firebase_auth/firebase_auth_methods.dart';
import 'package:women_safety/utils/custom_text.dart';
import 'package:women_safety/utils/custom_toast.dart';
import 'package:women_safety/utils/size.dart';
import 'package:women_safety/view/auth/register/pages/page2/page2.dart';
import 'package:women_safety/view/auth/register/pages/page3/page3.dart';
import 'package:women_safety/widgets/custom_button.dart';
import 'package:women_safety/widgets/loading_dialog.dart';

class Page4 extends StatefulWidget {
  var pageController;
  Page4({required this.pageController, super.key});

  @override
  State<Page4> createState() => _Page4State();
}

class _Page4State extends State<Page4> {
  CnicModel _cnicModel = CnicModel();
  bool _isScanned = false;
  bool _isValid = false;

  Future<void> scanCnic(ImageSource imageSource) async {
    try {
      CnicModel cnicModel =
          await CnicScanner().scanImage(imageSource: imageSource);

      String cnicNumber = cnicModel.cnicNumber;
      bool isValid = getCnicValidity(cnicNumber);

      setState(() {
        _isScanned = true;
        _isValid = isValid;
      });

      if (isValid) {
        // Show loading dialog before starting registration
        showLoadingDialog(context, 'Creating account...');

        // Sign up the user without email verification
        FirebaseAuthMethods().signUpWithEmail(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
          context: context,
        );
        // Note: Loading dialog will be dismissed in the FirebaseAuthMethods class
      } else {
        CustomToast.showSnackbar(context, 'Not eligible for registration');
      }
    } catch (e) {
      CustomToast.showSnackbar(context, 'Error scanning CNIC: ${e.toString()}');
    }
  }

  bool getCnicValidity(String cnicNumber) {
    if (cnicNumber.isNotEmpty) {
      int lastDigit = int.parse(cnicNumber[cnicNumber.length - 1]);
      return lastDigit % 2 == 0;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Scan CNIC',
            style: CustomText.customUrbanist.copyWith(
              fontSize: 30,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Spacer(),
        customScanFrame(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isScanned)
                Text(
                  _isValid ? 'Valid' : 'Not Eligible',
                  style: TextStyle(
                    fontSize: 18,
                    color: _isValid ? Colors.green : Colors.red,
                  ),
                ),
            ],
          ),
        ),
        verticalSpace(100),
        Spacer(),
        CustomButton(
          text: 'Scan Now',
          onPressed: () {
            scanCnic(ImageSource.camera);
          },
        ),
        verticalSpace(8),
      ],
    );
  }
}

class customScanFrame extends StatelessWidget {
  const customScanFrame({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 240,
          width: 240,
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: Center(
            child: Image(
              image: AssetImage('assets/images/cardFrame.png'),
              width: 215,
              height: 215,
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: Center(
            child: Image(
              image: AssetImage('assets/images/cardImage.png'),
              width: 190,
              height: 190,
            ),
          ),
        ),
      ],
    );
  }
}
