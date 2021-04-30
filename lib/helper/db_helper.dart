import 'dart:io';
import 'package:YOURDRS_FlutterAPP/common/app_strings.dart';
import 'package:YOURDRS_FlutterAPP/network/models/manual_dictations/dictation.dart';
import 'package:YOURDRS_FlutterAPP/network/models/manual_dictations/photo_list.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:YOURDRS_FlutterAPP/network/models/external_dictations/external_databse_model.dart';

class DatabaseHelper {
  static Database _database;
  static final DatabaseHelper db = DatabaseHelper._();

  DatabaseHelper._();

  Future<Database> get database async {
    // If database exists, return database
    if (_database != null) return _database;

    // If database don't exists, create one
    _database = await initDB();

    return _database;
  }

  // Create the database and the User table
  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, AppStrings.databaseName);

    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute(AppStrings.tableDictation);
      await db.execute(AppStrings.tblPhotoList);
      await db.execute(AppStrings.tblPhotoListExt);

      await db.execute(AppStrings.tableExternalAttachment);
    });
  }

// Insert Audio and Manual dictation
  insertAudioRecords(PatientDictation newAudio) async {
    var db = await database;
    //Exception handling
    try {
      var res = await db.insert(AppStrings.dbTableDictation, {
        AppStrings.colId: newAudio.id,
        // AppStrings.col_AudioFile :newAudio.audioFile,
        AppStrings.col_dictationId: newAudio.dictationId,
        AppStrings.col_AudioFileName: newAudio.fileName,
        AppStrings.col_PatientFname: newAudio.patientFirstName,
        AppStrings.col_PatientLname: newAudio.patientLastName,
        AppStrings.col_CreatedDate: newAudio.createdDate,
        AppStrings.col_Patient_DOB: newAudio.patientDOB,
        AppStrings.col_DictationTypeId: newAudio.dictationTypeId,
        AppStrings.col_EpisodeId: newAudio.episodeId,
        AppStrings.col_attachmentSizeBytes: newAudio.attachmentSizeBytes,
        AppStrings.col_attachmentType: newAudio.attachmentType,
        AppStrings.col_MemberId: newAudio.memberId,
        AppStrings.col_AttachmentName:newAudio.attachmentName,
        AppStrings.col_StatusId: newAudio.statusId,
        AppStrings.col_UploadedToServer: newAudio.uploadedToServer,
        AppStrings.col_DisplayFileName: newAudio.displayFileName,
        AppStrings.col_PhysicalFileName: newAudio.physicalFileName,
        AppStrings.col_DOS: newAudio.dos,
        AppStrings.col_PracticeId: newAudio.practiceId,
        AppStrings.col_PracticeName: newAudio.practiceName,
        AppStrings.col_LocationId: newAudio.locationId,
        AppStrings.col_LocationName: newAudio.locationName,
        AppStrings.col_ProviderId: newAudio.providerId,
        AppStrings.col_ProviderName: newAudio.providerName,
        AppStrings.col_AppointmentTypeId: newAudio.appointmentTypeId,
        AppStrings.col_AppointmentId: newAudio.appointmentId,
        AppStrings.col_isEmergencyAddOn: newAudio.isEmergencyAddOn,
        AppStrings.col_ExternalDocumentTypeId: newAudio.externalDocumentTypeId,
        AppStrings.col_Description: newAudio.description,
        AppStrings.col_AppointmentProvider: newAudio.appointmentProvider,
        AppStrings.col_isSelected: newAudio.isSelected,
      });
      return res;
    } catch (e) {
      print(e.toString());
    }
  }

  // Insert External Dictation
  insertExternalAttachmentData(ExternalAttachmentList eDict) async {
    var db = await database;

    //Exception handling
    try {
      var externalDictationId =
          await db.insert(AppStrings.dbTableExternalAttachment, {
        // AppStrings.col_External_Id: eDict.id,
        AppStrings.col_ExternalAttachmentId: eDict.externalattachmentid,
        AppStrings.col_ExternalPatientFname: eDict.patientfirstname,
        AppStrings.col_ExternalPatientLname: eDict.patientlastname,
        AppStrings.col_ExternalCreatedDate: eDict.createddate,
        AppStrings.col_ExternalPatient_DOB: eDict.patientdob,
        AppStrings.col_ExternalMemberId: eDict.memberid,
        AppStrings.col_ExternalStatusId: eDict.statusid,
        AppStrings.col_ExternalUploadedToServer: eDict.uploadedtoserver,
        AppStrings.col_ExternalDisplayFileName: eDict.displayfilename,
        AppStrings.col_ExternalDOS: eDict.dos,
        AppStrings.col_ExternalPracticeId: eDict.practiceid,
        AppStrings.col_ExternalPracticeName: eDict.practicename,
        AppStrings.col_ExternalLocationId: eDict.locationid,
        AppStrings.col_ExternalLocationName: eDict.locationname,
        AppStrings.col_ExternalProviderId: eDict.providerid,
        AppStrings.col_ExternalProviderName: eDict.providername,
        AppStrings.col_ExternalAppointmentTypeId: eDict.appointmenttypeid,
        AppStrings.col_ExternalAppointmentType: eDict.appointmenttype,
        AppStrings.col_ExternalisEmergencyAddOn: eDict.isemergencyaddon,
        AppStrings.col_ExternalDocumentType:
            eDict.externaldocumenttype, //changing
        AppStrings.col_Ex_ExternalDocumentTypeId: eDict.externaldocumenttypeid,
        AppStrings.col_ExternalDes: eDict.description
      });
      return externalDictationId;
    } catch (e) {
      print('insertExternalAttachment ${e.toString()}');
    }
  }

  Future<int> insertPhotoLists(PhotoList photoList) async {

    var db = await database;

//exception handling
    try {
      var externalPhotoListId = await db.insert(AppStrings.dbTablePhotoListExt, {
        AppStrings.col_PhotoList_Id: photoList.id,
        AppStrings.col_PhotoListDictationId: photoList.dictationLocalId,
        AppStrings.col_PhotoListExternalAttachmentId: photoList.externalattachmentlocalid,
        AppStrings.col_PhotoListAttachmentName: photoList.attachmentname,
        AppStrings.col_PhotoListAttachmentSizeBytes: photoList.attachmentsizebytes,
        AppStrings.col_PhotoListAttachmentAttachmentType: photoList.attachmenttype,
        AppStrings.col_PhotoListAttachmentFileName: photoList.fileName,
        AppStrings.col_PhotoListAttachmentPhysicalFileName: photoList.physicalfilename,
        AppStrings.col_PhotoListAttachmentCreatedDate: photoList.createddate
      });
      return externalPhotoListId;
    } catch (e) {
      print('insertPhotoList ${e.toString()}');
    }

    return -1;
  }

  //insert photo list
  insertPhotoList(PhotoList photoList) async {
    var db = await database;

    //exception handling
    try {
      var externalPhotoListId = await db.insert(AppStrings.dbTablePhotoList, {
        AppStrings.col_PhotoList_Id: photoList.id,
        AppStrings.col_PhotoListDictationId: photoList.dictationLocalId,
        AppStrings.col_PhotoListExternalAttachmentId:
            photoList.externalattachmentlocalid,
        AppStrings.col_PhotoListAttachmentName: photoList.attachmentname,
        AppStrings.col_PhotoListAttachmentSizeBytes:
            photoList.attachmentsizebytes,
        AppStrings.col_PhotoListAttachmentAttachmentType:
            photoList.attachmenttype,
        AppStrings.col_PhotoListAttachmentFileName: photoList.fileName,
        AppStrings.col_PhotoListAttachmentPhysicalFileName:
            photoList.physicalfilename,
        AppStrings.col_PhotoListAttachmentCreatedDate: photoList.createddate
      });
      return externalPhotoListId;
    } catch (e) {
      print('insertPhotoList ${e.toString()}');
    }

  }
  //external photo list table


  ///Delete all older records
  deleteAllOlderRecords() async {
    var db = await database;
    try {
      var res = await db.rawDelete(AppStrings.deleteOlderRecords);
      return res;
    } catch (e) {
      print(e.toString());
    }
  }

  ///-----------delete all older External Records From Local Db
  deleteAllExternalRecords() async {
    var db = await database;
    try {
      var res = await db.rawDelete(AppStrings.deleteAllExternalRecords);
      return res;
    } catch (e) {
      print(e.toString());
    }
  }

//get all images
  Future<List<PhotoList>> getAllImages(int Id) async {
    var db = await database;

    //Exception handling
    try {
      var res = await db
          .rawQuery("SELECT physicalfilename FROM photolistlocal WHERE id=$Id");
      List<PhotoList> list = res.isNotEmpty
          ? res.map((c) {
              var user = PhotoList.fromMap(c);
              return user;
            }).toList()
          : [];
      print(list);
      return list;
    } catch (e) {
      print(e.toString());
    }
  }

  Future<List<PatientDictation>> getId(int episodeId, int appointmentId) async {
    var db = await database;
    var dicationId;

    ///Exception handling
    try {
      var res = await db.rawQuery(
          "SELECT id FROM dictationlocal WHERE episodeid=$episodeId and appointmentid=$appointmentId");
      List<PatientDictation> list = res.isNotEmpty
          ? res.map((c) {
              var user = PatientDictation.fromMap(c);
              dicationId = PatientDictation(id: c["id"]);
              return user;
            }).toList()
          : [];
      print(list);
      return list;
    } catch (e) {
      print(e.toString());
    }
  }

  ///get dictation id
  Future<List<PatientDictation>> getDectionId() async {
    var db = await database;
    var dicationId;

    ///Exception handling
    try {
      var res = await db.rawQuery(AppStrings.selectIdFromTable);
      List<PatientDictation> list = res.isNotEmpty
          ? res.map((c) {
              var user = PatientDictation.fromMap(c);
              dicationId = PatientDictation(id: c["id"]);
              return user;
            }).toList()
          : [];
      print(list);
      return list;
    } catch (e) {
      print(e.toString());
    }
  }

  Future<List<PatientDictation>> getGalleryId() async {
    var db = await database;
    var dicationId;

//Exception handling
    try {
      var res = await db.rawQuery("SELECT id FROM dictationlocal");

      List<PatientDictation> list = res.isNotEmpty
          ? res.map((c) {
              var user = PatientDictation.fromMap(c);
              dicationId = PatientDictation(id: c["id"]);

              return user;
            }).toList()
          : [];
      print(list);
      return list;
    } catch (e) {
      print(e.toString());
    }
  }

  update(int id, int dictationId) async {
    final db = await database;
    var result = await db.rawUpdate(
        "UPDATE dictationlocal  SET dictationId =$dictationId WHERE id=$id");
    return result;
  }

  //Fetch all the records
  Future<List<PatientDictation>> getAllDictations() async {
    var db = await database;

    //Exception handling
    try {
      var res = await db.rawQuery(AppStrings.selectAllDictationsQuery);
      List<PatientDictation> list = res.isNotEmpty
          ? res.map((c) {
              var user = PatientDictation.fromMap(c);
              return user;
            }).toList()
          : [];
      print(list);
      return list;
    } catch (e) {
      print(e.toString());
    }
  }

  Future<List<PhotoList>> getAttachmentImages(int id) async {
    List<dynamic> resultt;
    var db = await database;
    //Exception handling
    try {
      resultt = await db.rawQuery(
          "SELECT * FROM photolistlocaltable WHERE externalattachmentlocalid=$id ");
      List<PhotoList> list = resultt.isNotEmpty
          ? resultt.map((c) {
              var user = PhotoList.fromMap(c);
              return user;
            }).toList()
          : [];
      print(list);
      return list;
    } catch (e) {
      print('getAttachmentImages ' + e.toString());
    }
  }

  ///get all external attachments

  Future<List<ExternalAttachmentList>> getAllExtrenalAttachmentList() async {
    var db = await database;
    var id;
    //Exception handling
    try {
      var res = await db.rawQuery(AppStrings.selectQuery);
      List<ExternalAttachmentList> list = res.isNotEmpty
          ? res.map((c) {
              var user = ExternalAttachmentList.fromMap(c);
              id = ExternalAttachmentList(id: c["id"]);
              return user;
            }).toList()
          : [];
      return list;
    } catch (e) {
      print(e.toString());
    }
  }

  //...sync offline data to server
  Future<List<Map<String, dynamic>>> queryUnsynchedRecords() async {
    Database db = await database;
    return await db
        .rawQuery('SELECT * FROM dictationlocal WHERE uploadedtoserver = 0');
  }

//close the db
  // db.close();
  Future close() async {
    return await db.close();
  }
}
