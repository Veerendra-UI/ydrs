import 'package:YOURDRS_FlutterAPP/common/app_colors.dart';
import 'package:YOURDRS_FlutterAPP/common/app_strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../common/app_text.dart';

class DateOfBirth extends StatefulWidget {
  final dobSelect;
  DateOfBirth({@required this.dobSelect});
  @override
  _DateOfBirthState createState() => _DateOfBirthState();
}

class _DateOfBirthState extends State<DateOfBirth>
    with AutomaticKeepAliveClientMixin {
  String _birthDate = 'Date of Birth';

  Future<void> _selectDate(BuildContext ctxdob) async {
    final DateTime d = await showDatePicker(
      context: ctxdob,
      initialEntryMode: DatePickerEntryMode.input,
      initialDate: DateTime.now(),
      firstDate: DateTime(1930),
      lastDate: DateTime.now(),
    );
    if (d != null)
      setState(() {
        final DateFormat formatter = DateFormat(AppStrings.dateFormatr);
        _birthDate = formatter.format(d);

        widget.dobSelect(_birthDate);
      });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
       //color: Colors.yellow,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.935,
              decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(
                        width: 1.0, color: CustomizedColors.accentColor),
                    left: BorderSide(
                        width: 1.0, color: CustomizedColors.accentColor),
                    right: BorderSide(
                        width: 1.0, color: CustomizedColors.accentColor),
                    bottom: BorderSide(
                        width: 1.0, color: CustomizedColors.accentColor),
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    InkWell(
                      child: Text(_birthDate,
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(color: CustomizedColors.accentColor,fontFamily: AppFonts.regular,)),
                      onTap: () {
                        _selectDate(context);
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.calendar_today_sharp,
                        color: CustomizedColors.accentColor,
                      ),
                      onPressed: () {
                        _selectDate(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
