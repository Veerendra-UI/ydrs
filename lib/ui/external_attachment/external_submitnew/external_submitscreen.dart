import 'dart:convert';
import 'dart:io';
import 'package:YOURDRS_FlutterAPP/common/app_colors.dart';
import 'package:YOURDRS_FlutterAPP/common/app_log_helper.dart';
import 'package:YOURDRS_FlutterAPP/common/app_strings.dart';
import 'package:YOURDRS_FlutterAPP/common/app_toast_message.dart';
import 'package:YOURDRS_FlutterAPP/network/models/external_dictations/external_databse_model.dart';
import 'package:YOURDRS_FlutterAPP/network/models/manual_dictations/photo_list.dart';
import 'package:YOURDRS_FlutterAPP/network/models/manual_dictations/practice.dart';
import 'package:YOURDRS_FlutterAPP/network/models/manual_dictations/document_type.dart';
import 'package:YOURDRS_FlutterAPP/network/models/manual_dictations/location_field_model.dart';
import 'package:YOURDRS_FlutterAPP/network/models/manual_dictations/provider_model.dart';
import 'package:YOURDRS_FlutterAPP/helper/db_helper.dart';
import 'package:YOURDRS_FlutterAPP/network/repo/local/preference/local_storage.dart';
import 'package:YOURDRS_FlutterAPP/network/services/dictation/extrenalattachmnent_postapi.dart';
import 'package:YOURDRS_FlutterAPP/ui/external_attachment/externalattchment_main.dart';
import 'package:YOURDRS_FlutterAPP/ui/manual_dictaions/date_Valid.dart';
import 'package:YOURDRS_FlutterAPP/utils/route_generator.dart';
import 'package:YOURDRS_FlutterAPP/widget/buttons/raised_buttons.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:YOURDRS_FlutterAPP/widget/dropdowns/documenttype.dart';
import 'package:YOURDRS_FlutterAPP/widget/dropdowns/location_field.dart';
import 'package:YOURDRS_FlutterAPP/widget/dropdowns/practice_field.dart';
import 'package:YOURDRS_FlutterAPP/widget/dropdowns/provider_field.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:YOURDRS_FlutterAPP/network/models/manual_dictations/external_dictation_attacment_model.dart';

import '../../../common/app_text.dart';

///------------------------------This is the SubmitNew class and this class contains all the fields for ExternalAttachment screen
class SubmitNew extends StatefulWidget {
  // static const String routeName = '/SubmitNew';
  @override
  _SubmitNewState createState() => _SubmitNewState();
}
class _SubmitNewState extends State<SubmitNew> {
  bool widgetVisible = false;
  bool visible = false;
  Directory directory;
  bool isSwitched = false;
  File newImage, image;
  String fileName;
  String filepath;
  Map<String, String> paths;
  List<String> extensions;
  bool isLoadingPath = false;
  bool isMultiPick = false;
  FileType fileType;
  bool imageVisible = true;
  var imageName;
  int imageIndex = 0;
  List imageArray = new List();
  final DateTime now = DateTime.now();
  final DateFormat formatter = DateFormat(AppStrings.dateFormatr);
  String selectedProvidername;
  String selectedDate;
  String practiceId;
  String selectedPractice2;
  String selectedLocation;
  String selecteddocumnettype;
  String LocationId;
  String providerId1;
  int documenttypeId;
  int toggleVal;
  var memberId;
  var statusCode, attachmentContent;
  var path;
  bool submitVisible = true;
  bool submitGVisible = false;
  bool isInternetAvailable = true;
  final _formKey = GlobalKey<FormState>();
  TextEditingController firstname = TextEditingController();
  TextEditingController lastname = TextEditingController();
  TextEditingController Description = TextEditingController();
  final _dateOfbirthController = TextEditingController();
  String content, name;
  var extId;
  int uploadedToServerTrue = 1,uploadedToServerFalse = 0;
  AppToast appToast=AppToast();
List photoListOfGallery = [];
  bool emergencyAddOn = true;
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
//-------------------------------checking internet condition
   check() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      setState(() {
        isInternetAvailable = true;
      });
    } else {
      setState(() {
        isInternetAvailable = false;
      });
      appToast.showToast(AppStrings.no_internet);
    }
  }
  //--------------------Show process indicator
  Future<void> showLoadingDialog(BuildContext context, GlobalKey key) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return new WillPopScope(
          onWillPop: () async => false,
          child: SimpleDialog(
            key: key,
            backgroundColor: Colors.white,
            children: <Widget>[
              Center(
                child: Row(
                  children: [
                    SizedBox(
                      width: 25,
                    ),
                    CircularProgressIndicator(
                      valueColor:
                      AlwaysStoppedAnimation(CustomizedColors.primaryColor),
                    ),
                    SizedBox(
                      width: 35,
                    ),
                    Text(
                      AppStrings.showuploader,
                      style: TextStyle( fontFamily: AppFonts.regular,
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    _loadData();
    DeleteFiles();
    super.initState();
  }
  void DeleteFiles() async {
    await DatabaseHelper.db.deleteAllExternalRecords();
  }
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child:Form(
            key: _formKey,
            child: Container(
              child: Column(
                children: [
//----------------------------------Practice Field

                  Container(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        AppStrings.practice,
                        style: TextStyle( fontFamily: AppFonts.regular,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: CustomizedColors.practice_textColor,
                        ),
                      ),
                    ),
                    width: MediaQuery.of(context).size.width * 0.95,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: PracticeDropDown(
                      onTapOfPractice: (PracticeList value) {
                        setState(() {
                          practiceId = '${value.id}';
                          selectedPractice2 = '${value.name}';
                        });
                      },
                    ),
                  ),

//---------------------------------------------Location Field

                  Container(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        AppStrings.locations,
                        style: TextStyle(
                          fontSize: 14, fontFamily: AppFonts.regular,
                          fontWeight: FontWeight.bold,
                          color: CustomizedColors.practice_textColor,
                        ),
                      ),
                    ),
                    width: MediaQuery.of(context).size.width * 0.95,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: Locations(
                      onTapOfLocation: (LocationList value) {
                        setState(() {
                          LocationId = '${value.id}';
                          selectedLocation = '${value?.name}';
                        });
                      },
                      PracticeIdList: practiceId,
                    ),
                  ),

//---------------------------------------Provider Field

                  Container(
                    child: Padding(
                      padding: const EdgeInsets.only(top:10),
                      child: Text(
                        AppStrings.provider,
                        style: TextStyle( fontFamily: AppFonts.regular,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: CustomizedColors.practice_textColor,
                        ),
                      ),
                    ),
                    width: MediaQuery.of(context).size.width * 0.95,
                  ),
                  Padding(
                      padding: EdgeInsets.only(top: 10),
                    child:   Container(
                      width: MediaQuery.of(context).size.width * 0.95,
                      child: ExternalProviderDropDown(
                        onTapOfProvider: (ProviderList value) {
                          setState(() {
                            providerId1 = '${value.providerId}';
                            selectedProvidername = '${value?.displayname}';
                          });

                        },
                        PracticeLocationId: LocationId,
                      ),
                    ),
                  ),

//------------------------------------------First Name Field

                  Container(
                    child: Column(
                      children: [
                        Container(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Text(
                              AppStrings.firstname,
                              style: TextStyle( fontFamily: AppFonts.regular,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: CustomizedColors.practice_textColor,
                              ),
                            ),
                          ),
                          width: MediaQuery.of(context).size.width * 0.95,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10, right: 8),
                          child: Container(
                            height: 55,
                            width: MediaQuery.of(context).size.width * 0.95,
                            //color: Colors.yellow,
                            child: TextFormField(
                              inputFormatters: [
                                WhitelistingTextInputFormatter(RegExp("[a-zA-Z]"))
                              ],
                              controller: firstname,
                              validator:validateInput,
                              obscureText: false,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(20),
                                hintText: AppStrings.hint_fisrtname,
                                //errorText: validationService.firstName.error,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0)),
                              ),
                              // onChanged: (String value) {
                              //   validationService.changeFirstName(value);
                              // },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

//-----------------------------------------Last Name Field

                  Container(
                    child: Column(
                      children: [
                        Container(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Text(
                              AppStrings.lastname,
                              style: TextStyle( fontFamily: AppFonts.regular,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: CustomizedColors.practice_textColor,
                              ),
                            ),
                          ),
                          width: MediaQuery.of(context).size.width * 0.95,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10, right: 8),
                          child: Container(
                            height: 55,
                            width: MediaQuery.of(context).size.width * 0.95,
                            //color: Colors.yellow,
                            child: TextFormField(
                              inputFormatters: [
                                WhitelistingTextInputFormatter(RegExp("[a-zA-Z]"))
                              ],
                              controller: lastname,
                              validator:validateInput,
                              obscureText: false,
                              decoration: InputDecoration(
                                //  errorText: validationService.lastName.error,
                                contentPadding: EdgeInsets.all(20),
                                hintText: AppStrings.hint_lastname,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

//------------------------------------------Date of birth Field
                  Container(
                    child: Column(
                      children: [
                        Container(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Text(
                              AppStrings.dateofbirth,
                              style: TextStyle( fontFamily: AppFonts.regular,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: CustomizedColors.practice_textColor,
                              ),
                            ),
                          ),
                          width: MediaQuery.of(context).size.width * 0.95,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10, right: 8),
                          child:
                          Container(
                            height: 60,
                            width: MediaQuery.of(context).size.width * 0.95,
                            child: TextFormField(
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp("[0-9\\-]")),
                                LengthLimitingTextInputFormatter(10),
                                DateValidFormatter(),
                              ],
                              validator:validateInput,
                              controller: _dateOfbirthController,
                              minLines: 2,
                              maxLines: 10,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: AppStrings.dateFormatLableHintText,
                                labelText: AppStrings.dateFormatLableHintText,
                                suffixIcon: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child:   IconButton(
                                    icon: Icon(Icons.calendar_today_sharp,color: CustomizedColors.primaryColor),
                                    onPressed: () async {
                                      DateTime d = DateTime(1900);
                                      // FocusScope.of(context).requestFocus(FocusNode());

                                      d = await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime(1900),
                                          lastDate: DateTime.now());
                                      final DateFormat formats = DateFormat(
                                          AppStrings.dateFormatForDatePicker);;
                                      selectedDate = formats.format(d);
                                      _dateOfbirthController.text = selectedDate.toString();
                                    },
                                  ),
                                ),
                                contentPadding: EdgeInsets.all(20),
                                // hintText: AppStrings.descp,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

//----------------------------Document type Field

                  Container(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        AppStrings.documenttype,
                        style: TextStyle( fontFamily: AppFonts.regular,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: CustomizedColors.practice_textColor,
                        ),
                      ),
                    ),
                    width: MediaQuery.of(context).size.width * 0.95,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: DocumentDropDown(
                      onTapDocument: (ExternalDocumentTypesList value) {
                        selecteddocumnettype = value.externalDocumentTypeName;
                        documenttypeId = value.id;
                      },
                    ),
                  ),
//----------------------------------emergency Field

                  Container(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        AppStrings.emergency_descrption,
                        style: TextStyle(
                          fontSize: 14, fontFamily: AppFonts.regular,
                          fontWeight: FontWeight.bold,
                          color: CustomizedColors.practice_textColor,
                        ),
                      ),
                    ),
                    width: MediaQuery.of(context).size.width * 0.95,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Center(
                      child: ToggleSwitch(
                        minWidth: 160.0,
                        minHeight: 55,
                        cornerRadius: 10.0,
                        activeBgColor: CustomizedColors.accentColor,
                        activeFgColor: CustomizedColors.whitetoggleTextColor,
                        inactiveBgColor: Colors.grey[300],
                        inactiveFgColor: Colors.grey[700],
                        labels: ['YES', 'NO'],
                        icons: [Icons.check_circle, Icons.cancel_rounded],
                        onToggle: (toggleIndex) {
                          if (toggleIndex == 0) {
                            toggleVal = 1;
                          } else if (toggleIndex == 1) {
                            toggleVal = 0;
                          } else {
                            return null;
                          }
                          print(toggleVal);
                        },
                      ),
                    ),
                  ),

//-----------------------------------Description Field

                  Container(
                    child: Column(
                      children: [
                        Container(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Text(
                              AppStrings.description,
                              style: TextStyle(
                                fontSize: 14, fontFamily: AppFonts.regular,
                                fontWeight: FontWeight.bold,
                                color: CustomizedColors.practice_textColor,
                              ),
                            ),
                          ),
                          width: MediaQuery.of(context).size.width * 0.95,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Container(
                            // height:200,
                            width: MediaQuery.of(context).size.width * 0.95,
                            //color: Colors.yellow,
                            child: TextFormField(
                              controller: Description,
                              validator:validateInput,
                              keyboardType: TextInputType.multiline,
                              minLines: 2,
                              maxLines: 10,
                              obscureText: false,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

//-----------------------------------------add image/take image
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: CupertinoPageScaffold(
                      child: Center(
                        child: Container(
                          height: 60,
                          width: MediaQuery.of(context).size.width * 0.95,
                          child: RaisedButton(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt,
                                    color: CustomizedColors.addressTextColor,
                                    size: 45,
                                  ),
                                  Text(
                                    'Add Image/Take Picture',
                                    style: TextStyle( fontFamily: AppFonts.regular,fontSize: 14,
                                        color:
                                        CustomizedColors.addimage_textColor),
                                  ),
                                ],
                              ),
                            ),
                            onPressed: () => _show(context),
                          ),
                        ),
                      ),
                    ),
                  ),
 //---------------------------display the camera images to the ui

                  Visibility(
                    visible: widgetVisible,
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Wrap(children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: CustomizedColors.homeSubtitleColor,
                                ),
                              ),
                              height: 100,
                              width: MediaQuery.of(context).size.width * 0.85,
                              child: Center(
                                  child: Stack(children: [
                                    image == null
                                        ? Text(AppStrings.noImageselected_text,style: TextStyle(fontFamily: AppFonts.regular,fontSize: 14),)
                                        : Image.file(
                                      image,
                                      fit: BoxFit.contain,
                                    ),
                                    Positioned(
                                      right: -10,
                                      top: -5,
                                      child: Visibility(
                                        visible: imageVisible,
                                        child: IconButton(
                                          icon: new Icon(
                                            Icons.close,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              image = null;
                                              imageVisible = false;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ])),
                            ),

                          ]),
                        ],
                      ),
                    ),
                  ),

//---------------------------display the gallery for selecting the images

                  Visibility(
                    visible: visible,
                    child: Column(
                      children: [
                        Builder(
                          builder: (BuildContext context) => isLoadingPath
                              ? Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: const CircularProgressIndicator())
                              : filepath != null ||
                              (paths != null &&
                                  paths.values != null &&
                                  paths.values.isNotEmpty)
                              ? new Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color:
                                CustomizedColors.homeSubtitleColor,
                              ),
                            ),
                            height: 100,
                            width: MediaQuery.of(context).size.width *
                                0.85,
                            child: new ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount:
                              paths != null && paths.isNotEmpty
                                  ? paths.length
                                  : 1,
                              itemBuilder:
                                  (BuildContext context, index) {
                                final bool isMultiPath =
                                    paths != null && paths.isNotEmpty;
                                final filePath1 = isMultiPath
                                    ? paths.values
                                    .toList()[index]
                                    .toString()
                                    : filepath;
                                print(filePath1);
                                return Container(
                                  color: CustomizedColors
                                      .homeSubtitleColor,
                                  margin: const EdgeInsets.all(8),
                                  child: Stack(children: [
                                    filePath1 != null
                                        ? Image.file(
                                      File(filePath1),
                                      fit: BoxFit.contain,
                                    )
                                        : Container(),
                                    Positioned(
                                      right: -10,
                                      top: -5,
                                      child: IconButton(
                                        icon: new Icon(
                                          Icons.close,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            var filename = basename(
                                                paths.values
                                                    .toList()[index]);
                                            paths.remove(filename);
                                          });
                                        },
                                      ),
                                    ),
                                  ]),
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) =>
                                  Divider(),
                            ),
                          )
                              : Container(),
                        ),
                      ],
                    ),
                  ),

//-------------------------------------Cancel and Submit Buttons

                  Padding(
                    padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                    child: Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            height: 60,
                            width: 150,
                            child: Card(
                              //color: Colors.blue,
                              child: RaisedBttn(
                                onPressed: () {
                                  RouteGenerator.navigatorKey.currentState
                                      .pushNamedAndRemoveUntil(ExternalAttachments.routeName,
                                        (Route<dynamic> route) => false,);

                                },
                                text: AppStrings.cancel,
                                button_color: CustomizedColors
                                    .cancelbuttonColor, //------we have take variable name clr to represents the color
                              ),
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              //color: Colors.yellow
                            ),
                          ),

 //------------------------------to show the gallery photos
                          SizedBox(width: 10),
                          Container(
                            height: 60,
                            width: 150,
                            child: Card(
                              // color: Colors.blue,
                                child: RaisedBttn(
                                  onPressed: () async {
                                    try {
                                      await check();
                                      if (isInternetAvailable == true) {
                                        if (_formKey.currentState.validate()) {
                                          showLoadingDialog(context, _keyLoader);
//---------------------------------------------save gallary images to sever with internet
                                          await _saveGalleryImagesTosever();
//---------------------------------------------save camera images with internet
                                          await _saveCameraImagesToServer();

//------------------------------------------------post api data
                                          await  _saveExternalAttachmentDictation();

                                          await appToast.showToast(AppStrings.showtoast_text);

                                         //clear the all the fields after submitting the data
                                          await RouteGenerator.navigatorKey.currentState
                                              .pushReplacementNamed(
                                              ExternalAttachments.routeName);

                                        }
                                      } else {
                                        if (_formKey.currentState.validate()) {
                                          showLoadingDialog(context, _keyLoader);


 //-------------------------------------------save camera images without internet
                                          await _saveCameraImagesToOfflinedata();

 //-------------------------------------------save gallery images without internet
                                          await _saveGalleryImagesToDB();

                                          appToast.showToast(AppStrings.showtoastdb_text);

                                          //clear the all the fields after submitting the data
                                          await RouteGenerator.navigatorKey.currentState
                                              .pushReplacementNamed(
                                              ExternalAttachments.routeName);
                                        }
                                      }

                                    }on Exception catch (e) {
                                      print(e.toString());
                                    }
                                  },

                                  text: AppStrings.submit_buttontext,
                                  button_color: CustomizedColors.submitbuttonColor,
                                )
                            ),
                            //color: Colors.blue,
                          ),
                        ],
                      ),
                      height: 100,
                    ),
                  ),

                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /////////------------------here calling the various functions-------------/////////////////

  //----------validator function for various fields
  String validateInput(String value) {
    try {
      if (value.length == 0) {
        return 'This is required';
      } else {
        return null;
      }
    } on Exception catch (e) {
      print(e.toString());
    }
  }

  //---------------------------------custom file name

  Future<String> createFileName(String mockName) async {
    final String formatted = formatter.format(now);
    try {
      imageName = '' + basename(mockName).replaceAll(".", "");
      if (imageName.length > 10) {
        imageName = imageName.substring(0, 10);

        final Directory directory = await getExternalStorageDirectory();
        String path = '${directory.path}/${AppStrings.folderName}';
        final myImgDir = await Directory(path).create(recursive: true);
        newImage = await File(image?.path).copy(
            '${myImgDir.path}/${basename(imageName + '${formatted}' + AppStrings.imageFormat)}');
        setState(() {
          newImage;
          print(path);
        });
      }
    } catch (e, s) {
      imageName = "";
      AppLogHelper.printLogs(e, s);
    }

    return "${formatted}" + imageName + AppStrings.imageFormat;
  }
//-------------------save the gallery images to folder
  void saveGalleryImageToFolder(String patientName, String dateFormat) async {
    for (int i = 0; i < paths.keys.toList().length; i++) {
      var galleryImage = paths.values.toList();
      print(galleryImage);

      final Directory directory = await getExternalStorageDirectory();
      String path = '${directory.path}/${AppStrings.folderName}';
      final myImgDir = await Directory(path).create(recursive: true);
      newImage = await File((galleryImage[i])).copy(
        '${myImgDir.path}/${patientName + dateFormat + basename((galleryImage[i]))}',
      );
    }
  }
  //---------------------------------------function to open camera

  Future openCamera() async {
    image = await ImagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 100);
    if(image!=null){
      String path = image.path;
      createFileName(path);
      setState(() {
        image;
        widgetVisible = true;
        visible = true;
      });
    }
  }
  //--------------------------------------------------function to open gallery

  Future openGallery() async {
    setState(() => isLoadingPath = true);
    try {
      if (!isMultiPick) {
        filepath = null;
        paths = await FilePicker.getMultiFilePath(
            type: fileType != null ? fileType : FileType.image,
            allowedExtensions: extensions);
        print(paths.toString());
      } else {
        filepath = await FilePicker.getFilePath(
            type: fileType != null ? fileType : FileType.image,
            allowedExtensions: extensions);
        print(filepath);
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
        visible = true;
      });
    } on PlatformException catch (e) {
      print(AppStrings.filePathNotFound + e.toString());
    }
  }
  //----------------------------------------cupertino sheet

  void _show(BuildContext ctx) {
    showCupertinoModalPopup(
      context: ctx,
      builder: (ctctc) => CupertinoActionSheet(
          actions: [
            CupertinoActionSheetAction(
                onPressed: () {
                  openCamera();
                  Navigator.pop(ctctc);
                },
                child: Text(AppStrings.camera_text,style: TextStyle(fontFamily: AppFonts.regular,fontSize: 14),)),
            CupertinoActionSheetAction(
                onPressed: () {
                  openGallery();
                  Navigator.pop(ctctc);
                },
                child: Text(AppStrings.gallery_text,style: TextStyle(fontFamily: AppFonts.regular,fontSize: 14),)),
          ],
          cancelButton: CupertinoActionSheetAction(
            child: const Text(AppStrings.cancel_text,style: TextStyle(fontFamily: AppFonts.regular,fontSize: 14),),
            //isDefaultAction: true,
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(ctctc);
            },
          )),
    );
  }

  //-----------------------------post api data to store the  camera images and details to server
  _saveExternalAttachmentDictation() async {
     try{
       if (toggleVal == 0) {
         emergencyAddOn = false;
       } else {
         emergencyAddOn = true;
       }
      final String formatted = formatter.format(now);

      final bytes = File(image?.path).readAsBytesSync();
      String convertedImg = base64Encode(bytes);
      imageName = "${firstname.text}_${formatted}_${basename('${image?.path}')}";
      String attachmentType="jpg";
      photoListOfGallery.add(
          {
            "header": {
              "status": "string",
              "statusCode": "string",
              "statusMessage": "string"
            },
            "content": convertedImg,
            "name": imageName,
            "attachmentType": ".jpg"
          }
      );
      // String attachmentType="jpg";
      ExternalAttachmentPost apiAttachmentPostServices =
      ExternalAttachmentPost();
      SaveExternalDictationOrAttachment saveDictationAttachments =
      await apiAttachmentPostServices.postApiServiceMethod(
          int.parse(practiceId) ?? null,//selectedPracticeId
          int.parse(LocationId) ?? null,//locationId
          int.parse(providerId1) ?? null,//providerId
          firstname.text,//patientFname
          lastname.text,//patientLname
          _dateOfbirthController.text,//patientDob
          memberId,
          documenttypeId ?? null,
          emergencyAddOn,
          Description.text,
          null,//convertedImg,
          null,
          null,
          photoListOfGallery ?? null
      );
      statusCode = saveDictationAttachments?.header?.statusCode;
      //printing status code
      print("status $statusCode");
      print("memberID:: " + memberId);
    }
    catch (e) {
      print('SaveAttachmentDictation exception ${e.toString()}');
    }
  }

  //--------------Shared Preference for getting memberID
  _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      memberId = (prefs.getString(Keys.memberId) ?? '');
      print('$memberId');
    });
  }

  //------------save camera images to server with internet
  _saveCameraImagesToServer()async{
    if(image==null){
      return;
    }
    DateTime now = DateTime.now();
    String formattedDate = DateFormat(AppStrings.currentdate_text).format(now);
    int localExternalAttachmentId =
    await DatabaseHelper.db.insertExternalAttachmentData(
      ExternalAttachmentList(
        // externalattachmentid: extId ?? null,
        practiceid:practiceId!=null ? int.parse(practiceId):null,
        practicename: selectedPractice2??null,
        locationid: LocationId!=null ? int.parse(LocationId):null,
        locationname: selectedLocation,
        providerid: providerId1!=null ? int.parse(providerId1):null,
        providername: selectedProvidername??null,
        externaldocumenttype: selecteddocumnettype??null,
        externaldocumenttypeid: documenttypeId??null,
        patientfirstname: firstname.text??null,
        patientlastname: lastname.text??null,
        patientdob: _dateOfbirthController.text??null,
        isemergencyaddon: toggleVal ?? false,
        description: Description.text??null,
        displayfilename: selecteddocumnettype + "_" + memberId + "_" + formattedDate,
        uploadedtoserver: uploadedToServerTrue,
      ),
    );

    //----------------camera images insert to db
    if(localExternalAttachmentId>0){
     // print('inserting images of locAttachment $localExternalAttachmentId');
      final String formatted = formatter.format(now);
      int photoResult = await DatabaseHelper.db.insertPhotoLists(PhotoList(
        // id: localExternalAttachmentId,
          externalattachmentlocalid: localExternalAttachmentId,
          attachmentname: '${firstname.text ?? ''}_${formatted}_${basename(image.path)}',
          createddate: '$now',
          attachmenttype: AppStrings.imageFormat,
          physicalfilename: '${image?.path}')
      );
      print('photoResult $photoResult of locAttachment $localExternalAttachmentId');
    }

  }
  //-----------save camera images to without interent
  _saveCameraImagesToOfflinedata() async{
    if(image==null){
      return;
    }
    DateTime now = DateTime.now();
    String formattedDate = DateFormat(AppStrings.currentdate_text).format(now);
    int localExternalAttachmentId= await DatabaseHelper.db.insertExternalAttachmentData(
        ExternalAttachmentList(

          practiceid:practiceId!=null ? int.parse(practiceId):null,
          practicename: selectedPractice2??null,
          locationid: LocationId!=null ? int.parse(LocationId):null,
          locationname: selectedLocation??null,
          providerid: providerId1!=null ? int.parse(providerId1):null,
          providername: selectedProvidername??null,
          externaldocumenttype: selecteddocumnettype??null,
          externaldocumenttypeid: documenttypeId??null,
          patientfirstname: firstname.text??null,
          patientlastname: lastname.text??null,
          patientdob: _dateOfbirthController.text??null,
          isemergencyaddon: toggleVal ?? false,
          description: Description.text??null,
          displayfilename: selecteddocumnettype + "_" + memberId + "_" + formattedDate,
          uploadedtoserver: uploadedToServerFalse,
        )
    );

    //----------------camera images insert to db
    if(localExternalAttachmentId>0){
      //print('inserting images of locAttachment $localExternalAttachmentId');
      final String formatted = formatter.format(now);
      int photoResult = await DatabaseHelper.db.insertPhotoLists(PhotoList(
        // id: localExternalAttachmentId,
          externalattachmentlocalid: localExternalAttachmentId,
          attachmentname: '${firstname.text ?? ''}_${formatted}_${basename(image?.path)}',
          createddate: '$now',
          attachmenttype: AppStrings.imageFormat,
          physicalfilename: '${image?.path}'));
      print('photoResult $photoResult of locAttachment $localExternalAttachmentId');
    }
  }

  //-----------------save gallery images to DB without internet
  _saveGalleryImagesToDB()async{
    if(paths == null || paths.values == null){
      return;
    }
    DateTime now = DateTime.now();
    String formattedDate = DateFormat(AppStrings.currentdate_text).format(now);
    int localExternalAttachmentId= await DatabaseHelper.db.insertExternalAttachmentData(
        ExternalAttachmentList(
          practiceid:practiceId!=null ? int.parse(practiceId):null,
          practicename: selectedPractice2!=null ? selectedPractice2:null,
          locationid: LocationId!=null ? int.parse(LocationId):null,
          locationname: selectedLocation!=null ? selectedLocation:null,
          providerid: providerId1!=null ? int.parse(providerId1):null,
          providername: selectedProvidername!=null ? selectedProvidername:null,
          externaldocumenttype: selecteddocumnettype!=null ? selecteddocumnettype:null,
          externaldocumenttypeid: documenttypeId!=null?documenttypeId:null,
          patientfirstname: firstname.text??null,
          patientlastname: lastname.text??null,
          patientdob: _dateOfbirthController.text??null,
          isemergencyaddon: toggleVal ?? false,
          description: Description.text??null,
          displayfilename: selecteddocumnettype + "_" + memberId + "_" + formattedDate??null,
          uploadedtoserver: uploadedToServerFalse,
        ));
    //----------gallery images insert to db

    if(localExternalAttachmentId>0){
      // print('inserting images of locAttachment $localExternalAttachmentId');
      final String formatted = formatter.format(now);
      for (int i = 0; i < paths.values.toList().length; i++) {
        int photoResult = await DatabaseHelper.db.insertPhotoLists(PhotoList(
          // id: localExternalAttachmentId,
            externalattachmentlocalid: localExternalAttachmentId,
            attachmentname:
            '${firstname.text ?? ''}_${formatted}_${basename('${paths.values.toList()[i]}')}',
            createddate: '$now',
            attachmenttype: AppStrings.imageFormat,
            physicalfilename: '${paths.values.toList()[i]}'));
        print('_saveGalleryImagesToserver photoResult $photoResult of locAttachment $localExternalAttachmentId');
      }
    }
  }
  //------------------save gallery images and data to server with internet
  _saveGalleryImagesTosever()async{
    if(paths == null || paths.values == null){
      return;
    }

    DateTime now = DateTime.now();
    String formattedDate = DateFormat(AppStrings.currentdate_text).format(now);
    int localExternalAttachmentId = await DatabaseHelper.db.insertExternalAttachmentData(
        ExternalAttachmentList(
          // externalattachmentid: extId ?? null,
          practiceid:practiceId!=null ? int.parse(practiceId):null,
          practicename: selectedPractice2??null,
          locationid: LocationId!=null ? int.parse(LocationId):null,
          locationname: selectedLocation??null,
          providerid: providerId1!=null ? int.parse(providerId1):null,
          providername: selectedProvidername??null,
          externaldocumenttype: selecteddocumnettype??null,
          externaldocumenttypeid: documenttypeId??null,
          patientfirstname: firstname.text??null,
          patientlastname: lastname.text??null,
          patientdob: _dateOfbirthController.text??null,
          isemergencyaddon: toggleVal ?? false,
          description: Description.text ?? null,
          displayfilename: selecteddocumnettype + "_" + memberId + "_" + formattedDate??null,
          uploadedtoserver: uploadedToServerTrue
        ));
    //---------------------gallery images insert to db

    if(localExternalAttachmentId>0) {
      final String formatted = formatter.format(now);
      for (int i = 0; i < paths.values
          .toList()
          .length; i++) {
        int photoResult = await DatabaseHelper.db.insertPhotoLists(PhotoList(
          // id: localExternalAttachmentId,
            externalattachmentlocalid: localExternalAttachmentId,
            attachmentname:
            '${firstname.text ?? ''}_${formatted}_${basename(
                '${paths.values.toList()[i]}')}',
            createddate: '$now',
            attachmenttype: AppStrings.imageFormat,
            physicalfilename: '${paths.values.toList()[i]}'));

        final bytes = File('${paths.values.toList()[i]}').readAsBytesSync();
        String galleryImages = base64Encode(bytes);
        name = '${firstname.text ?? ''}_${formatted}_${basename(
            '${paths.values.toList()[i]}')}';
        photoListOfGallery.add(
            {
              "header": {
                "status": "string",
                "statusCode": "string",
                "statusMessage": "string"
              },
              "content": galleryImages,
              "name": name,
              "attachmentType": ".jpg"
            }
        );
      }
    }
      try {
        if (toggleVal == 0) {
          emergencyAddOn = false;
        } else {
          emergencyAddOn = true;
        }
        //........convert image byte format
        ExternalAttachmentPost apiAttachmentPostServices =
        ExternalAttachmentPost();
        SaveExternalDictationOrAttachment saveDictationAttachments =
        await apiAttachmentPostServices.postApiServiceMethod(
            int.parse(practiceId) ?? null,//selectedPracticeId
            int.parse(LocationId) ?? null,//locationId
            int.parse(providerId1) ?? null,//providerId
            firstname.text,//patientFname
            lastname.text,//patientLname
            _dateOfbirthController.text,//patientDob
            memberId??null,
            documenttypeId ?? null,
            emergencyAddOn??null,
            Description.text??null,
            null,
            null,
            null,
            photoListOfGallery??null
        );
        statusCode = saveDictationAttachments?.header?.statusCode;
        //printing status code
        print("status $statusCode");
        print("memberID:: " + memberId);
        // print("dictationId: From API: " + dicId);
      }
      catch (e) {
        print('SaveAttachmentDictation exception ${e.toString()}');
      }
    }
  }