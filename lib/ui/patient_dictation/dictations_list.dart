import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:YOURDRS_FlutterAPP/common/app_colors.dart';
import 'package:YOURDRS_FlutterAPP/common/app_strings.dart';
import 'package:YOURDRS_FlutterAPP/common/app_text.dart';
import 'package:YOURDRS_FlutterAPP/common/app_toast_message.dart';
import 'package:YOURDRS_FlutterAPP/network/models/dictations/dictations_model.dart';
import 'package:YOURDRS_FlutterAPP/network/models/dictations/play_dictations.dart';
import 'package:YOURDRS_FlutterAPP/network/models/home/schedule.dart';
import 'package:YOURDRS_FlutterAPP/network/repo/local/preference/local_storage.dart';
import 'package:YOURDRS_FlutterAPP/network/services/dictation/play_audio_services.dart';
import 'package:YOURDRS_FlutterAPP/ui/patient_dictation/play_audio.dart';
import 'package:YOURDRS_FlutterAPP/widget/buttons/mic_button.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:pdftron_flutter/pdftron_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class DictationsList extends StatefulWidget {
  static const String routeName = '/DictationsList';
  @override
  _DictationsListState createState() => _DictationsListState();
}

class _DictationsListState extends State<DictationsList> {
  /// declaring the variables related to PDFTron
  String _version = 'Unknown';
  String memberRoleId;
  String _document =
      "https://scholar.harvard.edu/files/torman_personal/files/samplepptx.pptx";
  bool _showViewer = true;
  @override
  void initState() {
    _loadData();
    super.initState();
    //   loadDocument();
  }

  getExtension() {
    final path =
        "https://scholar.harvard.edu/files/torman_personal/files/samplepptx.pptx";
    print(path.split(".").last);
  }

  _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      memberRoleId = (prefs.getString(Keys.memberRoleId) ?? '');
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String version;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      PdftronFlutter.initialize("your_pdftron_license_key");
      version = await PdftronFlutter.version;
    } on PlatformException {
      version = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _version = version;
    });
  }

  Future<void> launchWithPermission() async {
    Map<PermissionGroup, PermissionStatus> permissions =
    await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    if (granted(permissions[PermissionGroup.storage])) {
      showViewer();
    }
  }

  bool granted(PermissionStatus status) {
    return status == PermissionStatus.granted;
  }

  void showViewer() async {
    // opening without a config file will have all functionality enabled.
    // await PdftronFlutter.openDocument(_document);

    // shows how to disale functionality
//      var disabledElements = [Buttons.shareButton, Buttons.searchButton];
//      var disabledTools = [Tools.annotationCreateLine, Tools.annotationCreateRectangle];
    var config = Config();
//      config.disabledElements = disabledElements;
//      config.disabledTools = disabledTools;
//      config.multiTabEnabled = true;
//      config.customHeaders = {'headerName': 'headerValue'};
    config.disabledElements = [
      Buttons.arrowToolButton,
      Buttons.toolsButton,
      Buttons.viewControlsButton,
      Buttons.prepareFormButton,
      Buttons.printButton,
      Buttons.listsButton,
      Buttons.editPagesButton,
      Buttons.shareButton,
      Buttons.saveCopyButton,
      Buttons.viewControlsButton,
    ];
    // config.disabledTools=[];
    // config.disabledTools = [Tools.annotationCreateArrow];
    // config.hideAnnotationMenu = [AnnotationMenuItems.editText];
    config.showLeadingNavButton = false;
    config.hideBottomToolbar = true;
    config.hideTopToolbars = true;
    config.hideTopAppNavBar = true;
    config.signSignatureFieldWithStamps = false;
    var documentLoadedCancel = startDocumentLoadedListener((filePath) {
      print("document loaded: $filePath");
    });

    await PdftronFlutter.openDocument(_document, config: config);

    try {
      PdftronFlutter.importAnnotationCommand(
          "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" +
              "    <xfdf xmlns=\"http://ns.adobe.com/xfdf/\" xml:space=\"preserve\">\n" +
              "      <add>\n" +
              "        <square style=\"solid\" width=\"5\" color=\"#E44234\" opacity=\"1\" creationdate=\"D:20200619203211Z\" flags=\"print\" date=\"D:20200619203211Z\" name=\"c684da06-12d2-4ccd-9361-0a1bf2e089e3\" page=\"1\" rect=\"113.312,277.056,235.43,350.173\" title=\"\" />\n" +
              "      </add>\n" +
              "      <modify />\n" +
              "      <delete />\n" +
              "      <pdf-info import-version=\"3\" version=\"2\" xmlns=\"http://www.pdftron.com/pdfinfo\" />\n" +
              "    </xfdf>");
    } on PlatformException catch (e) {
      print("Failed to importAnnotationCommand '${e.message}'.");
    }

    try {
      PdftronFlutter.importBookmarkJson('{"0":"Page 1"}');
    } on PlatformException catch (e) {
      print("Failed to importBookmarkJson '${e.message}'.");
    }

    var annotCancel = startExportAnnotationCommandListener((xfdfCommand) {
      // local annotation changed
      // upload XFDF command to server here
      print("flutter xfdfCommand: $xfdfCommand");
    });

    var bookmarkCancel = startExportBookmarkListener((bookmarkJson) {
      print("flutter bookmark: $bookmarkJson");
    });

    var path = await PdftronFlutter.saveDocument();
    print("flutter save: $path");

    // to cancel event:
    // annotCancel();
    // bookmarkCancel();
  }

  bool isNetAvailable;
  var filePath;
  @override
  Widget build(BuildContext context) {
    //.......progressing bar
    Future<void> showLoadingDialog(BuildContext context, String msg) async {
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
                            style: TextStyle( fontFamily: AppFonts.regular,
                                fontSize: 18, fontWeight: FontWeight.w600),
                          )
                        ]),
                      )
                    ]));
          });
    }

    final Map args = ModalRoute.of(context).settings.arguments;
    List<DictationItem> list = args['list'];
    final Map args3 = ModalRoute.of(context).settings.arguments;
    ScheduleList item = args3['item'];

    /// used to get the recording from the server
    getRecordings(String fileName, String displayFileName) async {
      Directory appDocDirectory;
      //platform checking conditions
      if (Platform.isIOS) {
        appDocDirectory = await getApplicationDocumentsDirectory();
      } else {
        appDocDirectory = await getExternalStorageDirectory();
      }
      String dir = appDocDirectory.path;
      String fileExists = "$dir/" + "$fileName";

      /// check whether the file is there or no in device storage
      if (File(fileExists).existsSync()) {
        filePath = fileExists;
        setState(() {
          isNetAvailable = true;
        });
      } else {
        var connectivityResult = await (Connectivity().checkConnectivity());
        if (connectivityResult == ConnectivityResult.mobile ||
            connectivityResult == ConnectivityResult.wifi) {
          setState(() {
            isNetAvailable = true;
          });
          PlayAllAudioDictations apiServices1 = PlayAllAudioDictations();
          PlayDictations playDictations =
          await apiServices1.getDictationsPlayAudio(fileName);
          var getRecordings = playDictations.fileName;
          http.Response response = await http.get('$getRecordings');
          var _base64 = base64Encode(response.bodyBytes);
          Uint8List bytes = base64.decode(_base64);
          File file = File("$dir/" + '$displayFileName' + ".mp4");
          await file.writeAsBytes(bytes);
          filePath = file.path;
        } else {
          setState(() {
            isNetAvailable = false;
          });
        }
      }
    }

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('${item.patient?.displayName ?? ""}' +
              ', ${item.patient?.age.toString() + " " + AppStrings.yearOld ?? ""}' +
              ' ${item.patient?.sex ?? ""}',style: TextStyle(fontFamily: AppFonts.regular,),),
          backgroundColor: CustomizedColors.appBarColor,
        ),
        body: Container(
          margin: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width / 20,
            vertical: MediaQuery.of(context).size.height / 50,
          ),
          child: Column(
            children: [
              Container(
                child: Text(
                  "All Dictation",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,fontFamily: AppFonts.regular,),
                ),
                padding: EdgeInsets.only(bottom: 20),
              ),
              Flexible(
                child: ListView(
                  children: [
                    ListView.builder(
                      physics: ScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: list.length,
                      itemBuilder: (BuildContext context, int index) {
                        return AnimationLimiter(
                            child: Column(children: [
                              AnimationConfiguration.staggeredList(
                                  position: index,
                                  duration: const Duration(milliseconds: 500),
                                  child: FadeInAnimation(
                                      child: SlideAnimation(
                                          horizontalOffset:
                                          MediaQuery.of(context).size.width / 2,
                                          child: Card(
                                            child: Container(
                                              child: Column(
                                                children: [
                                                  Row(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                    children: [
                                                      Container(
                                                        width: width * 0.55,
                                                        child: Text(
                                                          '${list[index].dictationType ?? ""}' +
                                                              ', ${list[index].dos ?? ""}',
                                                          style: TextStyle( fontFamily: AppFonts.regular,
                                                              fontSize: 14),
                                                          overflow:
                                                          TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                      Container(
                                                        width: width * 0.15,
                                                        color: Colors.grey[300],
                                                        child: IconButton(
                                                          padding:
                                                          EdgeInsets.all(0),
                                                          onPressed: () {
                                                            // getExtension();
                                                            initPlatformState();

                                                            if (Platform.isIOS) {
                                                              // Open the document for iOS, no need for permission
                                                              showViewer();
                                                            } else {
                                                              // Request for permissions for android before opening document
                                                              launchWithPermission();
                                                            }
                                                          },
                                                          icon: Icon(
                                                            Icons.remove_red_eye,
                                                            size: 30,
                                                          ),
                                                          color: CustomizedColors.dictationListIconColor,
                                                        ),
                                                      ),
                                                      SizedBox(width: 5),
                                                      Container(
                                                        width: width * 0.15,
                                                        color: Colors.grey[300],
                                                        child: IconButton(
                                                            padding:
                                                            EdgeInsets.all(0),
                                                            onPressed: () async {
                                                              showLoadingDialog(
                                                                  context,
                                                                  AppStrings.loading);
                                                              await getRecordings(
                                                                  list[index]
                                                                      .fileName,
                                                                  list[index]
                                                                      .displayFileName);
                                                              Navigator.of(
                                                                  this.context,
                                                                  rootNavigator:
                                                                  true)
                                                                  .pop();
                                                              if (isNetAvailable ==
                                                                  true) {
                                                                await showCupertinoModalPopup<
                                                                    void>(
                                                                  context: context,
                                                                  builder:
                                                                      (BuildContext
                                                                  context) {
                                                                    return CupertinoActionSheet(
                                                                      actions: [
                                                                        Material(
                                                                          child:
                                                                          Container(
                                                                            height:
                                                                            height *
                                                                                0.35,
                                                                            child:
                                                                            Center(
                                                                              child:
                                                                              Container(
                                                                                height:
                                                                                height * 0.50,
                                                                                width:
                                                                                width * 0.90,
                                                                                child:
                                                                                ListView(
                                                                                  children: [
                                                                                    Column(
                                                                                      children: [
                                                                                        PlayAudio(
                                                                                          displayFileName: '${list[index].dictationType ?? ""}' +
                                                                                              ', ${list[index].dos ?? ""}',
                                                                                          filePath: filePath,
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        )
                                                                      ],
                                                                      cancelButton:
                                                                      CupertinoActionSheetAction(
                                                                        child:
                                                                        const Text(
                                                                          AppStrings
                                                                              .cancel,
                                                                          style: TextStyle( fontFamily: AppFonts.regular,
                                                                              color: CustomizedColors
                                                                                  .canceltextColor),
                                                                        ),
                                                                        //isDefaultAction: true,
                                                                        // isDestructiveAction: true,
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.pop(
                                                                              context);
                                                                        },
                                                                      ),
                                                                    );
                                                                  },
                                                                );
                                                              } else {
                                                                AppToast().showToast(
                                                                    AppStrings
                                                                        .networkNotConnected);
                                                              }
                                                            },
                                                            icon: Icon(
                                                              Icons.play_circle_fill,
                                                              size: 30,
                                                            ),
                                                            color: CustomizedColors.dictationListIconColor
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  // Divider(
                                                  //   thickness: 1,
                                                  // )
                                                ],
                                              ),
                                            ),
                                          ))))
                            ]));
                      },
                    ),
                    Container(
                      height: 80,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        /// calling the mic button widget from widget folder
        floatingActionButton: int.tryParse(memberRoleId) != 1
            ? AudioMicButtons(
            patientFName: item.patient.firstName,
            patientLName: item.patient.lastName,
            caseId: item.patient.accountNumber,
            patientDob: item.patient.dob,
            practiceId: item.practiceId,
            statusId: item.dictationStatusId,
            episodeId: item.episodeId,
            episodeAppointmentRequestId: item.episodeAppointmentRequestId,
            appointmentType: item.appointmentType)
            : null);
  }
}
