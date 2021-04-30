import 'dart:convert';
import 'package:YOURDRS_FlutterAPP/network/models/login/pin_generation_model.dart';
import 'package:http/http.dart' as http;
import 'package:YOURDRS_FlutterAPP/common/app_strings.dart';

class PinGenerateResponse {
  Future<PinGenerateModel> postApiMethod(int MemberId, String Pin) async {
    var client = http.Client();
    String apiUrl = ApiUrlConstants.generatePin;

    final json = {
      "memberId": MemberId,
      "pin": Pin,
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
    print(jsonResponse);
    return PinGenerateModel.fromJson(jsonResponse);
  } catch (e) {
      print("${e.toString()}"
      );
    }
    finally {
      client.close();
    }
  }
}
