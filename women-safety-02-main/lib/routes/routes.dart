import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:women_safety/view/SplashScreen/splash_screen.dart';
import 'package:women_safety/view/WelcomePage/welcome_page.dart';
import 'package:women_safety/view/auth/forgetPasswordScreen/forget_password_screen.dart';
import 'package:women_safety/view/auth/loginScreen/login_screen.dart';
import 'package:women_safety/view/auth/register/success/success.dart';
import 'package:women_safety/view/auth/resendOtpVarification/resentOtp_varification.dart';
import 'package:women_safety/view/auth/register/register_screen.dart';
import 'package:women_safety/view/bottomNavigationBar/bottom_navigationbar.dart';
import 'package:women_safety/view/bottomNavigationBar/tabs/ProfileScreen/AboutScreen.dart';
import 'package:women_safety/view/bottomNavigationBar/tabs/homeScreen/Screen/RedArea/Screen/report_red_area_screen.dart';
import 'package:women_safety/view/bottomNavigationBar/tabs/homeScreen/Screen/locate/locate_screen.dart';
import 'package:women_safety/view/bottomNavigationBar/tabs/homeScreen/Screen/menu/Screens/Emergency/emergency_screen.dart';
import 'package:women_safety/view/bottomNavigationBar/tabs/homeScreen/Screen/menu/Screens/laws/law_screen.dart';
import 'package:women_safety/view/bottomNavigationBar/tabs/homeScreen/Screen/menu/menu_sreen.dart';
import 'package:women_safety/view/bottomNavigationBar/tabs/homeScreen/Screen/PinkArea/pink_area.dart';
import 'package:women_safety/view/bottomNavigationBar/tabs/homeScreen/Screen/RedArea/red_area.dart';
import 'package:women_safety/view/bottomNavigationBar/tabs/homeScreen/Screen/notification/notification_screen.dart';
import 'package:women_safety/view/bottomNavigationBar/tabs/ProfileScreen/screen/Account/account_screen.dart';
import 'package:women_safety/view/bottomNavigationBar/tabs/ProfileScreen/screen/SavePost/save_post_screen.dart';
import 'package:women_safety/view/bottomNavigationBar/tabs/ProfileScreen/screen/Settings/settings_screen.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/splash':
        return CupertinoPageRoute(builder: (_) => SplashScreen());
      case '/login':
        return CupertinoPageRoute(builder: (_) => LoginScreen());
      case '/':
        return CupertinoPageRoute(builder: (_) => WelcomePage());
      case '/forgotPassword':
        return CupertinoPageRoute(builder: (_) => ForgotPasswordScreen());
      case '/register':
        return CupertinoPageRoute(builder: (_) => RegisterScreen());
      case '/otpVarification':
        return CupertinoPageRoute(builder: (_) => ResendOtpVarification());
      case '/success':
        return CupertinoPageRoute(builder: (_) => Success());
      // Bottom Navigation Routes
      case '/bottomNavigation':
        return CupertinoPageRoute(builder: (_) => BottomNavigationbarScreen());
      case '/bottomNavigation/home/PinkArea':
        return CupertinoPageRoute(builder: (_) => PinkArea());
      case '/bottomNavigation/home/RedArea':
        return CupertinoPageRoute(builder: (_) => RedArea());
      case '/bottomNavigation/home/RedArea/ReportRedAreaScreen':
        return CupertinoPageRoute(builder: (_) => ReportRedAreaScreen());
      case '/bottomNavigation/home/locateScreen':
        return CupertinoPageRoute(builder: (_) => LocateScreen());
      case '/bottomNavigation/home/NotificationScreen':
        return CupertinoPageRoute(builder: (_) => NotificationScreen());
      case '/bottomNavigation/home/MenuSreen':
        return CupertinoPageRoute(builder: (_) => MenuSreen());
      case '/bottomNavigation/home/MenuSreen/EmegencyScreen':
        return CupertinoPageRoute(builder: (_) => EmergencyScreen());
      case '/bottomNavigation/home/MenuSreen/LawScreen':
        return CupertinoPageRoute(builder: (_) => LawScreen());
      case '/bottomNavigation/PersonScreen/SavePostScreen':
        return CupertinoPageRoute(builder: (_) => SavePostScreen());
      case '/bottomNavigation/PersonScreen/AccountScreen':
        return CupertinoPageRoute(builder: (_) => AccountScreen());
      case '/bottomNavigation/PersonScreen/AboutScreen':
        return CupertinoPageRoute(builder: (_) => AboutScreen());
      case '/bottomNavigation/PersonScreen/SettingsScreen':
        return MaterialPageRoute(builder: (_) => SettingsScreen());

      default:
        return CupertinoPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
