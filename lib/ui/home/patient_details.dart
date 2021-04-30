import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:YOURDRS_FlutterAPP/common/app_colors.dart';
import 'package:YOURDRS_FlutterAPP/common/app_log_helper.dart';
import 'package:YOURDRS_FlutterAPP/common/app_strings.dart';
import 'package:YOURDRS_FlutterAPP/common/app_text.dart';
import 'package:YOURDRS_FlutterAPP/common/app_toast_message.dart';
import 'package:YOURDRS_FlutterAPP/helper/db_helper.dart';
import 'package:YOURDRS_FlutterAPP/network/models/dictations/allImages_models.dart';
import 'package:YOURDRS_FlutterAPP/network/models/dictations/allImages_models.dart';
import 'package:YOURDRS_FlutterAPP/network/models/dictations/dictations_model.dart';
import 'package:YOURDRS_FlutterAPP/network/models/dictations/post_dictations_model.dart';
import 'package:YOURDRS_FlutterAPP/network/models/home/schedule.dart';
import 'package:YOURDRS_FlutterAPP/network/models/manual_dictations/dictation.dart';
import 'package:YOURDRS_FlutterAPP/network/models/manual_dictations/photo_list.dart';
import 'package:YOURDRS_FlutterAPP/network/repo/local/preference/local_storage.dart';
import 'package:YOURDRS_FlutterAPP/network/services/dictation/dictation_services.dart';
import 'package:YOURDRS_FlutterAPP/network/services/dictation/getAllImages_service.dart';
import 'package:YOURDRS_FlutterAPP/network/services/dictation/post_dictation_image_service.dart';
import 'package:YOURDRS_FlutterAPP/ui/home/view_images.dart';
import 'package:YOURDRS_FlutterAPP/ui/patient_dictation/dictation_type.dart';
import 'package:YOURDRS_FlutterAPP/utils/route_generator.dart';
import 'package:YOURDRS_FlutterAPP/widget/buttons/material_buttons.dart';
import 'package:YOURDRS_FlutterAPP/widget/buttons/mic_button.dart';
import 'package:YOURDRS_FlutterAPP/widget/buttons/raised_buttons.dart';
import 'package:connectivity/connectivity.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


class PatientDetail extends StatefulWidget {

  static const String routeName = '/PatientDetails';
  @override
  _PatientDetailState createState() => _PatientDetailState();
}

class _PatientDetailState extends State<PatientDetail> {

  List allDtion = List();
  List allPrevDtion = List();
  List myPrevDtion = List();

  String dictationId;



  AllDtion(int appointmentId) async {
    AllDictationService apiServices1 = AllDictationService();
    Dictations allDictations =
    await apiServices1.getDictations(appointmentId);
    allDtion = allDictations.audioDictations;
  }

  AllPrevDtion(int episodeId, int appointmentId) async {
    AllPreviousDictationService apiServices2 = AllPreviousDictationService();
    Dictations allPreviousDictations =
    await apiServices2.getAllPreviousDictations(episodeId, appointmentId);
    allPrevDtion = allPreviousDictations.audioDictations;
  }

  MyPrevDtion(int episodeId, int appointmentId) async {
    MyPreviousDictationService apiServices3 = MyPreviousDictationService();
    Dictations myPreviousDictations = await apiServices3.getMyPreviousDictations(episodeId, appointmentId);
    myPrevDtion = myPreviousDictations.audioDictations;
  }


  AllImages(int dictaionId) async{
    GetAllDictationImages getAllDictationImages=GetAllDictationImages();
    GetAllImages  getAllImages=await getAllDictationImages.getImages(dictaionId);
    String data=getAllImages.attachmentNamesList;
    images=data.split(",");
  }

  var dId, data, imageName,images;
  bool cameraImageVisible = false;
  bool galleryImagevisible = false;
  bool buttonVisible = false;
  bool isSwitched = false;
  File newImage, image;
  String fileName, filepath, memberId,memberRoleId;
  Map<String, String> paths;
  List<String> extensions;
  bool isLoadingPath = false;
  bool isMultiPick = false;
  FileType fileType;
  bool imageVisible = true;
  final DateTime now = DateTime.now();
  final DateFormat formatter = DateFormat(AppStrings.dateFormat);
  int Id,dictationIds,dictaId;
  List listId,dictId;
  bool galbuttonVisible=false;
  String roleId,episodeId,appointmentId;



  //..fetch memberId from sharedpreference
  _loadData() async {
    SharedPreferences prefs= await SharedPreferences.getInstance();
    setState(() {
      memberId = (prefs.getString(Keys.memberId) ?? '');
      roleId = (prefs.getString(Keys.memberRoleId) ?? '');
      memberRoleId = (prefs.getString(Keys.memberRoleId) ?? '');
    });
  }



  ///Check internet connection
  Future<bool> checkNetwork() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    try {
      if (connectivityResult == ConnectivityResult.mobile) {
        return true;
      } else if (connectivityResult == ConnectivityResult.wifi) {
        return true;
      }
    } catch (e) {
      print(e.toString());
      AppToast().showToast(AppStrings.no_internet);
      return false;
    }
  }

  //....function to open camera
  Future openCamera() async {
    try{
      image = await ImagePicker.pickImage(
          source: ImageSource.camera, imageQuality: 100);
        String path = image.path;
        createFileName(path);
        setState(() {
          image;
          cameraImageVisible = true;
          galleryImagevisible = false;
          imageVisible = true;
          buttonVisible = true;
          galbuttonVisible = false;
        });
    }catch(e){
      print(e.toString());
    }
  }

  //....function to open gallery
  Future openGallery() async {
    setState(() => isLoadingPath = true);
    try {
      if (!isMultiPick) {
        filepath = null;
        paths = await FilePicker.getMultiFilePath(
            type: fileType != null ? fileType : FileType.image,

            allowedExtensions: extensions,allowCompression: true
        );
      } else {
        filepath = await FilePicker.getFilePath(
            type: fileType != null ? fileType : FileType.image,
            allowedExtensions: extensions,allowCompression: true,);
        paths = null;
      }
    } on PlatformException catch (e) {
      print(AppStrings.filePathNotFound + e.toString());
    }
    try {
      if (!mounted) return;
      setState(() {
        isLoadingPath = false;
        fileName = filepath != null
            ? filepath.split('/').last
            : paths != null
            ? paths.keys.toString()
            : '...';

        if (paths != null) {
          galleryImagevisible = true;
          cameraImageVisible = false;
          buttonVisible = false;
      galbuttonVisible=true;
        }
      });
    } on PlatformException catch (e) {
      print(AppStrings.filePathNotFound + e.toString());
    }
  }

  //.......save to server
  saveDictationsToServer(String image,String imageNames) async{
    final ScheduleList item = ModalRoute.of(this.context).settings.arguments;
    try {
      ///.........save data to server
       showLoadingDialog(this.context,AppStrings.uploading);
      PostDictationsImageService apiPostServices =
      PostDictationsImageService();
      PostDictationsModel saveDictations =
          await apiPostServices.postApiMethod(
        item.episodeId ?? '',
        item.episodeAppointmentRequestId ?? '',
        int.parse(memberId),
        int.parse(memberRoleId),
        item.patient.firstName ?? '',
        item.patient.lastName ?? '',
        image,
        imageNames,
        AppStrings.imageFormat,
        item.patient.dob ?? '',
        item.locationId ?? '',
        item.practiceId ?? '',
        item.providerId ?? '',
          );
      dId = saveDictations.dictationId;
      data = saveDictations?.header?.statusCode;//.printing status code
    } catch (e) {}

    Navigator.of(this.context, rootNavigator: true).pop();
    await MySharedPreferences.instance.setStringValue(Keys.dictationId, dId);
    AppToast().showToast(AppStrings.uploadedDataSuccessfully);//close
  }

  //.....saveDictation to localDb
  saveDictationToOffline(int id) async{
    final ScheduleList item = ModalRoute.of(this.context).settings.arguments;
    await DatabaseHelper.db.insertAudioRecords(PatientDictation(
      dictationId: '${dId}',
      patientFirstName: '${item.patient.firstName ?? ''}',
      patientLastName: '${item.patient.lastName ?? ''}',
      providerName: '${item.patient.providerName ?? ''}',
      providerId: item.providerId ?? '',
      patientDOB: '${item.patient.dob ?? ''}',
      episodeId: item.episodeId ?? '',
      appointmentId: item.episodeAppointmentRequestId ?? '',
      practiceName: '${item.practice ?? ''}',
      practiceId: item.practiceId ?? '',
      createdDate: '${DateTime.now()}',
      dos: item.lynxId??'',
      memberId: int.parse(memberId),
      uploadedToServer: 1,
      locationId: item.locationId??'',
      dictationTypeId: '${(item.dictationTypeId??'')}',
    ));
  }

  //.....saveImages to localDb
  saveImagesToOffline(int id,String filename,String physicalFileName,String attachmntName) async{
    await DatabaseHelper.db.insertPhotoList(PhotoList(
        dictationLocalId: id,
        attachmentname:attachmntName,
        fileName: filename,
        physicalfilename: physicalFileName,
        attachmenttype: AppStrings.imageFormat,
        createddate: '${DateTime.now()}',));
  }

  //...get dictationId using episodeId and appointmentId
  getDictationId(int episodeId,int appointMentId) async{
  listId = await DatabaseHelper.db.getId(episodeId,appointMentId);
  }

  //...get dictationId
  getDictId() async{
    dictId =  await DatabaseHelper.db.getDectionId();
    dictationIds= dictId[dictId.length - 1].id;
  }
//............save cameraImages to server
  _saveCameraImagesToServer() async {
    if (image == null) {
      return;
    }
    final String formatted = formatter.format(now);
    List<int> fileBytes = await File(image.path).readAsBytes();
    String byteImage = base64Encode(fileBytes);
    final ScheduleList item = ModalRoute.of(this.context).settings.arguments;
    checkNetwork().then((internet) async {
      ///..........Internet Present Case
      if (internet != null && internet) {
        try {
          ///.........save data to server
          await saveDictationsToServer(
         byteImage,
            '${item.patient.firstName ?? ''}_ ${formatted}_${basename('${image.path}')}',);
        } catch (e) {}
        setState(() {
          buttonVisible = false;
          cameraImageVisible = false;
          galbuttonVisible=false;
        });
        ///..........save data to local using Id
          await getDictationId( item.episodeId ?? '',
          item.episodeAppointmentRequestId ?? '',);
          if (listId.isNotEmpty) {
          //.....update dictionId
          await DatabaseHelper.db.update(listId[0].id, dId);
          ///..........insert images using dictionId
          await saveImagesToOffline(listId[0].id, '${item.patient.displayName ?? ''}_ ${formatted}',
              image.path,
              '${item.patient.firstName ?? ''}_ ${formatted}_${basename('${image.path}')}');

        } else {
          ///........save new diction if user is not present
          await saveDictationToOffline(dId);
          //.......return of dictionId
          await getDictId();
          ///..........insert images using dictionId
          await saveImagesToOffline(dictationIds,
             '${item.patient.firstName ?? ''}_ ${formatted}',
             image.path,
             '${item.patient.firstName ?? ''}_ ${formatted}_${basename('${image.path}')}');
        }
      }
      ///.....offline data saving to local
      else {
         await getDictationId( item.episodeId ?? '',
          item.episodeAppointmentRequestId ?? '',);
        if (listId.isNotEmpty) {
          //...save images to offline
         await saveImagesToOffline(listId[0].id,
              '${item.patient.firstName ?? ''}_ ${formatted}', image.path,
              '${item.patient.firstName ?? ''}_ ${formatted}_${basename('${image.path}')}');
        } else {
          //...save dictation to offline
         await saveDictationToOffline(dId);
         //return dictationId
         await getDictId();
          //...save images to offline
         await saveImagesToOffline(dictationIds, '${item.patient.displayName ?? ''}_ ${formatted}',
              image.path,
              '${item.patient.firstName ?? ''}_ ${formatted}_${basename('${image.path}')}');
        }
        setState(() {
          buttonVisible = false;
          cameraImageVisible = false;
           galbuttonVisible=false;
        });
      }
    });
  }

  //...save galleryImages to server
  saveGalleryImageToServer() async {
    if (paths == null || paths.values == null) {
      return;
    }
    final ScheduleList item = ModalRoute.of(this.context).settings.arguments;
    final String formatted = formatter.format(now);
    for (int i = 0; i < paths.keys.toList().length; i++) {
      await saveGalleryImageToFolder(
          '${item.patient.firstName ?? ''}', '${formatted}');

      //........convert image byte format
      final bytes = File('${paths.values.toList()[i]}').readAsBytesSync();
      String images = base64Encode(bytes);

      checkNetwork().then((internet) async {
        ///....Internet Present Case
        if (internet != null && internet) {
          try {///... save data to server
          await saveDictationsToServer(images,
              '${item.patient.firstName ?? ''}_ ${formatted}_${basename(paths.keys.toList()[i])}',
            );
          } catch (e) {}
          setState(() {
            buttonVisible = false;
            galleryImagevisible = false;
            galbuttonVisible=false;
          });
          ///....save data to local using Id
         await getDictationId(item.episodeId ?? '',
            item.episodeAppointmentRequestId ?? '',);
          if (listId.isNotEmpty) {
            //.....update dictionId
            await DatabaseHelper.db.update(listId[0].id, dId);
            ///..........insert images using dictionId
          await saveImagesToOffline(listId[0].id,
             '${item.patient.firstName ?? ''}_ ${formatted}',
             '${paths.values.toList()[i]}',
             '${item.patient.firstName ?? ''}_ ${formatted}_${basename(paths.keys.toList()[i])}',);
          }
          else {
            ///...save new diction if user is not present
          await saveDictationToOffline(dId);
            //.......return of dictionId
          await getDictId();
          ///..........insert images using dictionId
          await saveImagesToOffline(dictationIds,
              '${item.patient.firstName ?? ''}_ ${formatted}',
              '${paths.values.toList()[i]}',
              '${item.patient.firstName ?? ''}_ ${formatted}_${basename(paths.keys.toList()[i])}',);
          }
        }
        //....offline saving of data to local
        else {
          await getDictationId(item.episodeId ?? '',
            item.episodeAppointmentRequestId ?? '',);
          if (listId.isNotEmpty) {
            ///..........insert images using dictionId
           await saveImagesToOffline(listId[0].id,
              '${item.patient.firstName ?? ''}_ ${formatted}',
              '${paths.values.toList()[i]}',
              '${item.patient.firstName ?? ''}_ ${formatted}_${basename(paths.keys.toList()[i])}',);
          }
          else {
            ///...save new diction if user is not present
           await saveDictationToOffline(dId);
            //.......return of dictionId
           await getDictId();
           ///..........insert images using dictionId
           await saveImagesToOffline(dictationIds,
              '${item.patient.firstName ?? ''}_ ${formatted}',
              '${paths.values.toList()[i]}',
              '${item.patient.firstName ?? ''}_ ${formatted}_${basename(paths.keys.toList()[i])}',);
          }
          setState(() {
            buttonVisible = false;
            galleryImagevisible = false;
            galbuttonVisible=false;
          });
        }
      });
    }
  }

  //...saving gallery image to app folder
  saveGalleryImageToFolder(String patientName, String dateFormat) async {
    for (int i = 0; i < paths.keys.toList().length; i++) {
      var galleryImage = paths.values.toList();
      final Directory directory = await getExternalStorageDirectory();
      String path = '${directory.path}/${AppStrings.folderName}';
      final myImgDir = await Directory(path).create(recursive: true);
      newImage = await File((galleryImage[i])).copy(
        '${myImgDir.path}/${patientName + dateFormat + basename((galleryImage[i]))}',
      );
    }
  }

  //custom file name
  Future<String> createFileName(String mockName) async {
    final ScheduleList item = ModalRoute.of(this.context).settings.arguments;
    final String formatted = formatter.format(now);
    try {
      imageName = item.patient.firstName??'' + basename(mockName).replaceAll(".", "");
      if (imageName.length > 10) {
        imageName = imageName.substring(0, 10);

        final Directory directory = await getExternalStorageDirectory();
        String path = '${directory.path}/${AppStrings.folderName}';
        final myImgDir = await Directory(path).create(recursive: true);
        newImage = await File(image.path).copy(
            '${myImgDir.path}/${basename(imageName + '${formatted}' + AppStrings.imageFormat)}');
        setState(() {
          newImage;
        });
      }
    } catch (e, s) {
      imageName = "";
      AppLogHelper.printLogs(e, s);
    }
    return "${formatted}" + imageName + AppStrings.imageFormat;
  }

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text("", style:
        TextStyle(color: CustomizedColors.textColor, fontSize: 14.0,fontFamily: AppFonts.regular)),
        backgroundColor: CustomizedColors.primaryColor,
        elevation: 0.2,
      ),
      body: ListView(
        children:[ Container(
            width: double.infinity,
            decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, colors: [
                  CustomizedColors.primaryColor,
                  CustomizedColors.primaryColor,
                  CustomizedColors.primaryColor,
                ])),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(30, 10, 10, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(width: width * 0.05,),
                            //...hero widget to show elevation
                            heroWidget(context),
                            SizedBox(width: width * 0.07,),
                            //...patient details
                            patientDetails(context)
                          ],
                        ),
                        SizedBox(height: height * 0.03,),
                        patientDetailedDetails(context),
                        SizedBox(height: height * 0.02,),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(60),
                            topRight: Radius.circular(60))),
                      child: Column(
                        children: <Widget>[
                          SizedBox(height: 20),
                          audioAndcameraButtons(context),
                          //.....view camera image
                          viewCameraImage(context),
                          //...view gallery images
                          viewGalleryImages(context),
                          SizedBox(height: 12,),
                          //...buttons
                          audioDictationAndImagesButton(context)
                        ],
                      ),
                    ),
                 // ),
                ])),
     ] ),
    );
  }

  //...cupertinoactionsheet
  Widget cupertinoActionSheet(BuildContext context) {
    final action = CupertinoActionSheet(
      actions: [
        CupertinoActionSheetAction(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(AppStrings.camera,style: TextStyle(fontFamily: AppFonts.regular,),),
            ],
          ),
          onPressed: () {
            openCamera();
            Navigator.of(context, rootNavigator: true).pop();
          },
        ),
        CupertinoActionSheetAction(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(AppStrings.PhotoGallery,style: TextStyle(fontFamily: AppFonts.regular,),),
            ],
          ),
          onPressed: () {
            openGallery();
            Navigator.of(context, rootNavigator: true).pop();
          },
        )
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text(AppStrings.cancel,style: TextStyle(fontFamily: AppFonts.regular,),),
        isDestructiveAction: true,
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop();
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }

  //..........view camera image
  Widget viewCameraImage(BuildContext context) {
    return Visibility(
      visible: cameraImageVisible,
      child: Container(
        margin: const EdgeInsets.all(5),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Wrap(children: [
            Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: CustomizedColors.homeSubtitleColor,
                  ),
                ),
                height: 100,
                margin: const EdgeInsets.all(10),
                child: Container(
                    margin: const EdgeInsets.all(5),
                    child: Stack(children: [
                      image == null
                          ? Text(AppStrings.noImageSelected,style: TextStyle(fontFamily: AppFonts.regular,),)
                          : Image.file(image, fit: BoxFit.contain),
                      Positioned(
                        right: -15,
                        top: -15,
                        child: Visibility(
                          visible: imageVisible,
                          child: IconButton(
                            icon: Icon(
                              Icons.close,
                              color: CustomizedColors.buttonTitleColor,
                            ),
                            onPressed: () {
                              setState(() {
                                image = null;
                                imageVisible = false;
                                cameraImageVisible = false;
                                buttonVisible = false;
                              });
                            },
                          ),
                        ),
                      ),
                    ]))),
          ]),
        ]),
      ),
    );
  }

  //..GalleryImages
  Widget viewGalleryImages(BuildContext context) {
    return Visibility(
        visible: galleryImagevisible,
        child: Column(children: [
          filepath != null ||
              (paths != null &&
                  paths.values != null &&
                  paths.values.isNotEmpty)
              ? Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: CustomizedColors.homeSubtitleColor,
              ),
            ),
            height: 100,
            margin: const EdgeInsets.all(10),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount:
              paths != null && paths.isNotEmpty ? paths.length : 1,
              itemBuilder: (BuildContext context, int index) {
                final bool isMultiPath =
                    paths != null && paths.isNotEmpty;
                final filePath1 = isMultiPath
                    ? paths.values.toList()[index].toString()
                    : filepath;
                return Container(
                  color: CustomizedColors.homeSubtitleColor,
                  margin: const EdgeInsets.all(10),
                  child: Stack(children: [
                    filePath1 != null
                        ? Image.file(
                      File(filePath1),
                      fit: BoxFit.contain,
                    )
                        : Container(),

                Positioned(
                      right: -15,
                      top: -15,
                      child: IconButton(
                        icon: Icon(
                          Icons.close,
                          color: CustomizedColors.buttonTitleColor,
                        ),
                        onPressed: () {
                          setState(() {
                            imageName = basename(paths.values.toList()[index]);
                            paths.remove(imageName);
                            if (paths.values.toList().isEmpty) {
                              buttonVisible = false;
                              galbuttonVisible=false;
                            }
                          });
                        },
                      ),
                    ),
                  ]),

                );

              },
              separatorBuilder: (BuildContext context, int index) =>
                  Divider(),
            ),
          )
              : Container(
            child: Text(AppStrings.noImageSelected,style: TextStyle(fontFamily: AppFonts.regular,),),
          ),
        ]));
  }

  //............patientDetails
  Widget patientDetails(BuildContext context) {
    final ScheduleList item = ModalRoute.of(context).settings.arguments;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
         item.patient?.displayName ?? "",

          style: TextStyle(color: Colors.white, fontSize: 14,fontFamily: AppFonts.regular,),
        ),
        Row(
          children: [
            Text(
              item.patient?.sex ?? "",
              style: TextStyle(color: Colors.white, fontSize: 14,fontFamily: AppFonts.regular),
            ),
            Text("," + " ", style: TextStyle(color: Colors.white,fontFamily: AppFonts.regular,)),
            Text(
              item.patient?.age.toString() + " " + AppStrings.yearOld ?? "",
              style: TextStyle(color: Colors.white, fontSize: 14,fontFamily: AppFonts.regular),
            ),
          ],
        ),
        Text(
          item.accidentDate ?? "",
          style: TextStyle(color: Colors.white, fontSize: 14,fontFamily: AppFonts.regular),
        ),
      ],
    );
  }

//....patientDetailedDetails
  Widget patientDetailedDetails(BuildContext context) {
    final ScheduleList item = ModalRoute.of(context).settings.arguments;
    String dos=item.appointmentStartDate??'';
    var date=dos.split("T");
    return Row(
      children: [
        Padding(padding: EdgeInsets.only(right: 10)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.dateOfbirth + " " + ":" + " " + item.patient?.dob ??
                  "",
              style: TextStyle(color: Colors.white, fontSize: 14,fontFamily: AppFonts.regular),
            ),
            Text(
              AppStrings.caseNo + " " + ":" + " " + item?.lynxId ?? "",
              style: TextStyle(color: Colors.white, fontSize: 14,fontFamily: AppFonts.regular),
            ),
            Text(
              AppStrings.dos + " " + ":" + " " + date[0],
              style: TextStyle(color: Colors.white, fontSize: 14,fontFamily: AppFonts.regular),
            ),
          ],
        ),
      ],
    );
  }

  //....dictation and view image buttons
  Widget audioDictationAndImagesButton(BuildContext context) {
    final ScheduleList item = ModalRoute.of(context).settings.arguments;
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      ///...save images button
      Visibility(
        visible: buttonVisible,
        child: RaisedBtn(
            text: AppStrings.submitImages,
            onPressed:
                 () async {
                await _saveCameraImagesToServer();
            },
            iconData: Icons.image),
      ),
      Visibility(
        visible: galbuttonVisible,
        child: RaisedBtn(
            text: AppStrings.submitImages,
            onPressed: () async {
              await saveGalleryImageToServer();
            },
            iconData: Icons.image),
      ),
      SizedBox(height: 15),
      //......all dictation button
      RaisedBtn(
          text: AppStrings.allDictations,
          onPressed: () async {
            checkNetwork().then((internet) async {
            if (internet != null && internet){
            showLoadingDialog(context,AppStrings.loading);
            await AllDtion(item.episodeAppointmentRequestId);
            await AllPrevDtion(item.episodeId, item.episodeAppointmentRequestId);
            await MyPrevDtion(item.episodeId, item.episodeAppointmentRequestId);
            Navigator.of(this.context, rootNavigator: true)
                .pop();
            if(allDtion.length == 0 && allPrevDtion.length == 0 && myPrevDtion.length == 0){
              AppToast().showToast(AppStrings.noDictations);
            }else{
              RouteGenerator.navigatorKey.currentState
                  .pushNamed(DictationType.routeName,
                  arguments:  {
                    'allDictation': allDtion,
                    'allPreDictation': allPrevDtion,
                    'myPreDictation': myPrevDtion,
                    'item': item
                  });
            } }else{
              AppToast().showToast(AppStrings.no_internet);
            }
              });
          },
          iconData: Icons.mic_rounded),
      SizedBox(height: 15),

      ///....all images button
      RaisedBtn(
          text: AppStrings.images,
          onPressed: () async {
            checkNetwork().then((internet) async {
              try {
                if (internet != null && internet) {
                  if (((item.dictationId??'') == 0)){
                    AppToast().showToast(AppStrings.noImageSelected);
                  }
                  else {
                    showLoadingDialog(context, AppStrings.loading);
                    await AllImages((item.dictationId ?? ''));
                    Navigator.of(this.context, rootNavigator: true).pop();
                    if (images.length== 0) {
                      AppToast().showToast(AppStrings.noImageSelected);
                    }
                    else {
                      RouteGenerator.navigatorKey.currentState
                          .pushNamed(ViewImages.routeName,
                          arguments: images);
                    }
                  }
                }
                else {
                  AppToast().showToast(AppStrings.no_internet);
                }
              }catch(e){
                print(e.toString());
              }
            });

          },
          iconData: Icons.camera_alt),
    ]);
  }
  //....auido and camera button
  Widget audioAndcameraButtons(BuildContext context) {
    final ScheduleList item = ModalRoute.of(context).settings.arguments;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        //Button for mic
       int.tryParse(roleId)!=1 ?  AudioMicButtons(
            patientFName: item.patient.firstName,
            patientLName: item.patient.lastName,
            caseId: item.patient.accountNumber,
            patientDob: item.patient.dob,
            practiceId: item.practiceId,
            statusId: item.dictationStatusId,
            episodeId: item.episodeId,
            episodeAppointmentRequestId: item.episodeAppointmentRequestId,
            appointmentType: item.appointmentType):Container(
              height:5,
              width:5
            ),

        //Button for camera
        int.tryParse(roleId) !=1 ?  MaterialButtons(
            onPressed: () {
              // CupertinoActionSheet for camera and gallery
              cupertinoActionSheet(context);
            },
            iconData: Icons.camera_alt):Container(
              height:5,
              width:5
            )
      ],
    );
  }

  //....hero widget
  Widget heroWidget(BuildContext context) {
    final ScheduleList item = ModalRoute.of(context).settings.arguments;
    return Hero(
      transitionOnUserGestures: true,
      tag: item,
      child: Transform.scale(
        scale: 2.0,
        child: CircleAvatar(
          radius: 15,
          child: ClipOval(
            child: item.patient.profilePhotoName == ""
                ? Image.asset(
              AppStrings.defaultimage,
              fit: BoxFit.cover,
            )
                : Image.network(item.patient.profilePhotoName ?? ''),
          ),
        ),
      ),
    );
  }

  //.......progressing bar
  Future<void> showLoadingDialog(BuildContext context,String msg) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
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
                              fontSize: 18,fontFamily: AppFonts.regular,
                              fontWeight: FontWeight.w600),
                        )
                      ]),
                    )
                  ]));
        });

  }
}