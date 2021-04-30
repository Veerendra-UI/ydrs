import 'dart:async';
import 'package:YOURDRS_FlutterAPP/common/app_colors.dart';
import 'package:YOURDRS_FlutterAPP/common/app_icons.dart';
import 'package:YOURDRS_FlutterAPP/common/app_strings.dart';
import 'package:YOURDRS_FlutterAPP/ui/login/login_screen/loginscreen.dart';
import 'package:YOURDRS_FlutterAPP/ui/login/security_pin_screen/verify_security_pin.dart';
import 'package:YOURDRS_FlutterAPP/utils/route_generator.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/app_text.dart';
class SplashScreen extends StatefulWidget {
  static const String routeName = '/';
  @override
  State<StatefulWidget> createState() {
// TODO: implement createState
    return SplashScreen_State();
  }
}

class SplashScreen_State extends State<SplashScreen> {
  bool isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (isInit) {
      isInit = false;
      Timer(Duration(seconds: 5), () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        var login = prefs.getString(AppStrings.pinAvailable);
        if (login == null || login.isEmpty) {
          RouteGenerator.navigatorKey.currentState
              .pushReplacementNamed(LoginScreen.routeName);
        } else {
          RouteGenerator.navigatorKey.currentState
              .pushReplacementNamed(VerifyPinScreen.routeName);
        }
      });
    }
  }

  Widget _portrait({double LogoHt}) {
    return container(LogoHt);
  }

  Widget _landScape({double LogoHt}) {
    return container(LogoHt);
  }

  Container container(double LogoHeight) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.bottomCenter,
              child: Image.asset(
                AppImages.SplashLogo,
                width: width,
                height: height * LogoHeight,
              ),
            ),
            FractionalTranslation(
              translation: Offset(0.0, -0.3),
              child: Text(
                AppStrings.yourDrs,
                style: TextStyle( fontFamily: AppFonts.regular,
                    color: Colors.white,
                    fontSize: 50,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
      width: width,
      height: height,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomizedColors.PinScreenColor,
      body: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.portrait) {
            return _portrait(LogoHt: 0.15);
          } else {
            return _landScape(LogoHt: 0.30);
          }
        },
      ),
    );
  }
}
