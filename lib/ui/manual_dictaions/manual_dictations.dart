import 'package:YOURDRS_FlutterAPP/common/app_colors.dart';
import 'package:YOURDRS_FlutterAPP/common/app_strings.dart';
import 'package:YOURDRS_FlutterAPP/common/app_text.dart';
import 'package:YOURDRS_FlutterAPP/ui/home/home_screen.dart';
import 'package:YOURDRS_FlutterAPP/ui/manual_dictaions/manual_dictations_lists.dart';
import 'package:YOURDRS_FlutterAPP/ui/manual_dictaions/submit_new_dictation.dart';
import 'package:YOURDRS_FlutterAPP/utils/route_generator.dart';
import 'package:flutter/material.dart';

class ManualDictations extends StatefulWidget {
  static const String routeName = '/ManualDictations';
  @override
  _ManualDictationsState createState() => _ManualDictationsState();
}

class _ManualDictationsState extends State<ManualDictations> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: CustomizedColors.primaryColor,
        title: Text(
          AppStrings.appBarTitle,
          style: TextStyle(fontFamily: AppFonts.regular,  fontSize: 22,),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded),
          onPressed: () {
            RouteGenerator.navigatorKey.currentState
                .pushReplacementNamed(PatientAppointment.routeName);
          },
        ),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: <Widget>[
            Container(
              constraints: BoxConstraints(maxHeight: 150.0),
              child: Material(
                color: CustomizedColors.tabColor,
                child: TabBar(
                  tabs: [
                    Tab(
                        child: Text(
                      AppStrings.tabSubmitNew,
                      style: TextStyle(
                          color: CustomizedColors.primaryColor,
                          fontSize: 16.5,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppFonts.regular),
                    )),
                    Tab(
                        child: Text(
                      AppStrings.tabAllDictation,
                      style: TextStyle(
                          color: CustomizedColors.primaryColor,
                          fontSize: 16.5,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppFonts.regular),
                    )),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  //--------First screen
                  SubmitNewDictation(),
                  //--------second screen
                  // AllDictations(),
                  GetMyManualDictations(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
