import 'package:YOURDRS_FlutterAPP/blocs/dictation_screen/audio_dictation_bloc.dart';
import 'package:YOURDRS_FlutterAPP/blocs/dictation_screen/audio_dictation_event.dart';
import 'package:YOURDRS_FlutterAPP/blocs/dictation_screen/audio_dictation_state.dart';
import 'package:YOURDRS_FlutterAPP/common/app_colors.dart';
import 'package:YOURDRS_FlutterAPP/common/app_constants.dart';
import 'package:YOURDRS_FlutterAPP/common/app_loader.dart';
import 'package:YOURDRS_FlutterAPP/common/app_strings.dart';
import 'package:YOURDRS_FlutterAPP/common/app_toast_message.dart';
import 'package:YOURDRS_FlutterAPP/helper/db_helper.dart';
import 'package:YOURDRS_FlutterAPP/network/models/dictations/post_dictations_model.dart';
import 'package:YOURDRS_FlutterAPP/network/models/manual_dictations/dictation.dart';
import 'package:YOURDRS_FlutterAPP/network/repo/local/preference/local_storage.dart';
import 'package:YOURDRS_FlutterAPP/network/services/dictation/post_dictations_service.dart';
import 'package:YOURDRS_FlutterAPP/ui/audio_dictations/random_waves.dart';
import 'package:YOURDRS_FlutterAPP/widget/save_dictations_alert.dart';
import 'package:connectivity/connectivity.dart';
import 'package:file/local.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/app_text.dart';

final GlobalKey<State> _keyLoader = GlobalKey<State>();

class AudioDictationForPatientDetails extends StatefulWidget {
  final String patientFName,
      patientLName,
      patientDob,
      dictationTypeId,
      caseNum,
      dictationTypeName,
      appointmentType;
  final int onlineStatusId;
  final int offlineStatusId = 107;
  final episodeAppointmentRequestId, episodeId;
  final int offlineUploadedToServer = 0, onlineUploadToServer = 1;
  final int statusId = 17;
  const AudioDictationForPatientDetails(
      {Key key,
      this.patientFName,
      this.patientLName,
      this.patientDob,
      this.dictationTypeId,
      this.caseNum,
      this.appointmentType,
      this.dictationTypeName,
      this.episodeId,
      this.onlineStatusId,
      this.episodeAppointmentRequestId})
      : super(key: key);
  @override
  _AudioDictationState createState() => _AudioDictationState();
}

class _AudioDictationState extends State<AudioDictationForPatientDetails> {
  var data, dictId;
  String memberId;
  var dob;
  var memeberRoleId;
  String attachmentContent;
  String fName;
  String lName;
  bool isInternetAvailable = true;
  bool isStarted = false;
  bool isStartedUploadBtn = true;
  String audioSize;
  bool isUpload = false;
  bool saveforlater = false;
  @override
  void initState() {
    super.initState();
    _loadData();
    DeleteFiles();
  }
  ///delete 90 days older records
  // ignore: non_constant_identifier_names
  void DeleteFiles() async {
    await DatabaseHelper.db.deleteAllOlderRecords();
  }
  ///checking internet connectivity to upload files to server.
  checkNetwork() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      //  connected to a mobile network.
      setState(() {
        isInternetAvailable = true;
      });
    } else {
      //  connected to a wifi network.
      setState(() {
        isInternetAvailable = false;
        AppToast().showToast(AppStrings.networkNotConnected);
      });
    }
  }
  ///Loading data from shared preferences.
  _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      memberId = (prefs.getString(Keys.memberId) ?? '');
      dob = (prefs.getString(Keys.dob) ?? '');

      memeberRoleId = (prefs.getString(Keys.memberRoleId) ?? '');
    });
  }
  /// parsing parameters to service class
  // ignore: non_constant_identifier_names
  SaveDictations(String attachmentContentType) async {
    String lastAudioFilePath =
        BlocProvider.of<AudioDictationBloc>(context).finalPath;
    String audioFileName = path.basename(lastAudioFilePath);
    fName = widget.patientFName;
    lName = widget.patientLName;
    try {
      PostDictationsService apiPostServices = PostDictationsService();
      PostDictationsModel saveDictations = await apiPostServices.postApiMethod(
          int.tryParse(memberId),
          dob,
          widget.episodeId,
          widget.episodeAppointmentRequestId,
          int.parse(memeberRoleId),
          int.parse(widget.dictationTypeId),
          fName,
          lName,
          widget.caseNum,
          widget.patientDob,
          attachmentContent,
          audioFileName,
          widget.dictationTypeName);
      dictId = saveDictations.dictationId;
      data = saveDictations.header.statusCode;
    } catch (e) {
      print('${e.toString()}');
    }
  }
  ///Alert dialouge box to show success and Fail status.
  _dialogBox(int i) {
    if (data == "200") {
      return showDialog(
          barrierDismissible: false,
          context: context,
          builder: (ctx) => SaveDictationsAlert(
                title: AppStrings.uploadToServer,
                clr: CustomizedColors.uploadToServerTextColor,
                count: i,
              ));
    } else {
      return showDialog(
          barrierDismissible: false,
          context: context,
          builder: (ctx) => SaveDictationsAlert(
                title: AppStrings.uploadFailed,
                clr: CustomizedColors.uploadFailTextColor,
                count: i,
              ));
    }
  }
  LocalFileSystem localFileSystem;
  Recording _current;
  RecordingStatus _currentStatus = RecordingStatus.Unset;
  bool viewVisible = true;
  final DateTime now = DateTime.now();
  final DateFormat formatter = DateFormat(AppConstants.dateFormat);
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: _body(),
      ),
    );
  }
  _body() {
    final height = MediaQuery.of(context).size.height;
    return BlocListener<AudioDictationBloc, AudioDictationState>(
      listener: (context, state) async {
        attachmentContent = state.attachmentContent;
        if (isUpload || saveforlater) {
          if (attachmentContent != null && attachmentContent.isNotEmpty) {
            await SaveDictations(state.attachmentContentType);
            if (saveforlater) {
              _insertRecordsToDataBase(
                  widget.statusId, widget.onlineUploadToServer,
                  dictationId: dictId.toString());
              saveforlater = false;
              await _dialogBox(3);
            } else {
              isUpload = false;
              _insertRecordsToDataBase(
                  widget.onlineStatusId, widget.onlineUploadToServer,
                  dictationId: dictId.toString());
              await _dialogBox(4);
            }
        }
        }
        _currentStatus = state.currentStatus;
        _current = state.current;
        viewVisible = state.viewVisible;
        isStarted = (_currentStatus == RecordingStatus.Recording ||
            _currentStatus == RecordingStatus.Paused);

        if (state.errorMsg != null && state.errorMsg.isNotEmpty) {
          // ignore: deprecated_member_use
          Scaffold.of(context).showSnackBar(SnackBar(
              content: Text(state.errorMsg ?? AppStrings.someThingWentWrong,style: TextStyle(fontFamily: AppFonts.regular,),)));
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
                            Text("${_printDuration(_current?.duration)}",style: TextStyle(fontFamily: AppFonts.regular,),),
                            /////Save for later flat button
                            // ignore: deprecated_member_use
                            FlatButton(
                                onPressed: isStarted
                                    ? () async {
                                        ///calling post api to upload audio file
                                        BlocProvider.of<AudioDictationBloc>(
                                                context)
                                            .add(StopRecord());
                                        //checking internet connection
                                        await checkNetwork();
                                        if (isInternetAvailable == true) {
                                          saveforlater = true;
                                          ///progress bar
                                          showLoderDialog(
                                              context, text: AppStrings.uploading);
                                        } else {
                                          ///save dictations offline
                                          _insertRecordsToDataBase(
                                              widget.statusId,
                                              widget.offlineUploadedToServer);
                                          await _dialogBox(4);
                                        }
                                      }: null,
                                child: Text(
                                  AppStrings.saveForLater,
                                  style: TextStyle( fontFamily: AppFonts.regular,
                                      fontWeight: FontWeight.bold,
                                      color: isStarted
                                          ? CustomizedColors.saveLaterColor
                                          : null,
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
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width / 30,
                                  vertical:
                                      MediaQuery.of(context).size.height / 150),
                              // ignore: deprecated_member_use
                              child: FlatButton(
                                  padding: EdgeInsets.all(0),
                                  ///on press for start and resume.
                                  onPressed: isStartedUploadBtn
                                      ? () {
                                          switch (_currentStatus) {
                                            case RecordingStatus.Initialized:
                                              {
                                                /// bloc provider for start record event
                                                BlocProvider.of<
                                                            AudioDictationBloc>(
                                                        context)
                                                    .add(StartRecord());
                                                //Toast for recording started
                                                AppToast().showToast(AppStrings
                                                    .recordingStarted);
                                                break;
                                              }
                                            case RecordingStatus.Recording:
                                              {
                                                /// bloc provider for pause record event
                                                BlocProvider.of<
                                                            AudioDictationBloc>(
                                                        context)
                                                    .add(PauseRecord());
                                                //Toast for recording paused
                                                AppToast().showToast(
                                                    AppStrings.recordingPaused);
                                                break;
                                              }
                                            case RecordingStatus.Paused:
                                              {
                                                /// bloc provider for resume record event
                                                BlocProvider.of<AudioDictationBloc>(
                                                        context)
                                                    .add(ResumeRecord());
                                                //Toast for recording resumed
                                                AppToast().showToast(AppStrings
                                                    .recordingResumed);
                                                break;
                                              }
                                            case RecordingStatus.Stopped:
                                              {
                                                /// bloc provider for init event
                                                BlocProvider.of<
                                                            AudioDictationBloc>(
                                                        context)
                                                    .add(InitRecord());
                                                break;
                                              }
                                            default:
                                              break;
                                          }
                                        }
                                      : null,
                                  child: _buildText(_currentStatus)),
                            ),
                            ////upload icon
                            // ignore: deprecated_member_use
                            FlatButton(
                                padding: EdgeInsets.all(0),
                                onPressed: isStarted
                                    ? () async {
                                        BlocProvider.of<
                                                AudioDictationBloc>(context)
                                            .add(PauseRecord());
                                        /// Upload audio popup screen
                                        await showCupertinoModalPopup(
                                          context: context,
                                          builder: (BuildContext sheetContext) {
                                            return CupertinoActionSheet(
                                              actions: [ Material(
                                                child: Container(
                                                  height: height * 0.35,
                                                  child: Column(
                                                    children: [
                                                      Icon(
                                                        Icons.cloud_upload,
                                                        size: 75,
                                                        color: CustomizedColors
                                                            .waveColor,
                                                      ),
                                                      SizedBox(
                                                        height: height * 0.01,
                                                      ),
                                                      Text(
                                                        AppStrings.dict,
                                                        style: TextStyle( fontFamily: AppFonts.regular,
                                                          fontSize: 17,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: height * 0.025,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: [
                                                          /// cancel button in upload dictation dialouge
                                                          // ignore: deprecated_member_use
                                                          RaisedButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: Text(
                                                              AppStrings
                                                                  .cancel,
                                                              style: TextStyle(
                                                                  fontSize: 20,
                                                                  fontWeight: FontWeight.bold, fontFamily: AppFonts.regular,
                                                                  color: CustomizedColors
                                                                      .alertCancelColor),
                                                            ),
                                                          ),
                                                          ///upload button with functionalities.
                                                          // ignore: deprecated_member_use
                                                          RaisedButton(
                                                            onPressed:
                                                                () async {
                                                              setState(() {
                                                                isStartedUploadBtn =
                                                                    false;
                                                              });
                                                              ///calling post api to upload audio file
                                                              BlocProvider.of<
                                                                          AudioDictationBloc>(
                                                                      context)
                                                                  .add(
                                                                      StopRecord());
                                                              //checking internet connection
                                                              await checkNetwork();
                                                              if (isInternetAvailable ==
                                                                  true) {
                                                                isUpload =
                                                                    true;
                                                                showLoderDialog(
                                                                    context,
                                                                    text: AppStrings.uploading);

                                                              } else {
                                                                setState(() {
                                                                  isStarted =
                                                                      false;
                                                                });
                                                                AppToast().showToast(
                                                                    AppStrings
                                                                        .networkNotConnected);
                                                                _dialogBox(5);
                                                                ///If no internet(offline) records would be saved in db.
                                                                _insertRecordsToDataBase(
                                                                    widget
                                                                        .offlineStatusId,
                                                                    widget
                                                                        .offlineUploadedToServer);
                                                                _dialogBox(6);
                                                              }
                                                            },
                                                            child: Text(
                                                              AppStrings
                                                                  .upload,
                                                              style: TextStyle( fontFamily: AppFonts.regular,
                                                                  fontSize:
                                                                      20,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: CustomizedColors
                                                                      .textColor),
                                                            ),
                                                            color:
                                                                Colors.green,
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),]
                                            );
                                          },
                                        );
                                      }: null,
                                //cloud icon to upload file.
                                child: Icon(
                                  Icons.cloud_upload,
                                  size: 50,
                                  color: isStarted
                                      ? CustomizedColors.waveColor
                                      : null,
                                )),
                            // ignore: deprecated_member_use
                            FlatButton(
                              child: Icon(
                                Icons.delete,
                                color: isStarted
                                    ? CustomizedColors.deleteIconColor
                                    : null,
                                size: 50,
                              ),
                              onPressed: isStarted
                                  ? () {
                                      /// bloc provider for delete record event
                                      BlocProvider.of<AudioDictationBloc>(
                                              context)
                                          .add(DeleteRecord());
                                      //Toast for recording deleted.
                                      AppToast().showToast(
                                          AppStrings.recordingDeleted);
                                    }
                                  : null,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // ignore: deprecated_member_use
                            RaisedButton(
                              onPressed: () {
                                if (isStarted == false) {
                                  Navigator.pop(context);
                                } else {
                                  /// bloc provider for delete record event
                                  BlocProvider.of<AudioDictationBloc>(context)
                                      .add(DeleteRecord());
                                  Navigator.pop(context);
                                }
                              },
                              child: Text(
                                AppStrings.cancel,
                                style: TextStyle( fontFamily: AppFonts.regular,
                              fontSize:
                                    20,
                                    fontWeight:
                                    FontWeight
                                        .bold,
                                    color: CustomizedColors
                                        . cancelTextColor),
                              ),
                            ),
                          ],
                        )
                      ]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  /// setting timer format
  String _printDuration(Duration duration) {
    if (duration != null) {
      String twoDigits(int n) => n.toString().padLeft(2, "0");
      String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
      String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }
    return '';
  }
  ///play pause button icons
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
      color: isStartedUploadBtn ? CustomizedColors.waveColor : null,
      size: 55,
    );
  }
  ///insert online and offline Dictation Data
  _insertRecordsToDataBase(int statusId, int uploadToServer,
      {String dictationId}) async {
    try {
      final String formatted = formatter.format(now);
      await DatabaseHelper.db.insertAudioRecords(
          PatientDictation(
              // dictationId: '$dictId',
              dictationId: dictationId,
              fileName:
                  '${widget.dictationTypeName}_${widget.patientFName}_${widget.caseNum}_$formatted.mp4',
              patientFirstName: '${widget.patientFName ?? ''}',
              patientLastName: '${widget.patientLName ?? ''}',
              patientDOB: '${widget.patientDob ?? ''}',
              attachmentName:
              '${widget.dictationTypeName}_${widget.patientFName}_${widget.caseNum}_$formatted.mp4',
              createdDate: '${DateTime.now() ?? ''}',
              memberId: int.parse(memberId),
              episodeId: widget.episodeId ?? '',
              appointmentId: widget.episodeAppointmentRequestId ?? '',
              dictationTypeId: widget.dictationTypeId,
              physicalFileName: _current?.path ?? '',
              statusId: statusId ?? '',
              displayFileName:
                  '${widget.dictationTypeName}_${widget.patientFName}_${widget.caseNum}_$formatted',
              uploadedToServer: uploadToServer ?? '',
              attachmentType: '.mp4'));
    } catch (e) {
      print(e.toString());
    }
  }
}
