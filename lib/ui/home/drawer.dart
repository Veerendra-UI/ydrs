import 'package:YOURDRS_FlutterAPP/common/app_colors.dart';
import 'package:YOURDRS_FlutterAPP/common/app_strings.dart';
import 'package:YOURDRS_FlutterAPP/common/app_text.dart';
import 'package:YOURDRS_FlutterAPP/network/repo/local/preference/local_storage.dart';
import 'package:YOURDRS_FlutterAPP/ui/login/login_screen/loginscreen.dart';
import 'package:YOURDRS_FlutterAPP/utils/route_generator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DrawerScreen extends StatefulWidget {
  static const String routeName = '/DrawerScreen';

  @override
  State<StatefulWidget> createState() {
    return DrawerState();
  }
}

class DrawerState extends State<DrawerScreen> {
  var displayName = "";
  var profilePic = "";
  var userEmail = "";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      displayName = (prefs.getString(Keys.displayName) ?? '');
      profilePic = (prefs.getString(Keys.displayPic) ?? '');
      userEmail = (prefs.getString(Keys.userEmail) ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Container(
      width: width * 0.60,
      child: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: CustomizedColors.clrCyanBlueColor,
              ),
              accountName: Text(
                displayName ?? "", overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: CustomizedColors.textColor,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,fontFamily: AppFonts.regular),
              ),
              accountEmail: Text(userEmail ?? "",style: TextStyle(fontFamily: AppFonts.regular),),
              currentAccountPicture: CircleAvatar(
                child: ClipOval(
                  child: profilePic == "" ? Card(
                          elevation: 1,
                          child: Image.asset(
                            AppStrings.defaultimage,
                            width: 75,
                            height: 75,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.network(
                          profilePic,
                          width: 75,
                          height: 75,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.account_circle,
                color: CustomizedColors.clrCyanBlueColor,
              ),
              title: Text(AppStrings.txt1,style: TextStyle(fontFamily: AppFonts.regular),),
            ),
            ListTile(
              leading: Icon(
                Icons.logout,
                color: CustomizedColors.clrCyanBlueColor,
              ),
              title: Text(AppStrings.txt2,style: TextStyle(fontFamily: AppFonts.regular),),
              onTap: () async{
                SharedPreferences preferences =
                    await SharedPreferences.getInstance();
                await preferences.clear();
                RouteGenerator.navigatorKey.currentState
                    .pushReplacementNamed(LoginScreen.routeName);
              },
            ),
          ],
        ),
      ),
    );
  }
}
