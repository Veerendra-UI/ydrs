import 'package:YOURDRS_FlutterAPP/common/app_colors.dart';
import 'package:YOURDRS_FlutterAPP/common/app_strings.dart';
import 'package:YOURDRS_FlutterAPP/common/app_text.dart';
import 'file:///C:/Users/veerendra%20h/Desktop/images/YourDoctorApp/lib/cubit/location_cubit.dart';
import 'package:YOURDRS_FlutterAPP/widget/dropdowns/searchable_dropdown.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../network/services/schedules/appointment_service.dart';
import 'package:flutter/material.dart';

import '../../network/models/home/location.dart';

class LocationDropDown extends StatefulWidget {
  final onTapOfLocation;
  final String selectedLocationId;
  LocationDropDown({@required this.onTapOfLocation, this.selectedLocationId});
  @override
  _LocationState createState() => _LocationState();
}

class _LocationState extends State<LocationDropDown> {
  Services apiServices = Services();
  LocationList locationList;
  List<LocationList> _list = [];

// --------> get and decode the API data <-----------
  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    // Locations location = await apiServices.getLocation();
    // _list = location.locationList;
    // if (mounted) {
    //   setState(() {});
    BlocProvider.of<LocationListCubit>(context).getRecordsLocation();
    }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return BlocListener<LocationListCubit, LocationListCubitState>(
      listener: (context,state){
        if(state.errorMsg!=null)
          {
            print(state.errorMsg);
          }
        if(state.location != null)
          {
            _list =state.location;
          }
      },
      child: BlocBuilder<LocationListCubit,LocationListCubitState>(
        builder: (context,state){
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(10),

            width: MediaQuery.of(context).size.width*0.70,

// ----------> displaying Location list from API in SearchableDropdown <--------
            child: SearchableDropdown.single(
              underline: Padding(
                padding: EdgeInsets.all(5),
              ),
              displayClearIcon: false,
              icon: const Icon(Icons.arrow_drop_down,color: CustomizedColors.iconColor),
              hint: Text(AppStrings.lochinttxt,style: TextStyle(fontFamily: AppFonts.regular,color: CustomizedColors.textColor),),

// ----------> displaying the the data which stored in data of list type <--------
              items: _list.map((item) {
                return DropdownMenuItem<LocationList>(
                    child: Text(
                      item.locationName,
                      overflow: TextOverflow.ellipsis,style: TextStyle(fontFamily: AppFonts.regular),
                    ),
                    value: item);
              }).toList(),
              isExpanded: true,
              value: locationList,
              searchHint:
              new Text(AppStrings.lochinttxt, style: new TextStyle(fontSize: 20,fontFamily: AppFonts.regular)),
// ----------> called when a new item is selected <--------
              onChanged: (value) {
                setState(() {
                  locationList = value;
                });
                widget.onTapOfLocation(value);
              },
            ),
          );
        },
      ),
    );

  }
  }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       alignment: Alignment.center,
//       padding: const EdgeInsets.all(10),
//
//       width: MediaQuery.of(context).size.width*0.70,
//
// // ----------> displaying Location list from API in SearchableDropdown <--------
//       child: SearchableDropdown.single(
//               underline: Padding(
//         padding: EdgeInsets.all(5),
//       ),
//         displayClearIcon: false,
//         icon: const Icon(Icons.arrow_drop_down,color: CustomizedColors.iconColor),
//         hint: Text(AppStrings.lochinttxt,style: TextStyle(fontFamily: AppFonts.regular,color: CustomizedColors.textColor),),
//
// // ----------> displaying the the data which stored in data of list type <--------
//         items: _list.map((item) {
//           return DropdownMenuItem<LocationList>(
//               child: Text(
//                 item.locationName,
//                 overflow: TextOverflow.ellipsis,style: TextStyle(fontFamily: AppFonts.regular),
//               ),
//               value: item);
//         }).toList(),
//         isExpanded: true,
//         value: locationList,
//         searchHint:
//             new Text(AppStrings.lochinttxt, style: new TextStyle(fontSize: 20,fontFamily: AppFonts.regular)),
// // ----------> called when a new item is selected <--------
//         onChanged: (value) {
//           setState(() {
//             locationList = value;
//           });
//           widget.onTapOfLocation(value);
//         },
//       ),
//     );
//   }
// }
