import 'dart:async';

import 'package:YOURDRS_FlutterAPP/common/app_strings.dart';
import 'package:YOURDRS_FlutterAPP/network/models/external_dictations/get_all_external_attachments_model.dart';
import 'package:YOURDRS_FlutterAPP/network/models/external_dictations/get_external_document_details.dart';
import 'package:YOURDRS_FlutterAPP/network/models/external_dictations/get_external_photos.dart';
import 'package:YOURDRS_FlutterAPP/network/repo/local/preference/local_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AllMyExternalAttachments {
  var client1=http.Client();
  //-------------------External display name api
  Future<GetAllExternalAttachments> getMyAllExternalAttachemnts(
      _pageNumber) async {
    var memberId =
    await MySharedPreferences.instance.getStringValue(Keys.memberId);
    try {
      var endpointUrl = ApiUrlConstants.allMyExternalAttachmentUrl;
      Map<String, dynamic> queryParams = {
        'MemberId': '$memberId',
        'PageIndex': '$_pageNumber',
      };
      String querryString = Uri(queryParameters: queryParams).query;
      var requestUrl = endpointUrl + '?' + querryString;
      // print('requestUrl $requestUrl');
      final response = await client1.get(Uri.encodeFull(requestUrl),
          headers: {"Accept": "application/json"});
      // print('response' + response.body);
      if (response.statusCode == 200) {
        GetAllExternalAttachments allExternalAttachment =
        parseAllExternalAttachment(response.body);
        print(allExternalAttachment);
        return allExternalAttachment;
      }
    } on Exception catch (e) {
      print(e.toString);
    }
    finally{
      // client1.close();
    }
  }

  static GetAllExternalAttachments parseAllExternalAttachment(
      String responseBody) {
    final GetAllExternalAttachments allExternalAttachment =
    GetAllExternalAttachments.fromJson(json.decode(responseBody));
    print(allExternalAttachment);
    return allExternalAttachment;
  }
}

  //------------------------------get external attachment details
class GetExternalDocumentDetailsService {
  var client2=http.Client();
  Future<GetExternalDocumentDetails> getExternalDocumentDetails(
      int externalAttachmentId) async {
    try {
      var endpointUrl = ApiUrlConstants.getExternalDocumentDetails;
      Map<String, dynamic> queryParams = {
        'ExternalDocumentUploadId': '$externalAttachmentId',
      };
      String querryString = Uri(queryParameters: queryParams).query;
      var requestUrl = endpointUrl + '?' + querryString;
      // print('requestUrl $requestUrl');
      final response = await client2.get(Uri.encodeFull(requestUrl),
          headers: {"Accept": "application/json"});
      //print('response' + response.body);
      if (response.statusCode == 200) {
        GetExternalDocumentDetails getExternalDocumentDetails =
        parseGetExternalDocumentDetails(response.body);
        // print(getExternalDocumentDetails);
        return getExternalDocumentDetails;
      }
    } on Exception catch (e) {
      print(e.toString);
    }
    finally{
      client2.close();
    }
  }

  static GetExternalDocumentDetails parseGetExternalDocumentDetails(
      String responseBody) {
    final GetExternalDocumentDetails getExternalDocumentDetails =
    GetExternalDocumentDetails.fromJson(json.decode(responseBody));
    // print(getExternalDocumentDetails);
    return getExternalDocumentDetails;
  }
}

  //-----------------------------get external attachment photos
class GetExternalPhotosService{
  //var client3=http.Client();
Future<GetExternalPhotos>getExternalPhotos(String name)async{
  try {
    var endpointUrl = ApiUrlConstants.getExternalPhotos;
    Map<String, dynamic> queryParams = {
      'PhysicalFileName': '$name',
    };
    String querryString = Uri(queryParameters: queryParams).query;
    var requestUrl = endpointUrl + '?' + querryString;
   // print('requestUrl $requestUrl');
    final response = await http.get(Uri.encodeFull(requestUrl),
        headers: {"Accept": "application/json"});
   // print('response' + response.body);
    if (response.statusCode == 200) {
      GetExternalPhotos getExternalPhotos =
      parseGetExternalPhotos(response.body);
      // print(getExternalPhotos);
      return getExternalPhotos;
    }
  } on Exception catch (e) {
    print(e.toString);
  }
  // finally{
  //   client3.close();
  // }

  }
  static GetExternalPhotos parseGetExternalPhotos(
      String responseBody) {
    final GetExternalPhotos getExternalPhotos =
    GetExternalPhotos.fromJson(json.decode(responseBody));
    // print(getExternalPhotos);
    return getExternalPhotos;
  }

}

