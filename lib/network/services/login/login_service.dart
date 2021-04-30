import 'dart:async';
import 'dart:convert';
import 'package:YOURDRS_FlutterAPP/common/app_strings.dart';
import 'package:YOURDRS_FlutterAPP/common/app_toast_message.dart';
import 'package:YOURDRS_FlutterAPP/network/models/login/login_model.dart';
import 'package:http/http.dart' as http;


class LoginApiServices {
  /// passing the controller valued in service
  AppToast appToast = AppToast();
  Future<AuthenticateUser> LoginpostApiMethod(String name, String password) async {
    var client = http.Client();
    String apiUrl = ApiUrlConstants.getUser;
    // print('requestUrl $apiUrl');
    final json = {
      "userName": name,
      "password": password,
    };
    try {
      http.Response response = await client.post(
        apiUrl,
        body: jsonEncode(json),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      var jsonResponse = jsonDecode(response.body);
      return AuthenticateUser.fromJson(jsonResponse);
    } catch (e) {
      print("${e.toString()}");
      print("error in catch statement");
      appToast.showToast(AppStrings.serverError);
      throw(e);
    }
    finally {
      client.close();
    }
  }
}
