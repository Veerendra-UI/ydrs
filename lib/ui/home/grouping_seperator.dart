import 'package:YOURDRS_FlutterAPP/common/app_text.dart';
import 'package:flutter/material.dart';


class TransactionGroupSeparator extends StatelessWidget {
final String practice;
int appointmentsCount;
final String locationName;
TransactionGroupSeparator(
    {this.practice, this.appointmentsCount, this.locationName});

@override
Widget build(BuildContext context) {
  return Center(
    child: Column(
      children: [
        SizedBox(
          height: 5,
        ),
        Center(
          child: Text(
            "${this.practice}-${this.locationName} ${[
              this.appointmentsCount
            ]} ",
            style:TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold,fontFamily: AppFonts.regular),
                maxLines: 2,
          ),
        ),
      ],
    ),
  );
}
}