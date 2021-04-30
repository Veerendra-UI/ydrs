import 'dart:convert';
import 'package:YOURDRS_FlutterAPP/common/app_constants.dart';
import 'package:YOURDRS_FlutterAPP/common/app_strings.dart';
import 'package:YOURDRS_FlutterAPP/network/repo/local/preference/local_storage.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:YOURDRS_FlutterAPP/network/models/manual_dictations/appointment_type.dart';
import 'package:YOURDRS_FlutterAPP/network/models/manual_dictations/document_type.dart';
import 'package:YOURDRS_FlutterAPP/network/models/manual_dictations/location_field_model.dart';
import 'package:YOURDRS_FlutterAPP/network/models/manual_dictations/practice.dart';
import 'package:YOURDRS_FlutterAPP/network/models/manual_dictations/provider_model.dart';
import '../../models/home/appointment.dart';
import '../../models/home/location.dart';
import '../../models/home/provider.dart';
import '../../models/home/schedule.dart';

class Services {
  static const String url = 'https://jsonplaceholder.typicode.com/users';

//------> getUsers service method also maintaining exception handling <---------
  static Future<List<Patients>> getUsers() async {
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<Patients> list = parseUsers(response.body);
        return list;
      } else {
        throw Exception("Error");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

// ------> mapping the data come from the model class Patients <---------
  static List<Patients> parseUsers(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Patients>((json) => Patients.fromJson(json)).toList();
  }

// ------> getSchedule service method also maintaining exception handling
  static Future<List<ScheduleList>> getSchedule(
    String date,
    int providerId,
    int locationId,
    int dictationId,
    String startDate,
    String endDate,
    String searchString,
    int memberId,
    int pageKey,
    CancelToken token
  ) async {
   
    String apiUrl = ApiUrlConstants.getSchedules;
    DateTime defaultDate = DateTime.now();
    var todayDate = AppConstants.parseDate(-1, AppConstants.MMDDYYYY,
        dateTime: defaultDate);
    final json = {
      "memberId": memberId ?? null,
      "appointmentStartDate": startDate != null
          ? startDate
          : date == null
              ? todayDate
              : date,
      "appointmentEndDate": endDate != null
          ? endDate
          : date == null
              ? todayDate
              : date,
      "locationId": locationId ?? null,
      "patientSearchString": searchString ?? null,
      "dictationStatusId": dictationId ?? null,
      "providerId": providerId ?? null,
      "page": pageKey ?? 1
    };

  Response response;
Dio dio = new Dio();
    response = await dio.post(
      apiUrl,
      data: jsonEncode(json),
      
      options: Options(
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'}
      )
    )
    .catchError(
      (e) {
        if (CancelToken.isCancel(e)) {
          print('$apiUrl: $e');
        }
      });

// ------> checking the condition statusCode success or not if success get data or throw the error <---------
    try {
      if (response.statusCode == 200) {
        Schedule schedule =
            Schedule.fromJson(response.data);
        return schedule.scheduleList;
      } else {
        throw Exception("Error");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
    
  }


// ------> getLocation service method also maintaining exception handling

  Future<Locations> getLocation() async {
    var client = http.Client();
    var memberId =
        await MySharedPreferences.instance.getStringValue(Keys.memberId);
    try {
      var endpointUrl = ApiUrlConstants.getLocation;
      Map<String, String> queryParams = {
        'MemberId': memberId,
      };
      String queryString = Uri(queryParameters: queryParams).query;
      var requestUrl = endpointUrl + '?' + queryString;
      final response = await client.get(Uri.encodeFull(requestUrl),
          headers: {"Accept": "application/json"});
//checking the condition statusCode success or not if success get data or throw the error <---------
      if (response.statusCode == 200) {
        Locations location = parseLocation(response.body);

        return location;
      } else {
        throw Exception("Error");
      }
    } catch (e) {
      throw Exception(e.toString());
    }finally{
      client.close();
    }
  }

// ------> mapping the data come from the model class Locations <---------
  static Locations parseLocation(String responseBody) {
    final Locations location = Locations.fromJson(json.decode(responseBody));
    return location;
  }

// ------> getProviders service also maintaining exception handling
  Future<Providers> getProviders() async {
    var client =http.Client();
    var memberId =
        await MySharedPreferences.instance.getStringValue(Keys.memberId);
    try {
      var endpointUrl = ApiUrlConstants.getProviders;
      Map<String, String> queryParams = {
        'MemberId': memberId,
      };
      String queryString = Uri(queryParameters: queryParams).query;
      var requestUrl = endpointUrl + '?' + queryString;
      final response = await client.get(Uri.encodeFull(requestUrl),
          headers: {"Accept": "application/json"});
// ------> checking the condition statusCode success or not if success get data or throw the error <---------
      if (response.statusCode == 200) {
        Providers provider = parseProviders(response.body);

        return provider;
      } else {
        throw Exception("Error");
      }
    } catch (e) {
      throw Exception(e.toString());
    }finally{
      client.close();
    }
  }

// ------> mapping the data come from the model class Providers <---------
  static Providers parseProviders(String responseBody) {
    final Providers provider = Providers.fromJson(json.decode(responseBody));
    return provider;
  }

  Future<Documenttype> getDocumenttype() async {
    var client = http.Client();
    try {
      var endpointUrl = ApiUrlConstants.getDocumenttype;

      var requestUrl = endpointUrl;
      final response = await client.get(Uri.encodeFull(requestUrl),
          headers: {"Accept": "application/json"});
      if (response.statusCode == 200) {
        Documenttype document = parseDocuments(response.body);

        return document;
      } else {
        throw Exception("Error");
      }
    } catch (e) {
      throw Exception(e.toString());
    }finally{
      client.close();
    }
  }

  static Documenttype parseDocuments(String responseBody) {
    final Documenttype document =
        Documenttype.fromJson(json.decode(responseBody));
    return document;
  }

  ///-----------------appointment type
  Future<AppointmentType> getAppointmenttype() async {
    try {
      var endpointUrl = ApiUrlConstants.getAppointmenttype;
      var requestUrl = endpointUrl;
      final response = await http.get(Uri.encodeFull(requestUrl),
          headers: {"Accept": "application/json"});
      if (response.statusCode == 200) {
        AppointmentType appointment = parseAppointment(response.body);
        return appointment;
      } else {
        throw Exception("Error");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static AppointmentType parseAppointment(String responsebody) {
    final AppointmentType appointment =
        AppointmentType.fromJson(json.decode(responsebody));
    return appointment;
  }

  ///------------Practice service method

  Future<Practices> getPratices() async {
    try {
      var endpointUrl = ApiUrlConstants.getPractices;
      var memberId =
          await MySharedPreferences.instance.getStringValue(Keys.memberId);

      Map<String, String> queryParams = {
        'LoggedInMemberId': memberId,
      };
      String queryString = Uri(queryParameters: queryParams).query;
      var requestUrl = endpointUrl + '?' + queryString;
      final response = await http.get(Uri.encodeFull(requestUrl),
          headers: {"Accept": "application/json"});
      if (response.statusCode == 200) {
        Practices practice = parsePractices(response.body);

        return practice;
      } else {
        throw Exception("Error");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Practices parsePractices(String responseBody) {
    final Practices practice = Practices.fromJson(json.decode(responseBody));
    return practice;
  }

  ///-------------Location service method
  Future<ExternalLocation> getExternalLocation(String PracticeIdList) async {
    try {
      var endpointUrl = ApiUrlConstants.getExternalLocation;
      var memberId =
          await MySharedPreferences.instance.getStringValue(Keys.memberId);

      Map<String, String> queryParams = {
        'LoggedInMemberId': memberId,
        'PracticeIdList': '$PracticeIdList',
      };
      String queryString = Uri(queryParameters: queryParams).query;
      var requestUrl = endpointUrl + '?' + queryString;
      final response = await http.get(Uri.encodeFull(requestUrl),
          headers: {"Accept": "application/json"});
      if (response.statusCode == 200) {
        ExternalLocation externalLocation =
            parseExternalLocation(response.body);

        return externalLocation;
      } else {
        throw Exception("Error");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static ExternalLocation parseExternalLocation(String responseBody) {
    final ExternalLocation externalLocation =
        ExternalLocation.fromJson(json.decode(responseBody));
    return externalLocation;
  }

  //------------------Providers service
  Future<ExternalProvider> getExternalProvider(
      String PracticeLocationId) async {
    if (PracticeLocationId != null) {
      try {
        var endpointUrl =
            ApiUrlConstants.getProvidersforSelectedPracticeLocation;
        var memberId =
            await MySharedPreferences.instance.getStringValue(Keys.memberId);

        Map<String, String> queryParams = {
          'LoggedInMemberId': memberId,
          'PracticeLocationId': '$PracticeLocationId',
        };
        String queryString = Uri(queryParameters: queryParams).query;
        var requestUrl = endpointUrl + '?' + queryString;
        final response = await http.get(Uri.encodeFull(requestUrl),
            headers: {"Accept": "application/json"});
        if (response.statusCode == 200) {
          ExternalProvider externalProvider =
              parseExternalProvider(response.body);
          return externalProvider;
        } else {
          throw Exception("Error");
        }
      } catch (e) {
        throw Exception(e.toString());
      }
    }

    return null;
  }

  static ExternalProvider parseExternalProvider(String responseBody) {
    final ExternalProvider externalProvider =
        ExternalProvider.fromJson(json.decode(responseBody));
    return externalProvider;
  }
}
