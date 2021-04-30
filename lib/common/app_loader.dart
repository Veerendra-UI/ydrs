import 'package:YOURDRS_FlutterAPP/common/app_colors.dart';
import 'package:YOURDRS_FlutterAPP/common/app_strings.dart';
import 'package:YOURDRS_FlutterAPP/common/app_text.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class CustomizedCircularProgressBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        ///onWillPop disables back button for this specific widget.
        onWillPop: () async => false,
        child: SimpleDialog(
            key: key,
            backgroundColor: Colors.white,
            children: <Widget>[
              Center(
                child: Row(children: [
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
                    "Loading...",
                    // text,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontFamily: AppFonts.regular,
                        fontWeight: FontWeight.w600),
                  )
                ]),
              )
            ]));
  }
}

///customized loading progress bar
showLoderDialog(BuildContext context, {@required String text}) async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () async => false,
        child: SimpleDialog(
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
                  text,
                  style: TextStyle( fontFamily: AppFonts.regular,
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w600),
                )
              ],
            )),
          ],
        ),
      );
    },
  );
}
