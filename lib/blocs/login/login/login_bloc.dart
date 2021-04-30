import 'dart:async';
import 'dart:io';
import 'package:YOURDRS_FlutterAPP/network/models/login/login_model.dart';
import 'package:YOURDRS_FlutterAPP/network/repo/local/preference/local_storage.dart';
import 'package:YOURDRS_FlutterAPP/network/services/login/login_service.dart';
import 'package:bloc/bloc.dart';

part 'login_event.dart';

part 'login_state.dart';

class LoginBloc extends Bloc<FormScreenEvent, FormScreenState> {
  LoginApiServices services;

  /// creating object of service class.
  LoginBloc(this.services) : super(FormScreenState(isTrue: true));

  ///Receiving service class instance from main.dart
  @override
  Stream<FormScreenState> mapEventToState(
    FormScreenEvent event,
  ) async* {
    try {
      if (event is FormScreenEvent) {
        AuthenticateUser authenticateUser =
            await services.LoginpostApiMethod(event.email, event.password).catchError((
                onError) {
              if (onError is SocketException){
                print("internet not available");
              }
              else if (onError is TimeoutException){
                print("server timeout");
              }
              else
                print("something went wrong!!");
            });

        bool isPinAvailable;

        /// check if the status value is 200 in response body.
        if (authenticateUser.header.statusCode == "200") {
          var memberId = authenticateUser.memberRole[0].memberId.toString();
          var displayUserName = authenticateUser.displayName;
          var userEmail = authenticateUser.userName;
          var profilePic = authenticateUser.profilePhoto;
          var isPINAvailable = authenticateUser.memberPin;
          var memberRoleId = authenticateUser.memberRole[0].roleId.toString();

          /// ///storing member id, memberRoleId, display_pic, displayName, pin in shared preference
          await MySharedPreferences.instance
              .setStringValue(Keys.memberId, memberId);
          await MySharedPreferences.instance
              .setStringValue(Keys.memberRoleId, memberRoleId);
          await MySharedPreferences.instance
              .setStringValue(Keys.displayPic, profilePic);
          await MySharedPreferences.instance
              .setStringValue(Keys.displayName, displayUserName);
          await MySharedPreferences.instance
              .setStringValue(Keys.userEmail, userEmail);
          await MySharedPreferences.instance
              .setStringValue(Keys.isPINAvailable, isPINAvailable);

          if (authenticateUser.memberPin == "") {
            ///here we are checking if user is having member pin or not based on that we are returning true/false value to Bloc listener.

            yield FormScreenState(
              isTrue: true,
              memberId: memberId,
              isPinAvailable: isPinAvailable = false,
            );
          } else {
            yield FormScreenState(
              isTrue: true,
              memberId: memberId,
              isPinAvailable: isPinAvailable = true,
            );
          }

          /// if the status value is not true return as false
        } else {
          yield FormScreenState(isTrue: false);
        }
      }
    } catch (Exception) {
      // print("Exception Error");
    }
  }
}
