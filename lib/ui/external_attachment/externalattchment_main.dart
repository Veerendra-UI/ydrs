import 'package:YOURDRS_FlutterAPP/common/app_colors.dart';
import 'package:YOURDRS_FlutterAPP/common/app_strings.dart';
import 'package:YOURDRS_FlutterAPP/common/app_toast_message.dart';
import 'package:YOURDRS_FlutterAPP/ui/home/home_screen.dart';
import 'package:YOURDRS_FlutterAPP/utils/route_generator.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../common/app_text.dart';
import 'allattachment/attachment_details/server/externalpage_get_api.dart';
import 'external_submitnew/external_submitscreen.dart';


//-----------------------This is ExternalAttachment home page this is the main page for submitne class and all attachment class

class ExternalAttachments extends StatefulWidget {
  static const String routeName = '/ExternalAttachments';
  @override
  _ExternalAttachmentStat createState() => _ExternalAttachmentStat();
}

class _ExternalAttachmentStat extends State<ExternalAttachments> {
  AppToast appToast=AppToast();
  bool isInternetAvailable=false;
  Future<void> checkInternet() async {
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
    }}
    @override
  void initState() {
    // TODO: implement initState
      checkInternet();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        resizeToAvoidBottomInset: false,
          appBar: AppBar(
           // automaticallyImplyLeading: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: ()
              {
                RouteGenerator.navigatorKey.currentState
                    .pushReplacementNamed(PatientAppointment.routeName);
              },
            ),
            backgroundColor: CustomizedColors.appbarColor,
            title: Text(AppStrings.externalattachment,style: TextStyle(fontFamily: AppFonts.regular,fontSize: 22),),
            centerTitle: true,
            actions: [
              IconButton(
                  icon: Icon(Icons.cloud_upload_outlined, size: 35),
                  onPressed: () {


                  }),
            ],
          ),
          body: DefaultTabController(
            length: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: 65,
                  child: Container(
                    //elevation: 5,
                    //color: CustomizedColors.tabColor,
                    child: TabBar(
                      tabs: [
                        Tab(
                            child: Text(
                          AppStrings
                              .submitnew, //here we called the text for SubmitNew
                          style: TextStyle( fontFamily: AppFonts.regular,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: CustomizedColors.submitnew_textColor,
                          ),
                        )),
                        Tab(
                          child: Text(
                            AppStrings
                                .allattachment, //here we called the text for AllAttachment
                            style: TextStyle( fontFamily: AppFonts.regular,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: CustomizedColors.allattachment_textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    decoration: BoxDecoration(boxShadow: [
                      new BoxShadow(
                        color: Colors.white,
                      ),
                    ]),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                     //
                       SubmitNew(),
                      GetMyAttachments(),
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
