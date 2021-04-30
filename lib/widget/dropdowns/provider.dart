import 'package:YOURDRS_FlutterAPP/common/app_colors.dart';
import 'package:YOURDRS_FlutterAPP/common/app_strings.dart';
import 'package:YOURDRS_FlutterAPP/common/app_text.dart';
import 'package:YOURDRS_FlutterAPP/widget/dropdowns/searchable_dropdown.dart';
import '../../network/services/schedules/appointment_service.dart';
import '../../network/models/home/provider.dart';
import 'package:flutter/material.dart';


class ProviderDropDowns extends StatefulWidget {
  final onTapOfProviders;
  final String selectedProviderId;
  ProviderDropDowns({@required this.onTapOfProviders, this.selectedProviderId});
  @override
  _ProviderState createState() => _ProviderState();
}

class _ProviderState extends State<ProviderDropDowns> {
  Services apiServices = Services();
  ProviderList providerList;
  List<ProviderList> _list = [];

// --------> get and decode the API data <-----------
  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    Providers provider = await apiServices.getProviders();
    _list = provider.providerList;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: MediaQuery.of(context).viewInsets,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width*0.70,

// ----------> displaying Provider list from API in SearchableDropdown <--------
      child: SearchableDropdown.single(
        displayClearIcon: false,
          underline: Padding(
        padding: EdgeInsets.all(5),
      ),
        icon: const Icon(Icons.arrow_drop_down,color: CustomizedColors.iconColor),
        hint: Text(AppStrings.providerhinttxt,style: TextStyle(fontFamily: AppFonts.regular,color: CustomizedColors.textColor),),
        items: _list.map((item) {
// ----------> displaying the the data which stored in data of list type <--------
          return DropdownMenuItem<ProviderList>(
            child: Text(
              item.displayname,
              overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: AppFonts.regular),
            ),
            value: item,
          );
        }).toList(),
        isExpanded: true,
        value: providerList,
        searchHint: new Text(AppStrings.providerhinttxt,
            style: new TextStyle(fontSize: 20,fontFamily: AppFonts.regular),),
// ----------> called when a new item is selected <--------
        onChanged: (value) {
          setState(() {
            providerList = value;
          });
          widget.onTapOfProviders(value);
        },
      ),
    );
  }
}
