import 'package:YOURDRS_FlutterAPP/common/app_strings.dart';
import 'package:YOURDRS_FlutterAPP/network/models/dictations/dictations_model.dart';
import 'package:YOURDRS_FlutterAPP/network/models/external_dictations/get_all_manual_dictation_model.dart';
import 'package:YOURDRS_FlutterAPP/network/repo/local/preference/local_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Get all dictations api service class
class AllDictationService {
  var client = http.Client();
  Future<Dictations> getDictations(int appointmentId) async {
    try {
      var endpointUrl = ApiUrlConstants.dictations;
      Map<String, dynamic> queryParams = {
        'AppointmentId': '$appointmentId',
      };
      String queryString = Uri(queryParameters: queryParams).query;
      var requestUrl = endpointUrl + '?' + queryString;
      final response = await client.get(Uri.encodeFull(requestUrl),
          headers: {"Accept": "application/json"});
      if (response.statusCode == 200) {
        Dictations allDictations = parseAllDictations(response.body);
        return allDictations;
      }
    } catch (e) {
      print(e.toString());
    }
    finally{
      client.close();
    }
  }

  static Dictations parseAllDictations(String responseBody) {
    final Dictations allDictations =
        Dictations.fromJson(json.decode(responseBody));
    return allDictations;
  }
}

/// Get all previous dictations api service class
class AllPreviousDictationService {
  var client = http.Client();
  Future<Dictations> getAllPreviousDictations(
      int episodeId, int appointmentId) async {
    try {
      var endpointUrl = ApiUrlConstants.allPreviousDictations;
      Map<String, dynamic> queryParams = {
        'EpisodeID': '$episodeId',
        'AppointmentId': '$appointmentId',
      };
      String queryString = Uri(queryParameters: queryParams).query;
      var requestUrl = endpointUrl + '?' + queryString;
      final response = await client.get(Uri.encodeFull(requestUrl),
          headers: {"Accept": "application/json"});
      if (response.statusCode == 200) {
        Dictations allPreviousDictations =
            parseAllPreviousDictations(response.body);
        return allPreviousDictations;
      }
    } catch (e) {
      print(e.toString());
    }
    finally{
      client.close();
    }
  }

  static Dictations parseAllPreviousDictations(String responseBody) {
    final Dictations allPreviousDictations =
        Dictations.fromJson(json.decode(responseBody));
    return allPreviousDictations;
  }
}

/// Get my previous dictations api service class
class MyPreviousDictationService {
  var client = http.Client();
  Future<Dictations> getMyPreviousDictations(
      int episodeId, int appointmentId) async {
    try {
      var memberId =
          await MySharedPreferences.instance.getStringValue(Keys.memberId);
      var endpointUrl = ApiUrlConstants.myPreviousDictations;
      Map<String, dynamic> queryParams = {
        'EpisodeId': '$episodeId',
        'AppointmentId': '$appointmentId',
        'LoggedInMemberId': '$memberId',
      };
      String queryString = Uri(queryParameters: queryParams).query;
      var requestUrl = endpointUrl + '?' + queryString;
      final response = await client.get(Uri.encodeFull(requestUrl),
          headers: {"Accept": "application/json"});
      if (response.statusCode == 200) {
        Dictations myPreviousDictations =
            parseMyPreviousDictations(response.body);
        return myPreviousDictations;
      }
    } catch (e) {
      print(e.toString());
    }
    finally{
      client.close();
    }
  }

  static Dictations parseMyPreviousDictations(String responseBody) {
    final Dictations myPreviousDictations =
        Dictations.fromJson(json.decode(responseBody));
    return myPreviousDictations;
  }
}

// Get All My Manual Dictations Get api
class AllMyManualDictations {
  Future<GetAllMyManualDictation> getMyManualDictations(int _pageNumber) async {
    var client = http.Client();
    var memberId =
        await MySharedPreferences.instance.getStringValue(Keys.memberId);
    try {
      var endpointUrl = ApiUrlConstants.allMyManualDictationUrl;
      Map<String, dynamic> queryParams = {
        'MemberId': '$memberId',
        'PageIndex': '$_pageNumber',
      };
      String querryString = Uri(queryParameters: queryParams).query;
      var requestUrl = endpointUrl + '?' + querryString;
      final response = await client.get(Uri.encodeFull(requestUrl),
          headers: {"Accept": "application/json"});
      print(requestUrl);
      if (response.statusCode == 200) {
        GetAllMyManualDictation allManualDictations =
            parseMyManualDictations(response.body);
        return allManualDictations;
      }
    } on Exception catch (e) {
      print(e.toString);
    } finally {
      client.close();
    }

    return null;
  }

  static GetAllMyManualDictation parseMyManualDictations(String responseBody) {
    final GetAllMyManualDictation allManualDictations =
        GetAllMyManualDictation.fromJson(json.decode(responseBody));
    return allManualDictations;
  }
}
