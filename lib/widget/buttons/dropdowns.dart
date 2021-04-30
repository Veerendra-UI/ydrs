import 'package:YOURDRS_FlutterAPP/common/app_colors.dart';
import 'package:YOURDRS_FlutterAPP/common/app_text.dart';
import 'package:flutter/material.dart';

//stateless Widget for Common DropDown Button
class DropDown extends StatelessWidget {
  final String hint;

  final String value;
  final Function(String) onChanged;
  final items;
  DropDown(
      {@required this.hint,
      @required this.value,
      @required this.onChanged,
      @required this.items});
  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
          hint: Text(hint,style: TextStyle(fontFamily: AppFonts.regular),),
          value: value,
          isExpanded: true,
          isDense: true,
          onChanged: onChanged,
          items: items),
    );
  }
}

class DropDownDictationType extends StatelessWidget {
  final String hint;

  final value;
  final onChanged;
  final items;
  DropDownDictationType({
    @required this.hint,
    @required this.value,
    @required this.onChanged,
    @required this.items,
  });
  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
          hint: Text(
            hint,
            style: TextStyle(color: CustomizedColors.textColor,fontFamily: AppFonts.regular),
          ),
          value: value,
          isExpanded: true,
          isDense: true,
          onChanged: onChanged,
          items: items),
    );
  }
}
