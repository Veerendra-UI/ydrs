import 'dart:convert';
import 'dart:io';
import 'package:YOURDRS_FlutterAPP/blocs/dictation_screen/audio_dictation_bloc.dart';
import 'package:YOURDRS_FlutterAPP/blocs/dictation_screen/audio_dictation_state.dart';
import 'package:YOURDRS_FlutterAPP/blocs/dictation_screen/audio_dictation_event.dart';
import 'package:YOURDRS_FlutterAPP/common/app_colors.dart';
import 'package:YOURDRS_FlutterAPP/common/app_constants.dart';
import 'package:YOURDRS_FlutterAPP/common/app_strings.dart';
import 'package:YOURDRS_FlutterAPP/common/app_text.dart';
import 'package:YOURDRS_FlutterAPP/helper/db_helper.dart';
import 'package:YOURDRS_FlutterAPP/network/models/manual_dictations/dictation.dart';
import 'package:YOURDRS_FlutterAPP/network/models/manual_dictations/external_dictation_attacment_model.dart';
import 'package:YOURDRS_FlutterAPP/network/models/manual_dictations/photo_list.dart';
import 'package:YOURDRS_FlutterAPP/network/repo/local/preference/local_storage.dart';
import 'package:YOURDRS_FlutterAPP/network/services/dictation/external_attachment_dictation.dart';
import 'package:YOURDRS_FlutterAPP/ui/audio_dictations/random_waves.dart';
import 'package:connectivity/connectivity.dart';
import 'package:file/local.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:YOURDRS_FlutterAPP/utils/route_generator.dart';
import 'package:YOURDRS_FlutterAPP/ui/manual_dictaions/manual_dictations.dart';

class ManualAudioDictation extends StatefulWidget {
  final String patientFName,
      patientLName,
      patientDob,
      patientDos,
      caseNum,
      attachmentname,
      physicalFileName,
      // docType,
      fileName,
      practiceName,
      providerName,
      locationName,
      descp,
      convertedImg;
  final List arrayOfImages;
  final int practiceId, providerId, locationId, docType, appointmentType;
  final int emergency;

  const ManualAudioDictation({
    Key key,
    this.patientFName,
    this.patientLName,
    this.patientDob,
    this.patientDos,
    this.fileName,
    this.docType,
    this.appointmentType,
    this.caseNum,
    this.attachmentname,
    this.physicalFileName,
    this.practiceName,
    this.providerName,
    this.locationName,
    this.emergency,
    this.descp,
    this.practiceId,
    this.providerId,
    this.locationId,
    this.arrayOfImages,
    this.convertedImg,
  }) : super(key: key);

  @override
  _ManualAudioDictationState createState() => _ManualAudioDictationState();
}

class _ManualAudioDictationState extends State<ManualAudioDictation> {
  bool isInternetAvailable = false;
  String name;
  var statusCode;
  var dicId;
  String attachmentContent;
  String abcd;
  var idGallery;
  LocalFileSystem localFileSystem;
  File image;
  Recording _current;
  RecordingStatus _currentStatus = RecordingStatus.Unset;
  bool viewVisible = true;
  String memberId;
  // bool uploadedToServerTrue = true;
  // bool uploadedToServerFalse = false;
  String attachmentNameMp4;
  bool isUpload = false;
  String mp4Base64, mp4Content;
  String attachmentTypeMp4 = 'mp4';
  List memberPhotos = [];
  bool emergencyAddOn = true;
  // final GlobalKey<State> _keyLoader = GlobalKey<State>();
  //Map<String, String> paths;

  int uploadedToServerTrue = 1;
  int uploadedToServerFalse = 0;

  final DateTime now = DateTime.now();
  final DateFormat formatter = DateFormat(AppConstants.dateFormat);

  // internet check
  Future<bool> checkNetwork() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      // I am connected to a wifi network.
      isInternetAvailable = true;
    } else {
      isInternetAvailable = false;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    this.localFileSystem = localFileSystem ?? LocalFileSystem();
    if (mounted) {
      /// bloc provider for init event
      BlocProvider.of<AudioDictationBloc>(context).add(InitRecord());
    }
  }

  @override
  void initState() {
    super.initState();
    checkNetwork();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: _body(),
        ),
      ),
    );
  }

  _body() {
    Future<void> showLoadingDialog(BuildContext context, String msg) async {
      return showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            // Future.delayed(Duration(seconds: 5), () {
            //   Navigator.of(context).pop(true);
            // });

            return WillPopScope(
                onWillPop: () async => false,
                child: SimpleDialog(

                    // backgroundColor: Colors.black54,
                    backgroundColor: Colors.white,
                    children: <Widget>[
                      Center(
                        child: Row(children: [
                          SizedBox(
                            width: 25,
                          ),
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(
                                CustomizedColors.primaryColor),
                          ),
                          SizedBox(
                            width: 35,
                          ),
                          Text(
                            msg,
                            style: TextStyle(
                                color: Colors.black,
                                fontFamily: AppFonts.regular,
                                fontSize: 18,
                                fontWeight: FontWeight.w600),
                          )
                        ]),
                      )
                    ]));
          });
    }

    return BlocListener<AudioDictationBloc, AudioDictationState>(
      listener: (context, state) async {
        attachmentContent = state.attachmentContent;

        if (isUpload) {
          if (attachmentContent != null && attachmentContent.isNotEmpty) {
            setState(() {
              mp4Base64 = attachmentContent;
              mp4Content = mp4Base64;
            });

            if (widget.arrayOfImages == null) {
              showLoadingDialog(context, "Uploading");
              await saveAttachmentDictation(state.attachmentContentType);

              await insertRecordsToDataBaseOnline();
              Navigator.of(this.context, rootNavigator: true).pop();
              memberPhotos.clear();
              await RouteGenerator.navigatorKey.currentState
                  .pushReplacementNamed(ManualDictations.routeName);
            } else {
              showLoadingDialog(context, "Uploading");
              await saveGalleryImageToServer();
              insertRecordsWithGalleryImagesOnline();
              Navigator.of(this.context, rootNavigator: true).pop();
              memberPhotos.clear();
              await RouteGenerator.navigatorKey.currentState
                  .pushReplacementNamed(ManualDictations.routeName);
            }
          }
        } else {
          isUpload = false;
        }

        _currentStatus = state.currentStatus;
        _current = state.current;
        viewVisible = state.viewVisible;
        if (state.errorMsg != null && state.errorMsg.isNotEmpty) {
          Scaffold.of(context).showSnackBar(SnackBar(
              content: Text(
            state.errorMsg ?? 'Something went wrong',
            style: TextStyle(fontFamily: AppFonts.regular),
          )));
        }
      },
      child: BlocBuilder<AudioDictationBloc, AudioDictationState>(
        builder: (context, state) {
          return Center(
            child: ListView(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width / 30,
                      vertical: MediaQuery.of(context).size.height / 150),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${_printDuration(_current?.duration)}",
                              style: TextStyle(fontFamily: AppFonts.regular),
                            ),
                            FlatButton(
                                onPressed: () async {
                                  /// bloc provider for save record event
                                  BlocProvider.of<AudioDictationBloc>(context)
                                      .add(StopRecord());
                                  // checkNetwork();

                                  if (isInternetAvailable == true) {
                                    if (widget.arrayOfImages != null) {
                                      ///upload gallery images to the server and db
                                      isUpload = true;
                                    } else if (widget.arrayOfImages == null) {
                                      ///upload camera image to the server and db
                                      //post to the API and get dictation ID
                                      isUpload = true;
                                    }
                                  } else
                                  //internet is not there
                                  {
                                    if (widget.arrayOfImages != null) {
                                      ///upload gallery images to the db

                                      // Fluttertoast.showToast(
                                      //     msg: AppStrings.noInternet,
                                      //     toastLength: Toast.LENGTH_SHORT,
                                      //     gravity: ToastGravity.CENTER,
                                      //     timeInSecForIosWeb: 2,
                                      //     backgroundColor:
                                      //         CustomizedColors.activeRedColor,
                                      //     textColor: CustomizedColors.textColor,
                                      //     fontSize: 16.0);
                                      showLoadingDialog(
                                          context, "Saving to Local DB");
                                      await insertRecordsWithGalleryImagesOffline();
                                      Navigator.of(this.context,
                                              rootNavigator: true)
                                          .pop();

                                      await RouteGenerator
                                          .navigatorKey.currentState
                                          .pushReplacementNamed(
                                              ManualDictations.routeName);
                                    } else if (widget.arrayOfImages == null) {
                                      ///upload camera image to the db
                                      ///
                                      // Fluttertoast.showToast(
                                      //     msg: AppStrings.noInternet,
                                      //     toastLength: Toast.LENGTH_SHORT,
                                      //     gravity: ToastGravity.CENTER,
                                      //     timeInSecForIosWeb: 2,
                                      //     backgroundColor:
                                      //         CustomizedColors.activeRedColor,
                                      //     textColor: CustomizedColors.textColor,
                                      //     fontSize: 16.0);
                                      showLoadingDialog(
                                          context, "Saving to Local DB");
                                      await insertRecordsToDataBaseOffline();
                                      Navigator.of(this.context,
                                              rootNavigator: true)
                                          .pop();

                                      await RouteGenerator
                                          .navigatorKey.currentState
                                          .pushReplacementNamed(
                                              ManualDictations.routeName);
                                    }
                                  }

                                  await Fluttertoast.showToast(
                                      msg: AppStrings.recordingSaved,
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor:
                                          CustomizedColors.toastColor,
                                      textColor: CustomizedColors.textColor,
                                      fontSize: 16.0);
                                },
                                child: Text(
                                  AppStrings.saveRecording,
                                  style: TextStyle(
                                      fontFamily: AppFonts.regular,
                                      fontWeight: FontWeight.bold,
                                      color: CustomizedColors.saveLaterColor,
                                      fontSize: 18),
                                ))
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              color: CustomizedColors.waveBGColor,
                              child: Visibility(
                                  maintainSize: true,
                                  maintainAnimation: true,
                                  maintainState: true,
                                  visible: viewVisible,

                                  /// calling random wave class
                                  child: RandomWaves()),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width / 30,
                                  vertical:
                                      MediaQuery.of(context).size.height / 150),
                              child: FlatButton(
                                padding: EdgeInsets.all(0),
                                onPressed: () {
                                  // print(
                                  //     'onPressed _currentStatus $_currentStatus');
                                  switch (_currentStatus) {
                                    case RecordingStatus.Initialized:
                                      {
                                        /// bloc provider for start record event
                                        BlocProvider.of<AudioDictationBloc>(
                                                context)
                                            .add(StartRecord());
                                        Fluttertoast.showToast(
                                            msg: AppStrings.recordingStarted,
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor:
                                                CustomizedColors.toastColor,
                                            textColor:
                                                CustomizedColors.textColor,
                                            fontSize: 16.0);
                                        break;
                                      }
                                    case RecordingStatus.Recording:
                                      {
                                        /// bloc provider for pause record event
                                        BlocProvider.of<AudioDictationBloc>(
                                                context)
                                            .add(PauseRecord());
                                        Fluttertoast.showToast(
                                            msg: AppStrings.recordingPaused,
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor:
                                                CustomizedColors.toastColor,
                                            textColor:
                                                CustomizedColors.textColor,
                                            fontSize: 16.0);
                                        break;
                                      }
                                    case RecordingStatus.Paused:
                                      {
                                        /// bloc provider for resume record event
                                        BlocProvider.of<AudioDictationBloc>(
                                                context)
                                            .add(ResumeRecord());
                                        Fluttertoast.showToast(
                                            msg: AppStrings.recordingResumed,
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor:
                                                CustomizedColors.toastColor,
                                            textColor:
                                                CustomizedColors.textColor,
                                            fontSize: 16.0);
                                        break;
                                      }
                                    case RecordingStatus.Stopped:
                                      {
                                        /// bloc provider for init event
                                        BlocProvider.of<AudioDictationBloc>(
                                                context)
                                            .add(InitRecord());
                                        break;
                                      }
                                    default:
                                      break;
                                  }
                                },
                                child: CircleAvatar(
                                  backgroundColor: CustomizedColors.waveColor,
                                  child: _buildText(_currentStatus),
                                  radius: 25,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  ///--------------setting timer format
  String _printDuration(Duration duration) {
    if (duration != null) {
      String twoDigits(int n) => n.toString().padLeft(2, "0");
      String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
      String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }
    return '';
  }

  ///-----------------play pause button icons
  Widget _buildText(RecordingStatus status) {
    var icon;
    switch (_currentStatus) {
      case RecordingStatus.Initialized:
        {
          icon = Icons.not_started;
          break;
        }
      case RecordingStatus.Recording:
        {
          icon = Icons.pause;
          break;
        }
      case RecordingStatus.Paused:
        {
          icon = Icons.play_arrow;
          break;
        }
      case RecordingStatus.Stopped:
        {
          icon = Icons.stop_outlined;
          break;
        }
      default:
        break;
    }
    return Icon(
      icon,
      color: CustomizedColors.textColor,
      size: 30,
    );
  }

//---------------Insert Dictation Data when online and camera images
  insertRecordsToDataBaseOnline() async {
    try {
      final String formatted = formatter.format(now);

      await DatabaseHelper.db.insertAudioRecords(PatientDictation(
        dictationId: dicId.toString() ?? null,
        attachmentType: attachmentTypeMp4,
        fileName: widget.patientFName +
            "_" +
            widget.patientLName +
            "_" +
            formatted +
            ".mp4",
        locationName: widget.locationName ?? null,
        attachmentName: widget.patientFName +
            "_" +
            widget.patientLName +
            "_" +
            formatted +
            ".mp4",
        locationId: widget.locationId ?? null,
        practiceName: widget.practiceName ?? null,
        practiceId: widget.practiceId ?? null,
        providerName: widget.providerName ?? null,
        providerId: widget.providerId ?? null,
        patientFirstName: widget.patientFName ?? null,
        patientLastName: widget.patientLName ?? null,
        patientDOB: widget.patientDob ?? null,
        dos: widget.patientDos ?? null,
        uploadedToServer: uploadedToServerTrue,
        isEmergencyAddOn: widget.emergency ?? null,
        externalDocumentTypeId: widget.docType ?? null,
        appointmentTypeId: widget.appointmentType ?? null,
        description: widget.descp ?? null,
        createdDate: '${DateTime.now()}' ?? 'NA',
        displayFileName:
            widget.patientFName + "_" + widget.patientLName + "_" + formatted,
      ));

      // List dictId = await DatabaseHelper.db.getDectionId();
      // int id;
      // id = dictId[dictId.length - 1].id;

      await DatabaseHelper.db.insertPhotoList(PhotoList(
          dictationLocalId: dicId ?? null,
          attachmentname: widget.attachmentname,
          createddate: '${DateTime.now()}',
          fileName: widget.fileName ?? null,
          attachmenttype: AppStrings.imageFormat,
          physicalfilename: widget.physicalFileName ?? "NA"));
    } catch (e) {
      print('_insertRecordsToDataBase ${e.toString()}');
    }
  }

//----------------insert into database if offline and camera images

  insertRecordsToDataBaseOffline() async {
    try {
      final String formatted = formatter.format(now);

      await DatabaseHelper.db.insertAudioRecords(PatientDictation(
        dictationId: dicId.toString() ?? null,
        attachmentType: "mp4",
        fileName: widget.patientFName +
            "_" +
            widget.patientLName +
            "_" +
            formatted +
            ".mp4",
        locationName: widget.locationName ?? null,
        attachmentName: widget.patientFName +
            "_" +
            widget.patientLName +
            "_" +
            formatted +
            ".mp4",
        locationId: widget.locationId ?? null,
        practiceName: widget.practiceName ?? null,
        practiceId: widget.practiceId ?? null,
        providerName: widget.providerName ?? null,
        providerId: widget.providerId ?? null,
        patientFirstName: widget.patientFName ?? null,
        uploadedToServer: uploadedToServerFalse,
        patientLastName: widget.patientLName ?? null,
        patientDOB: widget.patientDob ?? null,
        dos: widget.patientDos ?? null,
        isEmergencyAddOn: widget.emergency ?? null,
        externalDocumentTypeId: widget.docType ?? null,
        appointmentTypeId: widget.appointmentType ?? null,
        description: widget.descp ?? null,
        createdDate: '${DateTime.now()}' ?? 'NA',
        displayFileName:
            widget.patientFName + "_" + widget.patientLName + "_" + formatted,
      ));

      List dictId = await DatabaseHelper.db.getDectionId();
      int id;
      id = dictId[dictId.length - 1].id;

      await DatabaseHelper.db.insertPhotoList(PhotoList(
          dictationLocalId: id,
          attachmentname: widget.attachmentname,
          createddate: '${DateTime.now()}',
          fileName: widget.fileName ?? null,
          attachmenttype: AppStrings.imageFormat,
          physicalfilename: widget.physicalFileName ?? null));
    } catch (e) {
      print('_insertRecordsToDataBase ${e.toString()}');
    }
  }

//---------post to the API
  saveAttachmentDictation(String attachmentContentType) async {
    try {
      //when path is null no camera image is selected
      if (widget.physicalFileName == null) {
        final String formatted = formatter.format(now);
        attachmentNameMp4 = '${widget.patientFName}' +
            '_' +
            '${widget.patientLName}' +
            '_' +
            '${formatted}' +
            '.mp4';
        String attachmentTypeJpg = "jpg";
        name = '${widget.patientFName}_${widget.patientLName}_${formatted}' +
            '.jpg';

        if (widget.emergency == 0) {
          emergencyAddOn = false;
        } else {
          emergencyAddOn = true;
        }

        ExternalDictationAttachment apiAttachmentPostServices =
            ExternalDictationAttachment();
        SaveExternalDictationOrAttachment saveDictationAttachments =
            await apiAttachmentPostServices.postApiServiceMethod(
          widget.practiceId,
          widget.locationId,
          widget.providerId,
          widget.patientFName,
          widget.patientLName,
          widget.patientDob,
          widget.patientDos,
          memberId,
          widget.docType,
          widget.appointmentType,
          emergencyAddOn,
          widget.descp,
          attachmentTypeMp4, //attachmentTypeMp4,
          mp4Base64,
          attachmentNameMp4,
          null,
        );
        dicId = saveDictationAttachments.dictationId;
        statusCode = saveDictationAttachments?.header?.statusCode;
        //printing status code
        // print("status $statusCode");
      }
      //saving when selected camera images selected and path is not empty
      else {
        final bytes = File(widget?.physicalFileName ?? null).readAsBytesSync();
        String img64 = base64Encode(bytes);
        final String formatted = formatter.format(now);
        attachmentNameMp4 = '${widget.patientFName}' +
            '_' +
            '${widget.patientLName}' +
            '_' +
            '${formatted}' +
            '.mp4';
        String attachmentTypeJpg = "jpg";
        name = '${widget.patientFName}_${widget.patientLName}_${formatted}' +
            '.jpg';

        memberPhotos.add({
          "header": {
            "status": "string",
            "statusCode": "string",
            "statusMessage": "string"
          },
          "content": img64,
          "name": name,
          "attachmentType": "jpg"
        });

        if (widget.emergency == 0) {
          emergencyAddOn = false;
        } else {
          emergencyAddOn = true;
        }

        ExternalDictationAttachment apiAttachmentPostServices =
            ExternalDictationAttachment();
        SaveExternalDictationOrAttachment saveDictationAttachments =
            await apiAttachmentPostServices.postApiServiceMethod(
          widget.practiceId,
          widget.locationId,
          widget.providerId,
          widget.patientFName,
          widget.patientLName,
          widget.patientDob,
          widget.patientDos,
          memberId,
          widget.docType,
          widget.appointmentType,
          emergencyAddOn,
          widget.descp,
          // img64 ?? null, //img64
          // name ?? null, //name
          // attachmentTypeJpg ?? null, //attachmentTypeJpg,
          attachmentTypeMp4, //attachmentTypeMp4,
          mp4Base64,
          attachmentNameMp4,
          memberPhotos,
        );

        dicId = saveDictationAttachments.dictationId;
        statusCode = saveDictationAttachments?.header?.statusCode;
        //printing status code
        // print("status $statusCode");
      }
    } catch (e) {
      print('SaveAttachmentDictation exception ${e.toString()}');
    }
  }

//----------------getting memberId from sharedPrefarance
  _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      memberId = (prefs.getString(Keys.memberId) ?? '');
    });
  }

//----------------insert records with gallery images to db when online
  insertRecordsWithGalleryImagesOnline() async {
    final String formatted = formatter.format(now);
    try {
      for (int i = 0; i < widget.arrayOfImages.length; i++) {
        await DatabaseHelper.db.insertPhotoList(PhotoList(
            dictationLocalId: int.parse(dicId),
            attachmentname: ('${(widget.arrayOfImages[i])}'),
            fileName: '${widget.patientFName ?? ''}_ ${formatted}',
            createddate: '${DateTime.now()}',
            attachmenttype: AppStrings.imageFormat,
            physicalfilename: '${widget.arrayOfImages[i]}'));
      }
      await DatabaseHelper.db.insertAudioRecords(
        PatientDictation(
          fileName: widget.patientFName +
              "_" +
              widget.patientLName +
              "_" +
              formatted +
              ".mp4",
          attachmentType: 'mp4',
          dictationId: dicId.toString(),
          locationName: widget.locationName ?? "",
          locationId: widget.locationId ?? "",
          practiceName: widget.practiceName ?? "",
          practiceId: widget.practiceId ?? "",
          providerName: widget.providerName ?? "",
          providerId: widget.providerId ?? "",
          patientFirstName: widget.patientFName ?? "",
          patientLastName: widget.patientLName ?? "",
          patientDOB: widget.patientDob ?? "",
          dos: widget.patientDos ?? "",
          isEmergencyAddOn: widget.emergency ?? "",
          externalDocumentTypeId: widget.docType ?? "",
          appointmentTypeId: widget.appointmentType ?? "",
          description: widget.descp ?? "",
          memberId: int.parse(memberId) ?? "",
          createdDate: '${DateTime.now()}',
          uploadedToServer: uploadedToServerTrue,
          statusId: null,
        ),
      );
    } on PlatformException catch (e) {
      print("Exception handling" + e.toString());
    }
  }

//----------------insert records with gallery images to db when offline
  insertRecordsWithGalleryImagesOffline() async {
    final String formatted = formatter.format(now);
    try {
      for (int i = 0; i < widget.arrayOfImages.length; i++) {
        List listId = await DatabaseHelper.db.getGalleryId();
        idGallery = listId[listId.length].id;
        await DatabaseHelper.db.insertPhotoList(PhotoList(
            dictationLocalId: idGallery ?? "NA",
            attachmentname: ('${(widget.arrayOfImages[i])}'),
            fileName: '${widget.patientFName ?? ''}_ ${formatted}',
            createddate: '${DateTime.now()}',
            attachmenttype: AppStrings.imageFormat,
            physicalfilename: '${widget.arrayOfImages[i]}'));
      }
      await DatabaseHelper.db.insertAudioRecords(
        PatientDictation(
          attachmentType: 'mp4',
          fileName: widget.patientFName +
              "_" +
              widget.patientLName +
              "_" +
              formatted +
              ".mp4",
          attachmentName: widget.patientFName +
              "_" +
              widget.patientLName +
              "_" +
              formatted +
              ".mp4",
          displayFileName:
              widget.patientFName + "_" + widget.patientLName + "_" + formatted,
          dictationId: null,
          locationName: widget.locationName ?? "",
          locationId: widget.locationId ?? "",
          practiceName: widget.practiceName ?? "",
          practiceId: widget.practiceId ?? "",
          providerName: widget.providerName ?? "",
          providerId: widget.providerId ?? "",
          patientFirstName: widget.patientFName ?? "",
          patientLastName: widget.patientLName ?? "",
          patientDOB: widget.patientDob ?? "",
          dos: widget.patientDos ?? "",
          isEmergencyAddOn: widget.emergency ?? "",
          externalDocumentTypeId: widget.docType ?? "",
          appointmentTypeId: widget.appointmentType ?? "",
          description: widget.descp ?? "",
          memberId: int.parse(memberId) ?? "",
          createdDate: '${DateTime.now()}',
          uploadedToServer: uploadedToServerFalse,
          statusId: null,
        ),
      );
    } on PlatformException catch (e) {
      print("Exception handling" + e.toString());
    }
  }

//-----------------gallery images to API
  saveGalleryImageToServer() async {
    String attachmentTypeJpg = 'jpg';

    final String formatted = formatter.format(now);
    attachmentNameMp4 = '${widget.patientFName}' +
        '_' +
        '${widget.patientLName}' +
        '_' +
        '${formatted}' +
        '.mp4';

    for (int i = 0; i < widget.arrayOfImages.length; i++) {
      final bytes = File('${widget.arrayOfImages[i]}').readAsBytesSync();
      String images = base64Encode(bytes);
      // name = '${widget.patientFName}' +
      //     '_' +
      //     '${widget.patientLName}' +
      //     '_' +
      //     '${formatted}' +
      //     '${widget.arrayOfImages[i]}';

      memberPhotos.add(
        {
          "header": {
            "status": "string",
            "statusCode": "string",
            "statusMessage": "string"
          },
          "content": images,
          "name": '${widget.patientFName}' +
              '_' +
              '${widget.patientLName}' +
              '_' +
              '${i}' +
              '_' +
              '${formatted}'
                  '.jpg',
          "attachmentType": "jpg"
        },
      );
    }

    try {
      if (widget.emergency == 0) {
        emergencyAddOn = false;
      } else {
        emergencyAddOn = true;
      }
      ExternalDictationAttachment apiAttachmentPostServices =
          ExternalDictationAttachment();
      SaveExternalDictationOrAttachment saveDictationAttachments =
          await apiAttachmentPostServices.postApiServiceMethod(
        widget.practiceId,
        widget.locationId,
        widget.providerId,
        widget.patientFName,
        widget.patientLName,
        widget.patientDob,
        widget.patientDos,
        memberId,
        widget.docType,
        widget.appointmentType,
        emergencyAddOn,
        widget.descp,
        // img64 ?? null, //img64
        // name ?? null, //name
        // attachmentTypeJpg ?? null, //attachmentTypeJpg,
        attachmentTypeMp4, //attachmentTypeMp4,
        mp4Base64,
        attachmentNameMp4,
        memberPhotos, //memberPhotos,
      );
      dicId = saveDictationAttachments.dictationId.toString();

      statusCode = saveDictationAttachments?.header?.statusCode;
      print("status $statusCode");
    } catch (e) {}
// }
  }
}
