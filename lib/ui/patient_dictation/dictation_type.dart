import 'package:YOURDRS_FlutterAPP/common/app_colors.dart';
import 'package:YOURDRS_FlutterAPP/common/app_strings.dart';
import 'package:YOURDRS_FlutterAPP/network/models/dictations/dictations_model.dart';
import 'package:YOURDRS_FlutterAPP/network/models/home/schedule.dart';
import 'package:YOURDRS_FlutterAPP/network/repo/local/preference/local_storage.dart';
import 'package:YOURDRS_FlutterAPP/ui/patient_dictation/dictations_list.dart';
import 'package:YOURDRS_FlutterAPP/utils/route_generator.dart';
import 'package:YOURDRS_FlutterAPP/widget/buttons/mic_button.dart';
import 'package:YOURDRS_FlutterAPP/widget/buttons/raised_buttons.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/app_text.dart';

class DictationType extends StatefulWidget {
  static const String routeName = AppStrings.dictationRouteName;

  @override
  _DictationTypeState createState() => _DictationTypeState();
}

class _DictationTypeState extends State<DictationType> {
 String memberRoleId;
  @override
  void initState() {
    _loadData();
    // TODO: implement initState
    super.initState();

  }
  _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      memberRoleId = (prefs.getString(Keys.memberRoleId) ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map args = ModalRoute.of(context).settings.arguments;
    List<DictationItem> list = args[AppStrings.allDictationList];
    final Map args1 = ModalRoute.of(context).settings.arguments;
    List<DictationItem> list1 = args1[AppStrings.preDictationList];
    final Map args2 = ModalRoute.of(context).settings.arguments;
    List<DictationItem> list2 = args2[AppStrings.myPreDictationList];
    final Map args3 = ModalRoute.of(context).settings.arguments;
    ScheduleList item = args3[AppStrings.dictationItem];
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(AppStrings.allDictations,style: TextStyle(fontFamily: AppFonts.regular,),),
        backgroundColor: CustomizedColors.appBarColor,
      ),
      body: Builder(
        builder: (context) => Container(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// calling raised button class from the raised button widget folder
                  RaisedBtn1(
                      text: AppStrings.allDictations,
                      count: list.length,
                      onPressed: () {
                        RouteGenerator.navigatorKey.currentState
                            .pushNamed(DictationsList.routeName,
                            arguments: {
                              'list': list,
                              'item': item
                            });
                      }),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// calling raised button class from the raised button widget folder
                  RaisedBtn1(
                    text: AppStrings.textAllDictation,
                    count: list1.length,
                    onPressed: () {
                      {
                        RouteGenerator.navigatorKey.currentState
                            .pushNamed(DictationsList.routeName,
                            arguments: {
                      'list': list1,
                      'item': item
                      });
                      }
                    }
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// calling raised button class from the raised button widget folder
                  RaisedBtn1(
                    text: AppStrings.textMyDictation,
                    count: list2.length,
                    onPressed: () {
                      {
                        RouteGenerator.navigatorKey.currentState.pushNamed(
                            DictationsList.routeName,
                            arguments: {
                      'list': list2,
                      'item': item
                      });
                      }
                    },
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height / 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /// calling the mic button widget from widget folder
                   int.tryParse(memberRoleId)!=1? AudioMicButtons(
                        patientFName: item.patient.firstName,
                        patientLName: item.patient.lastName,
                        caseId: item.patient.accountNumber,
                        patientDob: item.patient.dob,
                        practiceId: item.practiceId,
                        statusId: item.dictationStatusId,
                        episodeId: item.episodeId,
                        episodeAppointmentRequestId: item.episodeAppointmentRequestId,
                        appointmentType: item.appointmentType
                    ):Container(
                      height:5,
                      width:5
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
