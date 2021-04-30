import 'package:YOURDRS_FlutterAPP/common/app_colors.dart';
import 'package:YOURDRS_FlutterAPP/common/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';

import '../common/app_text.dart';

class DateOfService extends StatefulWidget {
  final dosSelect;
  DateOfService({@required this.dosSelect});
  @override
  _DateOfServiceState createState() => _DateOfServiceState();
}

class _DateOfServiceState extends State<DateOfService>
    with AutomaticKeepAliveClientMixin {
  String _serviceDate = 'Service date';

  Future<void> _selectDate(BuildContext ctxdos) async {
    final DateTime d = await showDatePicker(
      context: ctxdos,
      initialEntryMode: DatePickerEntryMode.input,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime(2030),
    );
    if (d != null)
      setState(() {
        final DateFormat formatter = DateFormat(AppStrings.dateFormatr);
        _serviceDate = formatter.format(d);
        widget.dosSelect(_serviceDate);
      });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
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
                      child: Text(_serviceDate,
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
