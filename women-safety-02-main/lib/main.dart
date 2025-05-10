// Dart: lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:women_safety/bloc/register/bloc/register_pages_bloc.dart';
import 'package:women_safety/routes/routes.dart';
import 'package:women_safety/services/backgroundService/app_initializer.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:women_safety/utils/battery_util.dart';
import 'package:women_safety/view/SplashScreen/splash_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Request battery optimization exemption using the utility class
  await BatteryOptimizationUtil.requestIgnoreBatteryOptimizations();

  // For more comprehensive battery optimization handling:
  await BatteryOptimizationUtil.requestAllBatteryOptimizations();

  await initializeAppServices();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterPagesBloc(),
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Women Safety',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        onGenerateRoute: Routes.generateRoute,
        home: SplashScreen(),
      ),
    );
  }
}
