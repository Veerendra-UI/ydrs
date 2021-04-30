import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:YOURDRS_FlutterAPP/common/app_colors.dart';
import 'package:YOURDRS_FlutterAPP/common/app_strings.dart';
import 'package:YOURDRS_FlutterAPP/common/app_text.dart';
import 'package:YOURDRS_FlutterAPP/common/app_toast_message.dart';
import 'package:YOURDRS_FlutterAPP/network/models/dictations/play_dictations.dart';
import 'package:YOURDRS_FlutterAPP/network/models/external_dictations/get_all_manual_dictation_model.dart';
import 'package:YOURDRS_FlutterAPP/network/services/dictation/dictation_services.dart';
import 'package:YOURDRS_FlutterAPP/network/services/dictation/play_audio_services.dart';
import 'package:YOURDRS_FlutterAPP/ui/patient_dictation/play_audio.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class GetMyManualDictations extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return GetMyManualDictationsState();
  }
}

class GetMyManualDictationsState extends State<GetMyManualDictations>
    with AutomaticKeepAliveClientMixin {
  /// Declaring variables
  bool _hasMore;
  int _pageNumber;
  bool _error;
  bool _loading;
  bool isNetAvailable;
  final int _defaultDataPerPageCount = 20;
  List<AudioDictations> _audioDictates;
  int thresholdValue = 0;
  var filePath;

  /// Creating an object for GetAllMyManualDictationApi
  AllMyManualDictations apiServices = AllMyManualDictations();

  /// initState
  @override
  void initState() {
    super.initState();
    _hasMore = true;
    _pageNumber = 1;
    _error = false;
    _loading = true;
    _audioDictates = [];
  }

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    GetAllMyManualDictation allMyManualDictations =
    await apiServices.getMyManualDictations(_pageNumber);
    if (!mounted) return;
    setState(() {
      _hasMore = allMyManualDictations.audioDictations?.length ==
          _defaultDataPerPageCount;
      _loading = false;
      _pageNumber = _pageNumber + 1;
      _audioDictates.addAll(allMyManualDictations?.audioDictations);
    });
  }

  /// build Method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getBody(),
    );
  }

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

  /// body Widget
  Widget getBody() {
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
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontFamily: AppFonts.regular,
                                fontWeight: FontWeight.w600),
                          )
                        ]),
                      )
                    ]));
          });
    }

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    if (_audioDictates?.isEmpty ?? false) {
      if (_loading) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(CustomizedColors.primaryColor),
            ),
          ),
        );
      } else if (_error) {
        return Center(
            child: InkWell(
              onTap: () {
                setState(
                      () {
                    _loading = true;
                    _error = false;
                    didChangeDependencies();
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                    "Error while loading photos, tap to try again after sometime",style: TextStyle(fontFamily: AppFonts.regular,  fontSize: 14,),),
              ),
            ));
      }
    } else {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: width / 50,
          vertical: height / 40,
        ),
        child: ListView.builder(
          itemCount: _audioDictates.length + (_hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _audioDictates.length - thresholdValue) {
              didChangeDependencies();
            }
            if (index == _audioDictates.length) {
              if (_error) {
                return Center(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _loading = true;
                          _error = false;
                          didChangeDependencies();
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text("Error while loading photos, tap to try again",style: TextStyle(fontFamily: AppFonts.regular,  fontSize: 14,),),
                      ),
                    ));
              } else {
                return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: CircularProgressIndicator(
                        valueColor:
                        AlwaysStoppedAnimation(CustomizedColors.primaryColor),
                      ),
                    ));
              }
            }
            final AudioDictations audioDictations = _audioDictates[index];
            // print("all data loaded successfully 7");
            return AnimationLimiter(
                child: Column(
                  children: [
                    AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 10),
                      child: FadeInAnimation(
                        child: SlideAnimation(
                          horizontalOffset: MediaQuery.of(context).size.width / 2,
                          child: Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 4,
                            shadowColor: CustomizedColors.accentColor,
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
                                          audioDictations.patientFirstName +
                                              ' ' +
                                              audioDictations.patientLastName +
                                              ',' +
                                              audioDictations.dos,
                                          style: TextStyle(
                                              fontFamily: AppFonts.regular,
                                              fontSize: 14),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Card(
                                       shadowColor: CustomizedColors.accentColor,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                        elevation: 10,
                                        color: Colors.white,
                                        child: IconButton(
                                          padding: EdgeInsets.all(0),
                                          icon: Icon(
                                            Icons.remove_red_eye,
                                            size: 30,
                                          ),
                                          onPressed: () {
                                          },
                                          color: CustomizedColors.accentColor,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 2,
                                      ),
                                      Card(
                                        shadowColor: CustomizedColors.accentColor,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                        elevation: 10,
                                        color: Colors.white,
                                        child: IconButton(
                                            padding: EdgeInsets.all(0),
                                            onPressed: () async {
                                              if (audioDictations.fileName.isEmpty ||
                                                  audioDictations.fileName ==
                                                      null ||
                                                  audioDictations.displayFileName ==
                                                      null ||
                                                  audioDictations
                                                      .displayFileName.isEmpty) {
                                                showDialog(
                                                  context: context,
                                                  builder: (ctxx) => AlertDialog(
                                                    contentPadding: EdgeInsets.zero,
                                                    title: Text(AppStrings
                                                        .noAudioRecordings,style: TextStyle(fontFamily: AppFonts.regular,),),
                                                    actions: [
                                                      FlatButton(
                                                        child: Text(
                                                            AppStrings.closeDialog,style: TextStyle(fontFamily: AppFonts.regular,  fontSize: 14,),),
                                                        onPressed: () {
                                                          Navigator.of(context,
                                                              rootNavigator:
                                                              true)
                                                              .pop();
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                  barrierDismissible: false,
                                                );
                                              } else {
                                                showLoadingDialog(
                                                    context, AppStrings.loading);
                                                await getRecordings(
                                                    audioDictations.fileName,
                                                    audioDictations
                                                        .displayFileName);
                                                Navigator.of(this.context,
                                                    rootNavigator: true)
                                                    .pop();
                                                if (isNetAvailable == true) {
                                                  await showCupertinoModalPopup<void>(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return CupertinoActionSheet(
                                                        actions: [
                                                          Material(
                                                            child: Container(
                                                              height: height * 0.35,
                                                              child: Center(
                                                                child: Container(
                                                                  height: height * 0.50,
                                                                  width: width * 0.90,
                                                                  child: ListView(
                                                                    children: [
                                                                      Column(
                                                                        children: [
                                                                          PlayAudio(
                                                                            displayFileName: audioDictations.patientFirstName +
                                                                                ' ' +
                                                                                audioDictations.patientLastName +
                                                                                ',' +
                                                                                audioDictations.dos,
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
                                                          child: const Text(
                                                            AppStrings.cancel,
                                                            style: TextStyle( fontFamily: AppFonts.regular,  fontSize: 14,
                                                                color: CustomizedColors
                                                                    .canceltextColor),
                                                          ),
                                                          //isDefaultAction: true,
                                                          // isDestructiveAction: true,
                                                          onPressed: () {
                                                            Navigator.pop(context);
                                                          },
                                                        ),
                                                      );
                                                    },
                                                  );
                                                } else {
                                                  AppToast().showToast(AppStrings
                                                      .networkNotConnected);
                                                }
                                              }
                                            },
                                            icon: Icon(
                                              Icons.play_circle_fill,
                                              size: 30,
                                            ),
                                            color: CustomizedColors
                                                .dictationListIconColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ));
          },
        ),
      );
    }
    return Container();
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}