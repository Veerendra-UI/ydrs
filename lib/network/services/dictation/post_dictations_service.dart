import 'dart:convert';
import 'package:YOURDRS_FlutterAPP/common/app_colors.dart';
import 'package:YOURDRS_FlutterAPP/common/app_constants.dart';
import 'package:YOURDRS_FlutterAPP/common/app_strings.dart';
import 'package:YOURDRS_FlutterAPP/network/models/dictations/post_dictations_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

////service class starts from here
class PostDictationsService {
  // ignore: missing_return
  Future<PostDictationsModel> postApiMethod(
      int memberid,
      String dob,
      int episodeId,
      int episodeAppointmentRequestId,
      int membeRoleId,
      int dictationTypeId,
      String patientFName,
      String patientLName,
      String caseNum,
      String patientDob,
      String attachmentContent,
      String attachmentName,
      String dictationTypeName) async {
    String apiUrl = ApiUrlConstants.saveDictations;
    final DateTime now = DateTime.now();
    var client = http.Client();
    String displayName = attachmentName.replaceFirst('.mp4', '');
    final json = {
      "header": {
        "status": "string",
        "statusCode": "string",
        "statusMessage": "string"
      },
      "id": null,
      "dictationId": null,
      "episodeId": episodeId ?? null,
      "episodeAppointmentRequestId": episodeAppointmentRequestId ?? null,
      "attachmentName":attachmentName,
      "attachmentContent": attachmentContent?.toString() ,
      "attachmentSizeBytes": attachmentContent?.length ?? null,
      "attachmentType": "mp4",
      "memberId": memberid ?? null,
      "statusId": 107,
      "fileName": attachmentName,
      "createdBy": memberid ?? null,
      "createdDate": AppConstants.parseDate(-1, AppConstants.MMDDYYYY,
          dateTime: now) ?? null,
      "uploadedToServer": true,
      "rejectionComments": null,
      "memberRoleId": membeRoleId ?? null,
      "providerId": null,
      "attachmentPhysicalFileName": attachmentName,
      "patientFirstName": patientFName ?? null,
      "patientLastName": patientLName ?? null,
      "patientDOB":  patientDob,
      "dos": null,
      "practiceId": null,
      "locationId": null,
      "cptCodeIds": null,
      "appointmentTypeId": null,
      "displayFileName":displayName,
      "isW9Doc": true,
      "consolidatedDocExists": true,
      "memberPhotos": null,
      "photoNameList": null,
      "dictationTypeId": dictationTypeId!=null ? dictationTypeId:null,
      "nbrMemberId": null,
      "nbrMemberName": null,
      "isStatFile": null,
      "externalDocumentUploadId": null,
      "isEmergencyAddOn": false,
      "externalDocumentTypeId": null,
      "description": null,
      "appointmentProvider": null
    };

    ///checking  response status of Api on success and failure
    try {
      http.Response response = await client.post(
        apiUrl,
        body: jsonEncode(json),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      var jsonResponse = jsonDecode(response.body);
      return PostDictationsModel.fromJson(jsonResponse);
    } catch (e) {
      print("${e.toString()}");
    }
    finally{
      client.close();
    }
  }
}
