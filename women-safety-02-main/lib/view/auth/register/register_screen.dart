import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:women_safety/bloc/register/bloc/register_pages_bloc.dart';
import 'package:women_safety/utils/custom_color.dart';
import 'package:women_safety/utils/size.dart';
import 'package:women_safety/view/auth/register/pages/page1/page1.dart';
import 'package:women_safety/view/auth/register/pages/page2/page2.dart';
import 'package:women_safety/view/auth/register/pages/page3/page3.dart';
import 'package:women_safety/view/auth/register/pages/page4/page4.dart';
import 'package:women_safety/widgets/custom_back_button.dart';
import 'package:women_safety/widgets/custom_button.dart';
import 'package:women_safety/widgets/custom_linearProgress.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Keep track of PageState keys to access states - now using public state classes
  final GlobalKey<Page1State> _page1Key = GlobalKey<Page1State>();
  final GlobalKey<Page2State> _page2Key = GlobalKey<Page2State>();
  final GlobalKey<Page3State> _page3Key = GlobalKey<Page3State>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Clear all controllers when user presses back button
        _clearAllControllers();
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: CustomColor.whiteColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    _clearAllControllers();
                    Navigator.pop(context);
                  },
                  child: CustomBackButton(context),
                ),
                verticalSpace(4),
                BlocBuilder<RegisterPagesBloc, RegisterPagesState>(
                  builder: (context, state) {
                    double progress = 0.25; // 1 tick
                    if (state is RegisterPage1) {
                      progress = 0.25; // 1 tick
                    } else if (state is RegisterPage2) {
                      progress = 0.5; // 2 ticks
                    } else if (state is RegisterPage3) {
                      progress = 0.75; // 3 ticks
                    } else if (state is RegisterPage4) {
                      progress = 1.0; // 4 ticks
                    }
                    return CustomLinearProgress(value: progress);
                  },
                ),
                verticalSpace(19),
                Expanded(
                  child: PageView(
                    // physics: NeverScrollableScrollPhysics(),
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                      if (index == 0) {
                        context.read<RegisterPagesBloc>().add(GoToPage1());
                      } else if (index == 1) {
                        context.read<RegisterPagesBloc>().add(GoToPage2());
                      } else if (index == 2) {
                        context.read<RegisterPagesBloc>().add(GoToPage3());
                      } else if (index == 3) {
                        context.read<RegisterPagesBloc>().add(GoToPage4());
                      }
                    },
                    children: [
                      Page1(key: _page1Key),
                      Page2(key: _page2Key),
                      Page3(key: _page3Key),
                      Page4(pageController: _pageController),
                    ],
                  ),
                ),
                if (_currentPage < 3) verticalSpace(14),
                if (_currentPage < 3)
                  CustomButton(
                    text: 'Next',
                    onPressed: handleNext,
                  ),
                verticalSpace(24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Method to clear all controllers when user leaves the registration flow
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
  void dispose() {
    // Clear all controllers when widget is disposed
    _clearAllControllers();
    super.dispose();
  }

  void handleNext() {
    FocusScope.of(context).unfocus();

    if (_pageController.page == 0) {
      // Use Page1 validation
      final page1State = _page1Key.currentState;
      if (page1State != null && page1State.validateFields()) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else if (_pageController.page == 1) {
      // Use Page2 validation
      final page2State = _page2Key.currentState;
      if (page2State != null && page2State.validateFields()) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else if (_pageController.page == 2) {
      // Use Page3 validation
      final page3State = _page3Key.currentState;
      if (page3State != null && page3State.validateFields()) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else if (_pageController.page == 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}
