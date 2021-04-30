import 'package:YOURDRS_FlutterAPP/blocs/login/pin_generation/pin_screen_generate_bloc.dart';
import 'package:YOURDRS_FlutterAPP/common/app_colors.dart';
import 'package:YOURDRS_FlutterAPP/common/app_constants.dart';
import 'package:YOURDRS_FlutterAPP/common/app_icons.dart';
import 'package:YOURDRS_FlutterAPP/common/app_strings.dart';
import 'package:YOURDRS_FlutterAPP/common/app_text.dart';
import 'package:YOURDRS_FlutterAPP/common/app_toast_message.dart';
import 'package:YOURDRS_FlutterAPP/network/repo/local/preference/local_storage.dart';
import 'package:YOURDRS_FlutterAPP/network/services/login/pin_generation_api.dart';
import 'package:YOURDRS_FlutterAPP/ui/login/login_screen/loginscreen.dart';
import 'package:YOURDRS_FlutterAPP/ui/login/security_pin_screen/create_security_pin.dart';
import 'package:YOURDRS_FlutterAPP/ui/login/security_pin_screen/verify_security_pin.dart';
import 'package:YOURDRS_FlutterAPP/utils/route_generator.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'create_security_pin.dart';

var _pin;
final GlobalKey<State> _keyLoader = new GlobalKey<State>();

class ConfirmPinScreen extends StatelessWidget {
  static const String routeName = '/ConfirmPinScreen';

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PinScreenGenerateBloc>(
      create: (context) => PinScreenGenerateBloc(PinGenerateResponse()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: PinPutView()),
      ),
    );
  }
}

class PinPutView extends StatefulWidget {
  @override
  PinPutViewState createState() => PinPutViewState();
}

class PinPutViewState extends State<PinPutView> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool isInternetAvailable = false;
  var _memberId;
  final pinPutController = TextEditingController();
  AppToast appToast=AppToast();
  ///checking internet connection available or not.
  Future<void> _checkInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      // I am connected to a mobile network.
      setState(() {
        isInternetAvailable = true;
      });
    } else {
      setState(() {
        isInternetAvailable = false;
      });
      appToast.showToast(AppStrings.noInternet);
    }
  }

  clearTextInput() {
    pinPutController.clear();
  }

  ///customized dialog box.
  Future<void> showLoadingDialog(BuildContext context, GlobalKey key) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(

            ///onWillPop disables back button for this specific widget.
              onWillPop: () async => false,
              child: SimpleDialog(
                  key: key,
                  backgroundColor: Colors.white,
                  children: <Widget>[
                    Center(
                      child: Row(children: [
                        SizedBox(width: 25),
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(
                              CustomizedColors.primaryColor),
                        ),
                        SizedBox(width: 35),
                        Text(
                          AppStrings.loading,
                          style: TextStyle(
                              fontFamily: AppFonts.regular,
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w600),
                        )
                      ]),
                    )
                  ]));
        });
  }

  Widget _alertMessage(String msg) {
    Alert(
      context: context,
      type: AlertType.none,
      title: msg,
      buttons: [
        DialogButton(
          color: CustomizedColors.primaryColor,
          child: Text(
            AppStrings.ok,
            style: TextStyle(color: Colors.white, fontSize: 20,  fontFamily: AppFonts.regular,),
          ),
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          width: 58,
          height: 40,
        )
      ],
    ).show();
  }

  /// validating the pin put value
  String _validatePinput(String value) {
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
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _memberId = (prefs.getString(Keys.memberId) ?? '');
      _pin = (prefs.getString(Keys.pin) ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    var storedPin = _pin;
    // TODO: implement build
    final BoxDecoration pinPutDecoration = BoxDecoration(
      color: Colors.grey,
      borderRadius: BorderRadius.circular(12.0),
    );

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    Widget _portrait() {
      return BlocListener<PinScreenGenerateBloc, PinGenerateScreenState>(
          listener: (context, state) {
            if (state.isTrue == true) {
              Navigator.of(_keyLoader.currentContext, rootNavigator: true)
                  .pop();
              RouteGenerator.navigatorKey.currentState
                  .pushReplacementNamed(VerifyPinScreen.routeName);
            } else {
              Navigator.of(_keyLoader.currentContext, rootNavigator: true)
                  .pop();
              _alertMessage(state.statusMsg);
              clearTextInput();
            }
          },
          child: Container(
            height: height,
            //color: CustomizedColors.PinScreenColor,
            color: Colors.white,
            child: Stack(
              fit: StackFit.passthrough,
              children: <Widget>[
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
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
                  SizedBox(height: height * 0.08),
                  // Container(
                  //     height: height * 0.13,
                  //     child: Image.asset(AppImages.pinImage)),
                  Text(
                    AppStrings.confirmPin,
                    style: TextStyle(
                        fontFamily: AppFonts.regular,
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: height * 0.05),
                  Container(
                    width: width * 0.80,
                    child:
                    Form(
                      key: _formKey,
                      child: GestureDetector(
                        onLongPress: () {
                          print(_formKey.currentState.validate());
                        },
                        child: PinPut(
                          validator: _validatePinput,
                          controller: pinPutController,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          withCursor: true,
                          fieldsCount: 4,
                          fieldsAlignment: MainAxisAlignment.spaceAround,
                          textStyle: const TextStyle(fontFamily: AppFonts.regular,
                              fontSize: 25.0, color: Colors.black),
                          eachFieldMargin: EdgeInsets.all(0),
                          eachFieldWidth: 50.0,
                          eachFieldHeight: 50.0,
                          onSubmit: (String pin) async {
                            FocusScope.of(context).unfocus();
                            ///after submitting pin keyboard will automatically destroy.
                            await _checkInternet();
                            if (pin == storedPin) {
                              ///here we are checking if Previously entered pin is same as confirm pin.
                              ///if pin is incorrect we are are navigating user back to create pin screen.else we are saving generated pin in API.
                              var _generate;
                              if (isInternetAvailable == true) {
                                showLoadingDialog(context, _keyLoader);
                                BlocProvider.of<PinScreenGenerateBloc>(context)
                                    .add(PinGenerateScreenEvent(
                                    pin, _generate, int.parse(_memberId)));
                              }
                            } else {
                              appToast.showToast(AppStrings.pinNotMatched);
                              RouteGenerator.navigatorKey.currentState
                                  .pushReplacementNamed(
                                CreatePinScreen.routeName,
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
                  SizedBox(height: height * 0.10,),
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
              ],
            ),
          ));
    }
    return Scaffold(
      body: SingleChildScrollView(child: _portrait()),
    );
  }
}
