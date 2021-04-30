import 'package:YOURDRS_FlutterAPP/common/app_colors.dart';
import 'package:YOURDRS_FlutterAPP/common/app_constants.dart';
import 'package:YOURDRS_FlutterAPP/common/app_icons.dart';
import 'package:YOURDRS_FlutterAPP/common/app_strings.dart';
import 'package:YOURDRS_FlutterAPP/common/app_text.dart';
import 'package:YOURDRS_FlutterAPP/network/repo/local/preference/local_storage.dart';
import 'package:YOURDRS_FlutterAPP/ui/login/login_screen/loginscreen.dart';
import 'package:YOURDRS_FlutterAPP/ui/login/security_pin_screen/confirm_pin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:YOURDRS_FlutterAPP/utils/route_generator.dart';

final _formKey = GlobalKey<FormState>();
final scaffoldKey = GlobalKey<ScaffoldState>();

class CreatePinScreen extends StatelessWidget {
  static const String routeName = '/CreatePinScreen';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: PinPutView()),
    );
  }
}

class PinPutView extends StatefulWidget {
  @override
  PinPutViewState createState() => PinPutViewState();
}

class PinPutViewState extends State<PinPutView> {
  /// validating the pin put value
  String validatePinput(String value) {
    Pattern pattern = AppConstants.numberRegExp;
    RegExp regex = RegExp(pattern);
    try {
      if (value.isEmpty) {
        return AppStrings.cannot_be_empty;
      } else {
        if (!regex.hasMatch(value))
          return AppStrings.enterValidPin;
        else {
          return null;
        }
      }
    } catch (Exception) {
      print(Exception);
    }
  }

  @override
  Widget build(BuildContext context) {
    final BoxDecoration pinPutDecoration = BoxDecoration(
      color: Colors.grey,
      borderRadius: BorderRadius.circular(12.0),
    );

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    Widget _smallDisplay() {
      return Container(
        height: height,
       // color: CustomizedColors.PinScreenColor,
        color: Colors.white,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(
              AppStrings.your,
              style: TextStyle(
                  fontFamily: AppFonts.regular,
                  fontWeight: FontWeight.bold,
                  fontSize: 40,
                  color: CustomizedColors.your_text_color),
            ),
            Text(
              AppStrings.doctors,
              style: TextStyle(
                  fontFamily: AppFonts.regular,
                  fontWeight: FontWeight.bold,
                  fontSize: 40,
                  color: CustomizedColors.doctor_text_color),
            ),
            Image.asset(
              AppImages.doctorImg,
              // I added asset image
              height: 50,
            ),
          ]),
          SizedBox(
            height: height * 0.08,
          ),
          // Container(
          //     height: height * 0.13, child: Image.asset(AppImages.pinImage)),
          Text(
            AppStrings.createPin,
            style: TextStyle(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600,fontFamily: AppFonts.regular),
          ),
          SizedBox(height: height * 0.05),
          Container(
            width: width * 0.80,
            child: Form(
              key: _formKey,
              child: GestureDetector(
                onLongPress: () {
                  print(_formKey.currentState.validate());
                },
                child: PinPut(
                  validator: validatePinput,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  withCursor: true,
                  fieldsCount: 4,
                  fieldsAlignment: MainAxisAlignment.spaceAround,
                  textStyle:
                      const TextStyle(fontFamily: AppFonts.regular,fontSize: 25.0, color: Colors.black),
                  eachFieldMargin: EdgeInsets.all(0),
                  eachFieldWidth: 50.0,
                  eachFieldHeight: 50.0,
                  onSubmit: (String pin) async {
                    FocusScope.of(context).unfocus();

                    ///after submitting pin keyboard will automatically destroy.
                    if (_formKey.currentState.validate()) {
                      await MySharedPreferences.instance
                          .setStringValue(Keys.pin, pin);
                      RouteGenerator.navigatorKey.currentState
                          .pushReplacementNamed(
                        ConfirmPinScreen.routeName,
                      );
                    } else {
                      scaffoldKey.currentState.showSnackBar(
                        new SnackBar(
                          content: Container(
                            height: 40.0,
                            child: Center(
                              child: Text(
                                AppStrings.valid_credentials,
                                style: const TextStyle(fontFamily: AppFonts.regular,fontSize: 15.0),
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                  },
                  submittedFieldDecoration: pinPutDecoration,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  selectedFieldDecoration: pinPutDecoration.copyWith(
                    color: CustomizedColors.text_field_background,
                    border: Border.all(
                      width: 2,
                      color: const Color.fromRGBO(160, 215, 220, 1),
                    ),
                  ),
                  followingFieldDecoration: pinPutDecoration,
                  pinAnimationType: PinAnimationType.slide,
                ),
              ),
            ),
          ),
          SizedBox(
            height: height * 0.10,
          ),
          GestureDetector(
            onTap: () async {
              SharedPreferences preferences =
                  await SharedPreferences.getInstance();
              await preferences.clear();
              MySharedPreferences.instance.removeAll();
              RouteGenerator.navigatorKey.currentState
                  .pushReplacementNamed(LoginScreen.routeName);
            },
            child: Text(
              AppStrings.loginWithDiffAcc,
              style: TextStyle(
                  fontFamily: AppFonts.regular,
                  color: Colors.black,
                  fontSize: 20,
                  decoration: TextDecoration.underline),
            ),
          ),
        ]),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(child: _smallDisplay()),
    );
  }
}
