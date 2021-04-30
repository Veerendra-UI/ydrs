import 'package:YOURDRS_FlutterAPP/blocs/login/login/login_bloc.dart';
import 'package:YOURDRS_FlutterAPP/common/app_colors.dart';
import 'package:YOURDRS_FlutterAPP/common/app_constants.dart';
import 'package:YOURDRS_FlutterAPP/common/app_icons.dart';
import 'package:YOURDRS_FlutterAPP/common/app_strings.dart';
import 'package:YOURDRS_FlutterAPP/common/app_text.dart';
import 'package:YOURDRS_FlutterAPP/common/app_toast_message.dart';
import 'package:YOURDRS_FlutterAPP/network/repo/local/preference/local_storage.dart';
import 'package:YOURDRS_FlutterAPP/ui/home/home_screen.dart';
import 'package:YOURDRS_FlutterAPP/ui/login/security_pin_screen/create_security_pin.dart';
import 'package:YOURDRS_FlutterAPP/utils/route_generator.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final scaffoldKey = GlobalKey<ScaffoldState>();
final GlobalKey<State> _keyLoader = GlobalKey<State>();

class LoginScreen extends StatefulWidget {
  static const String routeName = '/Login';

  @override
  State<StatefulWidget> createState() {
    return LoginState();
  }
}

class LoginState extends State<LoginScreen> with SingleTickerProviderStateMixin{
  /// declaring variable
  final _formKey = GlobalKey<FormState>();
  AppToast appToast = AppToast();
  bool _passwordVisible;
  var memberID;
  bool visible = false;
  bool isInternetAvailable = false;

  /// Text editing Controllers
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  /// Animation controllers
  AnimationController _loginButtonAnimationController;
  Animation<double> _loginButtonSizeAnimation;
  bool _isLoading = false;


  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
    _checkInternet();
    ///for shrinking animation delay.
    _loginButtonAnimationController =
        AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    ///for auto setting width of animated login button
    _loginButtonSizeAnimation = Tween<double>(begin: 330, end: 64)
        .animate(_loginButtonAnimationController)
      ..addListener(() {
        setState(() {});
      });
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _loginButtonAnimationController.dispose();
    super.dispose();
  }
  /// animation method for login button
  void _playLoginAnimation() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    try {
      await _loginButtonAnimationController.forward();
    } on TickerCanceled {}
  }
  ///checking internet connection available
  Future<void> _checkInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      setState(() {
        isInternetAvailable = true;
      });
    } else {
      setState(() {
        isInternetAvailable = false;
      });
      //  appToast.showToast(AppStrings.no_internet);
      showInternetError(context, _keyLoader);
    }
  }

  /// DialogBox to show the popup message if user credentials are wrong
  void _alertMessage() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppStrings.incorrectCredentials,
            style: TextStyle(fontWeight: FontWeight.bold,fontFamily: AppFonts.regular,),
          ),
          content: Text(
            AppStrings.wrongCredentialsMsg,
            style: TextStyle(
                fontFamily: AppFonts.regular,
                color: CustomizedColors.your_doctors_text_color,
                fontWeight: FontWeight.bold),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                AppStrings.Submit,
                style: TextStyle(
                    fontFamily: AppFonts.regular,
                    fontSize: 15,
                    color: CustomizedColors.primaryColor,
                    fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void resetAnimatedButtonSize(){
    setState(() {
      _isLoading = false;
      _loginButtonAnimationController.reverse();
    });

  }

  ///for checking user is login first time.
  void setIsItFirstTime() async {
    await MySharedPreferences.instance
        .setStringValue(Keys.isItFirstTime, "yes");
  }

  Future<void> showInternetError(BuildContext context, GlobalKey key) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return new WillPopScope(
          onWillPop: () async => true,
          child: SimpleDialog(
            key: key,
            // backgroundColor: Colors.redAccent.shade100,
            backgroundColor: Colors.white,
            children: <Widget>[
              Center(
                child: Column(
                  children: [
                    Container(
                        height: 100,
                        child: Image.asset(
                          "assets/images/bird.gif",
                          fit: BoxFit.cover,
                        )),
                    Text(
                      "No Internet",
                      style: TextStyle(
                          fontFamily: AppFonts.regular,
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Please check your connection and try again",
                      style: TextStyle(
                          fontFamily: AppFonts.regular,
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.normal),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Ok",style: TextStyle(fontFamily: AppFonts.regular,),),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var hight= MediaQuery.of(context).size.height;
    return BlocListener<LoginBloc, FormScreenState>(
      listener: (context, state) {
        // if the status code is true i.e 200 it execute the statement else go to next statement
        if (state.isTrue == true) {
          ///for setting value in shared preference.
          setIsItFirstTime();
          // checking for particular member pin is available or not.
          // based on that we are navigating user to respective screens.
          if (state.isPinAvailable == true) {
            // Route navigation to patientAppointment Screen
            // Navigator.of(_keyLoader.currentContext, rootNavigator: true)
            //     .pop(); //close the dialog
            RouteGenerator.navigatorKey.currentState.pushReplacementNamed(
                PatientAppointment.routeName,
                arguments: state.memberId);
          } else {
            // Route navigation to Create Pin Screen
            RouteGenerator.navigatorKey.currentState.pushReplacementNamed(
              CreatePinScreen.routeName,
            );
          }
        } else {
          resetAnimatedButtonSize();
          // Navigator.of(_keyLoader.currentContext, rootNavigator: true)
          //     .pop(); //close the dialog
          _alertMessage();
        }
      },
      child: Scaffold(
        key: scaffoldKey,
        body: SingleChildScrollView(
          child: Center(
            child: Container(
              height: hight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _text(),
                  _welcome_text(),
                  _yourDoctors_text(),
                  _form_field(),
                  _SignIn_button(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Container for your doctor text with image
  @override
  Widget _text() {
    var height = MediaQuery.of(context).size.height;
    return Container(
      child: Row(
        // which add Row properties at the center
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppStrings.your,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: AppFonts.regular,
                fontSize: 40,
                color: CustomizedColors.your_text_color),
          ),
          Text(
            AppStrings.doctors,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: AppFonts.regular,
                fontSize: 40,
                color: CustomizedColors.doctor_text_color),
          ),
          Image.asset(
            AppImages.doctorImg,
            // I added asset image
            height: 60,
          ),
        ],
      ),
      margin: EdgeInsets.only(bottom: height * 0.060, top: height * 0.04),
    );
  }

  /// Container for welcome screen Text
  @override
  Widget _welcome_text() {
    var height = MediaQuery.of(context).size.height;
    return Container(
      child: Text(
        AppStrings.welcome_text,
        style: TextStyle(
            fontWeight: FontWeight.w700,
            fontFamily: AppFonts.regular,
            fontSize: 35,
            letterSpacing: 1),
      ),
      margin: EdgeInsets.only(bottom: height * 0.03),
    );
  }

  /// Container for your_doctors quote text
  // ignore: non_constant_identifier_names
  Widget _yourDoctors_text() {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Container(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: height * 0.2,
          maxWidth: width * 0.9,
        ),
        child: Text(
          AppStrings.your_doctor_text,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontFamily: AppFonts.regular,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: CustomizedColors.your_doctors_text_color),
        ),
      ),
      margin: EdgeInsets.only(bottom: height * 0.04),
    );
  }

  /// Two Form field to which validate the user input
  @override
  _form_field(){
    var height = MediaQuery.of(context).size.height;
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: CustomizedColors.text_field_background,
              borderRadius: BorderRadius.circular(15),
            ),

            /// TextFormField for Email
            child: TextFormField(
              inputFormatters: [
                BlacklistingTextInputFormatter(RegExp(AppConstants.ignoreSpace))

                ///for disabling white spaces in form field
              ],
              validator: (value) {
                if (value.isEmpty) {
                  return AppStrings.enter_email;
                }
                return null;
              },
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(left: 20),
                border: InputBorder.none,
                hintText: AppStrings.email_text_field_hint,
                hintStyle: TextStyle(fontWeight: FontWeight.w400,  fontFamily: AppFonts.regular,),
              ),
            ),
            margin: EdgeInsets.only(
                left: height * 0.04,
                right: height * 0.04,
                top: height * 0.06,
                bottom: height * 0.05),
          ),
          Container(
            decoration: BoxDecoration(
              color: CustomizedColors.text_field_background,
              borderRadius: BorderRadius.circular(15),
            ),

            /// TextFormField for password
            child: TextFormField(
              inputFormatters: [
                BlacklistingTextInputFormatter(RegExp(AppConstants.ignoreSpace))

                ///for disabling white spaces in form field
              ],
              validator: (value) {
                if (value.isEmpty) {
                  return AppStrings.enter_password;
                }
                return null;
              },
              controller: passwordController,
              obscureText: !_passwordVisible,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(left: 20, top: 15),
                border: InputBorder.none,
                suffixIcon: IconButton(
                  icon: Icon(
                    _passwordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.black54,
                  ),
                  onPressed: () {
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  },
                ),
                hintText: AppStrings.password_text_field_hint,
                hintStyle: TextStyle(fontWeight: FontWeight.w400,  fontFamily: AppFonts.regular,),
              ),
            ),

            margin: EdgeInsets.only(
                left: height * 0.04,
                right: height * 0.04,
                bottom: height * 0.05),
          ),
        ],
      ),
    );
  }

  /// Onclick of sign in  Button user validated and navigated to next screen
  // ignore: non_constant_identifier_names
  Widget _SignIn_button() {
    return Center(
      child: GestureDetector(
        onTap: () async {
        //_playLoginAnimation();
          FocusScope.of(context).unfocus();
          //it will check for internet connection before sending data to Api.
          await _checkInternet();
          if (isInternetAvailable == true) {
            if (_formKey.currentState.validate()) {
              _playLoginAnimation();
              // showLoadingDialog(context, _keyLoader);
              BlocProvider.of<LoginBloc>(context).add(FormScreenEvent(
                  emailController.text, passwordController.text));
            } else {
              return null;
            }
          }
        },
        child: Container(
            width: _loginButtonSizeAnimation.value,
            height: 50.0,
            alignment: FractionalOffset.center,
            decoration: BoxDecoration(
                color: CustomizedColors.primaryColor,
                borderRadius: BorderRadius.all(const Radius.circular(30.0))),
            child: !_isLoading
                ? Text(
              AppStrings.sign_in,
              style: TextStyle( fontFamily: AppFonts.regular,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: CustomizedColors.sign_in_text_color),
            )
                : CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation(Colors.white),
            )),
      ),
    );
  }
}
