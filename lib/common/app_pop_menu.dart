import 'package:YOURDRS_FlutterAPP/common/app_colors.dart';
import 'package:YOURDRS_FlutterAPP/common/app_strings.dart';
import 'package:YOURDRS_FlutterAPP/common/app_text.dart';
import 'package:YOURDRS_FlutterAPP/network/repo/local/preference/local_storage.dart';
import 'package:YOURDRS_FlutterAPP/ui/external_attachment/externalattchment_main.dart';
import 'package:YOURDRS_FlutterAPP/ui/login/login_screen/loginscreen.dart';
import 'package:YOURDRS_FlutterAPP/ui/manual_dictaions/manual_dictations.dart';
import 'package:YOURDRS_FlutterAPP/utils/route_generator.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

class Pop extends StatefulWidget {
  final int initialValue;
  final double xPos;
  final double yPos;

  final ValueChanged<Offset> onChanged;
  const Pop({
    Key key,
    this.onChanged,
    this.xPos: 0.0,
    this.yPos: 0.0, this.initialValue,
  })
      : super(key: key);
  @override
  _PopState createState() => _PopState();
}

class _PopState extends State<Pop> {
  double xPos = 0.0;
  double yPos = 0.0;

  double xStart = 0.0;
  double yStart = 0.0;


  void reset()
  {
    xPos  = 0.0;
    yPos  = 0.0;
  }


  SharedPreferences logindata;
  String username;
    int roleId;
  @override
  void initState() {
    super.initState();
 
  }

   initial() async {
    logindata = await SharedPreferences.getInstance();
    // setState(() {
      username = logindata.getString('username');
    // });
  }



  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
      await initial();
    await _loadData();
  }

 _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var memberRoleId =(prefs.getString(Keys.memberRoleId) ?? " ");
      roleId = int.tryParse(memberRoleId);
    print(roleId);
  }
  int number;

  void onChanged(Offset offset)
  {
    final RenderBox referenceBox = context.findRenderObject();
    Offset position = referenceBox.globalToLocal(offset);
    if (widget.onChanged != null)
    {
      //    print('---- onChanged.CHANGE ----');
      widget.onChanged(position);
    }
    else
    {
      //    print('---- onChanged.NO CHANGE ----');
    }

    xPos = position.dx;
    yPos = position.dy;

  }

  @override
  bool hitTestSelf(Offset position) => true;
  void _handlePanStart(DragStartDetails details) {
    print('start');
    final RenderBox referenceBox = context.findRenderObject();
    Offset position = referenceBox.globalToLocal(details.globalPosition);

    onChanged(details.globalPosition);
    xStart = xPos;
    yStart = yPos;
  }
  void _handleTapUp(TapUpDetails details) {
    //  _scene.clear();

    print('--- _handleTapUp   ---');
    final RenderBox referenceBox = context.findRenderObject();
    Offset position = referenceBox.globalToLocal(details.globalPosition);
    onChanged(new Offset(0.0, 0.0));

    //_showPopupMenu(context);
    print('+++ _handleTapUp   [${position.dx},${position.dy}] +++');
  }

  @override
  Widget build(BuildContext context) {

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    // final mediaQueryData = MediaQuery.of(context);
    // print('test ${int.tryParse(roleId)}');
    // if( (int.tryParse(roleId))!=1){
    return roleId !=1 ?
    GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart:     _handlePanStart,
      child: PopupMenuButton<int>(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15.0))),
        itemBuilder: (context) => [
// -----> list of items in the PopupMenuButton <--------
          PopupMenuItem(
            value: 1,
            child: Row(
              children: [
                Icon(
                  Icons.mic,
                  color: CustomizedColors.primaryColor,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  AppStrings.item1,
                  style: TextStyle(
                      color: CustomizedColors.dropdowntxtcolor,
                      fontWeight: FontWeight.normal,
                      fontFamily: AppFonts.regular),
                ),
              ],
            ),
          ),
          PopupMenuItem(
// height: MediaQuery.of(context).size.height*0.07,
            value: 2,
            child: Row(
              children: [
                Icon(
                  Icons.attach_file_sharp,
                  color: CustomizedColors.primaryColor,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  AppStrings.item2,
                  style: TextStyle(
                      color: CustomizedColors.dropdowntxtcolor,
                      fontWeight: FontWeight.normal,
                      fontFamily: AppFonts.regular),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            // height: MediaQuery.of(context).size.height*0.07,
            value: 3,
            child: Row(
              children: [
                Icon(
                  Icons.logout,
                  color: CustomizedColors.primaryColor,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  AppStrings.item5,
                  style: TextStyle(
                      color: CustomizedColors.dropdowntxtcolor,
                      fontWeight: FontWeight.normal,
                      fontFamily: AppFonts.regular),
                ),
              ],
            ),
          ),
        ],
        icon: Icon(Icons.add),
// ----> it will display the PopupMenuButton based on the value <---
        offset: Offset(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height/2  * -0.40),


// ------> this method is called when particular item is selected <------
        onSelected: (value) async {
          if (value == 1) {
            RouteGenerator.navigatorKey.currentState.pushReplacementNamed(ManualDictations.routeName);
          } else if (value == 2) {
            RouteGenerator.navigatorKey.currentState.pushReplacementNamed(ExternalAttachments.routeName);
          } else if (value == 3) {
            SharedPreferences preferences =
            await SharedPreferences.getInstance();
            await preferences.clear();
            MySharedPreferences.instance.removeAll();
            RouteGenerator.navigatorKey.currentState.pushReplacementNamed(LoginScreen.routeName);
          }
        },
         initialValue: widget.initialValue,
      ),
    )
        :
    PopupMenuButton<int>(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0))),
      itemBuilder: (context) => [
// -----> list of items in the PopupMenuButton <--------
    
        PopupMenuItem(
          // height: MediaQuery.of(context).size.height*0.07,
          value: 1,
          child: Row(
            children: [
              Icon(
                Icons.attach_file_sharp,
                color: CustomizedColors.primaryColor,
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                AppStrings.item2,
                style: TextStyle(
                    color: CustomizedColors.dropdowntxtcolor,
                    fontWeight: FontWeight.normal,
                    fontFamily: AppFonts.regular),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          // height: MediaQuery.of(context).size.height*0.07,
          value: 3,
          child: Row(
            children: [
              Icon(
                Icons.logout,
                color: CustomizedColors.primaryColor,
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                AppStrings.item5,
                style: TextStyle(
                    color: CustomizedColors.dropdowntxtcolor,
                    fontWeight: FontWeight.normal,fontFamily: AppFonts.regular),
              ),
            ],
          ),
        ),


      ],
      icon: Icon(Icons.add),
// ----> it will display the PopupMenuButton based on the value <---

      offset: Offset(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height / 2 * -0.30),

// ------> this method is called when particular item is selected <------
      onSelected: (value) async {
        if (value == 1) {
          RouteGenerator.navigatorKey.currentState.pushReplacementNamed(ExternalAttachments.routeName);
        } else  if (value == 3) {
          SharedPreferences preferences =
          await SharedPreferences.getInstance();
          await preferences.clear();
          RouteGenerator.navigatorKey.currentState.pushReplacementNamed(LoginScreen.routeName);
        }
      },
       initialValue: widget.initialValue,
    );
  }
}
