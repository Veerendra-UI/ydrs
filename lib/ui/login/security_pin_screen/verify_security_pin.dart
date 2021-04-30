import 'package:YOURDRS_FlutterAPP/blocs/login/pin_validation/pin_screen_validate_bloc.dart';
import 'package:YOURDRS_FlutterAPP/common/app_colors.dart';
import 'package:YOURDRS_FlutterAPP/common/app_icons.dart';
import 'package:YOURDRS_FlutterAPP/common/app_strings.dart';
import 'package:YOURDRS_FlutterAPP/common/app_text.dart';
import 'package:YOURDRS_FlutterAPP/common/app_toast_message.dart';
import 'package:YOURDRS_FlutterAPP/network/repo/local/preference/local_storage.dart';
import 'package:YOURDRS_FlutterAPP/network/services/login/pin_validate_api.dart';
import 'package:YOURDRS_FlutterAPP/ui/home/home_screen.dart';
import 'package:YOURDRS_FlutterAPP/ui/login/login_screen/loginscreen.dart';
import 'package:YOURDRS_FlutterAPP/utils/route_generator.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();
final GlobalKey<State> _keyLoader = new GlobalKey<State>();

class VerifyPinScreen extends StatelessWidget {
  static const String routeName = '/VerifyPinScreen';

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PinScreenBloc>(
      create: (context) => PinScreenBloc(PinRepo()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: PinPutView(),
        ),
      ),
    );
  }
}

class PinPutView extends StatefulWidget {
  @override
  PinPutViewState createState() => PinPutViewState();
}

class PinPutViewState extends State<PinPutView> {
  AppToast appToast = AppToast();
  var name;
  var img;
  bool isInternetAvailable = false;
  final _formKey = GlobalKey<FormState>();
  final pinPutController = TextEditingController();
  var isItFirstTime;
  var storePin;
  var storedMemberPin;

  _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isItFirstTime = (prefs.getString(Keys.isItFirstTime) ?? '');
     // print("isItFirstTime>>>>>>>>>$isItFirstTime");
      storedMemberPin = (prefs.getString(Keys.storedMemberPin) ?? '');
      //print("storedMemberPin............$storedMemberPin");
    });
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  ///for clearing input field.
  clearTextInput() {
    pinPutController.clear();
  }

  ///checking internet connection available or not.
  Future<void> _checkInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      setState(() {
        isInternetAvailable = true;
      });
    } else {
      // I am connected to a wifi network.
      setState(() {
        isInternetAvailable = false;
      });
    }
  }

  ///Customized dialog for loading...
  Future<void> showLoadingDialog(BuildContext context, GlobalKey key) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new WillPopScope(

            ///onWillPop disables back button for this specific widget.
              onWillPop: () async => false,
              child: SimpleDialog(
                  key: key,
                  backgroundColor: Colors.white,
                  children: <Widget>[
                    Center(
                      child: Row(children: [
                        SizedBox(
                          width: 25,
                        ),
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(
                              CustomizedColors.primaryColor),
                        ),
                        SizedBox(
                          width: 35,
                        ),
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

  final LocalAuthentication _localAuthentication = LocalAuthentication();

  Future<bool> _isBiometricAvailable() async {
    bool isAvailable = false;
    try {
      isAvailable = await _localAuthentication.canCheckBiometrics;
    } on PlatformException catch (e) {
      print(e);
    }

    if (!mounted) return isAvailable;
    // isAvailable;
    return isAvailable;
  }

  /// To retrieve the list of biometric types
  /// (if available).
  Future<void> _getListOfBiometricTypes() async {
    List<BiometricType> listOfBiometrics;
    try {
      listOfBiometrics = await _localAuthentication.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print(e);
    }

    if (!mounted) return;
  }

  bool isAuthenticated = false;

  /// Process of authentication user using
  /// biometrics.
  Future<void> _authenticateUser() async {
    try {
      isAuthenticated = await _localAuthentication.authenticateWithBiometrics(
        localizedReason: AppStrings.transaction_overview,
        useErrorDialogs: true,
        stickyAuth: true,
      );
    } on PlatformException catch (e) {
      print(e);
    }

    if (!mounted) return;

    isAuthenticated;

    if (isAuthenticated) {
      RouteGenerator.navigatorKey.currentState
          .pushNamed(PatientAppointment.routeName);
    }
  }

  String validatePinput(String value) {
    Pattern pattern = r'^[0-9]*$';
    RegExp regex = new RegExp(pattern);
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

  void setIsItFirstTime() async {
    await MySharedPreferences.instance.setStringValue(Keys.isItFirstTime, "no");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(child: _mobileDisplay()),
    );
  }

  Widget _alertMessage() {
    Alert(
      context: context,
      type: AlertType.none,
      title: AppStrings.enterValidPin,
      buttons: [
        DialogButton(
          color: CustomizedColors.primaryColor,
          child: Text(
            AppStrings.ok,
            style: TextStyle(color: Colors.white, fontSize: 20,fontFamily: AppFonts.regular,),
          ),
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          width: 58,
          height: 40,
        )
      ],
    ).show();
  }

  storePinInSharePref() async {
    await MySharedPreferences.instance
        .setStringValue(Keys.storedMemberPin, storePin);
  }

  Widget _mobileDisplay() {
    // TODO: implement build
    final BoxDecoration pinPutDecoration = BoxDecoration(
     // color:CustomizedColors.text_field_background,
      color:Colors.grey,
      borderRadius: BorderRadius.circular(12.0),
    );
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Container(
      height: height,
     // color: CustomizedColors.PinScreenColor,
      color: Colors.white,
      child: BlocListener<PinScreenBloc, PinScreenState>(
        listener: (context, state) {
          setState(() {
            img = state.displayPic;
            name = state.name;
          });
          if (state.isTrue == true) {
            setIsItFirstTime();
            storePinInSharePref();
            ///here if the response code is 200 based on that we are storing user entered pin in shared preference.
            Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
            RouteGenerator.navigatorKey.currentState
                .pushReplacementNamed(PatientAppointment.routeName);
            clearTextInput();
          } else {
            Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
            _alertMessage();
            clearTextInput();
          }
        },
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
            height: height * 0.05,
          ),
          // Container(
          //     height: height * 0.13, child: Image.asset(AppImages.pinImage)),
          SizedBox(
            height: height * 0.03,
          ),
          Text(
            AppStrings.enterPin,
            style: TextStyle(
                fontFamily: AppFonts.regular,
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: height * 0.05),
          Container(
           // color: Colors.green,
            width: width * 0.80,
            //height: height*0.12,
            child: Form(
              key: _formKey,
              child: GestureDetector(
                onLongPress: () {},
                child: PinPut(
                  controller: pinPutController,
                  validator: validatePinput,
                  autovalidateMode: AutovalidateMode.disabled,
                  withCursor: true,
                  fieldsCount: 4,
                  fieldsAlignment: MainAxisAlignment.spaceAround,
                  textStyle:
                  const TextStyle(fontSize: 25.0, color: Colors.black,fontFamily: AppFonts.regular,),
                  eachFieldWidth: 50.0,
                  eachFieldHeight: 50.0,
                  onSubmit: (String pin) async {
                    setState(() {
                      storePin = pin;
                    });
                    FocusScope.of(context).unfocus();

                    ///after submitting pin keyboard will automatically destroy.
                    if (_formKey.currentState.validate()) {
                      var verify;
                      await _checkInternet();
                      if (isItFirstTime == "yes") {
                        ///we are checking, is this users first time to pin screen.if it is first time then verification is done through api else it is trough sharedPref.
                        if (isInternetAvailable == true) {
                          showLoadingDialog(context, _keyLoader);
                          BlocProvider.of<PinScreenBloc>(context)
                              .add(PinScreenEvent(
                            pin,
                            verify,
                          ));
                          // print("this is pinPut value $pinPutController");
                        } else {
                          appToast.showToast(AppStrings.no_internet);
                          clearTextInput();
                        }
                      } else if (isItFirstTime == "no") {
                        if (pin == storedMemberPin) {
                          RouteGenerator.navigatorKey.currentState
                              .pushReplacementNamed(
                              PatientAppointment.routeName);
                          clearTextInput();
                        } else {
                          _alertMessage();
                          clearTextInput();
                        }
                      }

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
          SizedBox(
            height: height * 0.03,
          ),
          GestureDetector(
            onTap: () async {
              if (await _isBiometricAvailable()) {
                await _getListOfBiometricTypes();
                await _authenticateUser();
              }
            },
            child: Text(
              AppStrings.userTouchAndFaceId,
              style: TextStyle(color: Colors.black, fontSize: 20,fontFamily: AppFonts.regular),
            ),
          ),
          SizedBox(
            height: 25,
          ),
        ]),
      ),
    );
  }
}
