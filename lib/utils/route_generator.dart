import 'package:YOURDRS_FlutterAPP/blocs/home/patient_bloc.dart';
import 'package:YOURDRS_FlutterAPP/blocs/login/login/login_bloc.dart';
import 'package:YOURDRS_FlutterAPP/network/services/login/login_service.dart';
import 'package:YOURDRS_FlutterAPP/ui/external_attachment/allattachment/attachment_details/local/externalattachment_details.dart';
import 'package:YOURDRS_FlutterAPP/ui/external_attachment/allattachment/attachment_details/server/externalattachment_server.dart';
import 'package:YOURDRS_FlutterAPP/ui/external_attachment/allattachment/attachment_details/server/externalpage_get_api.dart';
import 'package:YOURDRS_FlutterAPP/ui/external_attachment/externalattchment_main.dart';
import 'package:YOURDRS_FlutterAPP/ui/home/home_screen.dart';
import 'package:YOURDRS_FlutterAPP/ui/home/patient_details.dart';
import 'package:YOURDRS_FlutterAPP/ui/home/view_images.dart';
import 'package:YOURDRS_FlutterAPP/ui/login/login_screen/loginscreen.dart';
import 'package:YOURDRS_FlutterAPP/ui/login/login_screen/splash_screen.dart';
import 'package:YOURDRS_FlutterAPP/ui/login/security_pin_screen/verify_security_pin.dart';
import 'package:YOURDRS_FlutterAPP/ui/manual_dictaions/manual_dictations.dart';
import 'package:YOURDRS_FlutterAPP/ui/patient_dictation/dictation_type.dart';
import 'package:YOURDRS_FlutterAPP/ui/patient_dictation/dictations_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:YOURDRS_FlutterAPP/ui/login/security_pin_screen/create_security_pin.dart';
import 'package:YOURDRS_FlutterAPP/ui/login/security_pin_screen/confirm_pin.dart';
class RouteGenerator {
  static final navigatorKey = new GlobalKey<NavigatorState>();
  static Route<dynamic> generateRoute(RouteSettings settings) {
   // print("RouteGenerator->name=${settings.name}");
    switch (settings.name) {
      case SplashScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => SplashScreen(),
        );

      case LoginScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (context) => LoginBloc(LoginApiServices()),
            child: LoginScreen(),
          ),
        );

      case PatientAppointment.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (context) => PatientBloc(),
            child: PatientAppointment(),
          ),
        );

      case VerifyPinScreen.routeName:
        return
          MaterialPageRoute(
          settings: settings,
          builder: (_) => VerifyPinScreen(),
        );
      case CreatePinScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => CreatePinScreen(),
        );
      case ConfirmPinScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ConfirmPinScreen(),
        );
      case ManualDictations.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ManualDictations(),
        );
      case ViewImages.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ViewImages(),
       );
      case ExternalAttachments.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ExternalAttachments(),
        );
      case Externalattachmnet_server.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => Externalattachmnet_server(),
        );
      case Externalattachment_data.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => Externalattachment_data(),
        );

      case DictationType.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => DictationType(),
        );

      case DictationsList.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => DictationsList(),
        );

      default:
        return null;
    }
  }
}
