import 'package:YOURDRS_FlutterAPP/network/repo/local/preference/local_storage.dart';
import 'package:YOURDRS_FlutterAPP/ui/login/login_screen/splash_screen.dart';
import 'package:YOURDRS_FlutterAPP/ui/login/security_pin_screen/verify_security_pin.dart';
import 'package:YOURDRS_FlutterAPP/utils/route_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var login = prefs.getString(Keys.isPINAvailable);
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Your Doctors',
    home: login == null || login == "" ? SplashScreen() : VerifyPinScreen(),
    initialRoute: SplashScreen.routeName,
    onGenerateRoute: RouteGenerator.generateRoute,
    navigatorKey: RouteGenerator.navigatorKey,
  ));
}
