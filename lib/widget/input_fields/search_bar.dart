import 'package:YOURDRS_FlutterAPP/common/app_colors.dart';
import 'package:YOURDRS_FlutterAPP/common/app_strings.dart';
import 'package:YOURDRS_FlutterAPP/common/app_text.dart';
import 'package:flutter/material.dart';

class PatientSerach extends StatelessWidget {
  int width;
  double height;
  final onChanged;
    final controller;

    // ---> Implementing the constructor <----
  PatientSerach(
      {@required this.onChanged, @required this.width, @required this.height,@required this.controller}
      );

  @override
  Widget build(BuildContext context) {

// ---> search bar <---
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Container(
        margin: EdgeInsets.only(top: 0.0),
        height: height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            ListTile(
              trailing: Icon(Icons.search),
              title: new TextField(
                 controller: controller,
                autofocus: false,
                decoration: InputDecoration.collapsed(hintText: AppStrings.searchpatienttitle,
                    border: InputBorder.none),
                style: TextStyle(color: CustomizedColors.dropdowntxtcolor,fontFamily: AppFonts.regular),
// --> called value is changed <----
                onChanged: onChanged,
              ),
            )
          ],
        ),
      )
      );
  }
}
