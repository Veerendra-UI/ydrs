import 'dart:io';

import 'package:YOURDRS_FlutterAPP/common/app_colors.dart';
import 'package:YOURDRS_FlutterAPP/common/app_strings.dart';

import 'package:YOURDRS_FlutterAPP/network/models/external_dictations/get_external_document_details.dart';
import 'package:YOURDRS_FlutterAPP/network/models/external_dictations/get_external_photos.dart';
import 'package:YOURDRS_FlutterAPP/network/services/external_attachment/all_external_attachment_service.dart';
import 'package:YOURDRS_FlutterAPP/utils/route_generator.dart';
import 'package:flutter/material.dart';

import '../../../../../common/app_text.dart';
import '../../../externalattchment_main.dart';
import '../external_component.dart';

class Externalattachmnet_server extends StatefulWidget {
  static const String routeName = '/ExternalAttachments';
  var displayfilename;
  var Practicename;
  var Locationname;
  var Externaldocumenttypename;
  var Providername;
  var Patientfirstname;
  var Dob;
  var isemergencyAddon;
  var Description;
  var filename;
  var attachmentname;
  var externalAttachmentId;
  Externalattachmnet_server({
    this.displayfilename,
    this.Practicename,
    this.Locationname,
    this.Externaldocumenttypename,
    this.Providername,
    this.Patientfirstname,
    this.Dob,
    this.isemergencyAddon,
    this.Description,
    this.filename,
    this.attachmentname,
    this.externalAttachmentId
  });

  @override
  _Externalattachmnet_serverState createState() => _Externalattachmnet_serverState();
}



class _Externalattachmnet_serverState extends State<Externalattachmnet_server> {

  //  GetExternalDocumentDetails getExternalDocumentDetails;

    // GetExternalPhotos getExternalPhotos;

    AllMyExternalAttachments apiServices = AllMyExternalAttachments();
    GetExternalDocumentDetailsService apiService2=GetExternalDocumentDetailsService();
    GetExternalPhotosService apiService3=GetExternalPhotosService();

  // ignore: unused_field
  List<Attachments> _list = [];
    final GlobalKey<State> _keyLoader = new GlobalKey<State>();
 @override
 void initState() {
    // TODO: implement initState
    super.initState();
  }
    //--------------------Show process indicator
    Future<void> showLoadingDialog(BuildContext context, GlobalKey key) async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new WillPopScope(
            onWillPop: () async => false,
            child: SimpleDialog(
              key: key,
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
                        AppStrings.loading,
                        style: TextStyle( fontFamily: AppFonts.regular,
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        },
      );
    }
    @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    GetExternalDocumentDetails photoListArray = await apiService2.getExternalDocumentDetails(widget.externalAttachmentId);
    _list = photoListArray.attachments;
    if (mounted) {
      setState(() {});
    }
  }
  //GetExternalPhotos getExternalPhotos;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: CustomizedColors.ExtAppbarColor,
          toolbarHeight: 70,
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: ()
              {
                RouteGenerator.navigatorKey.currentState
                    .pushReplacementNamed(Externalattachmnet_server.routeName);
              },
          ),
          title: Container(
              child: Text(
            widget.displayfilename ?? "",
            style: TextStyle(fontSize: 18,fontFamily: AppFonts.regular,),
            overflow: TextOverflow.fade,
          )),
          centerTitle: true,
        ),
        body: ListView(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                AppStrings.casedetails_text,
                style: TextStyle( fontFamily: AppFonts.regular,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: CustomizedColors.customeColor),
              ),
            ),
            CustomTile(text1: AppStrings.practice_text, text2: widget.Practicename ?? ""),
            Divider(
              color: CustomizedColors.primaryColor,
              height: 0,
            ),
            CustomTile(text1: AppStrings.location_text, text2: widget.Locationname ?? ""),
            Divider(
              color: CustomizedColors.primaryColor,
              height: 0,
            ),
            CustomTile(
                text1: AppStrings.doc_text,
                text2: widget.Externaldocumenttypename ?? ""),
            Divider(
              color: CustomizedColors.primaryColor,
              height: 0,
            ),
            CustomTile(text1: AppStrings.provider_text, text2: widget.Providername ?? ""),
            Divider(
              color: CustomizedColors.primaryColor,
              height: 0,
              thickness: 0.60,
            ),
            CustomTile(text1: AppStrings.name_text, text2: widget.Patientfirstname ?? ""),
            Divider(
              color: CustomizedColors.primaryColor,
              height: 0,
              thickness: 0.60,
            ),
            CustomTile(text1: AppStrings.dob_text, text2: widget.Dob ?? ""),
            Divider(
              color: CustomizedColors.primaryColor,
              height: 0,
            ),
            CustomTile(
                text1: AppStrings.isemergency_text,
                text2: widget.isemergencyAddon.toString()),
            Divider(
              color: CustomizedColors.primaryColor,
              height: 0,
            ),
            CustomTile(text1: AppStrings.description_text, text2: widget.Description ?? ""),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                AppStrings.uploadedattachments_text,
                style: TextStyle( fontFamily: AppFonts.regular,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: CustomizedColors.customeColor),
              ),
            ),
             Center(
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 280,
                  child: _list!=null || _list.isNotEmpty ?
                            ListView.builder(
                              primary: false,
                              scrollDirection: Axis.vertical,
                              itemCount: _list.length,
                              itemBuilder: (context, index) {
                                Attachments item = _list[index];
                                return Card(
                                  child: ListTile(
                                      leading: Container(
                                        height: 100,
                                        width: 280,
                                        child: Center(child:Text(item.name,style: TextStyle(fontFamily: AppFonts.regular,),)),
                                      ),
                                      trailing: FlatButton(
                                        onPressed: () async{
                                          showLoadingDialog(context, _keyLoader);
                                      //-----------------get external attachmens photos api
                                          GetExternalPhotos   getExternalPhotos = await apiService3.getExternalPhotos(item.name);
                                          Navigator.of(_keyLoader.currentContext, rootNavigator: true)
                                              .pop();
                                          showDialog(
                                            context: context,
                                            builder: (_) => Dialog(
                                              child:Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                    0.7,
                                                child: Image.network(getExternalPhotos.fileName,fit: BoxFit.fill,
                                                  loadingBuilder:(BuildContext context, Widget child,ImageChunkEvent loadingProgress) {
                                                    if (loadingProgress == null) return child;
                                                    return Center(
                                                      child: CircularProgressIndicator(
                                                        valueColor:
                                                        AlwaysStoppedAnimation(CustomizedColors.primaryColor),
                                                       // backgroundColor: CustomizedColors.primaryColor,
                                                        value: loadingProgress.expectedTotalBytes != null ?
                                                        loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                                                            : null,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          );

                                        },
                                        child: Icon(Icons.remove_red_eye),
                                      )),
                                );
                              },
                            ): Container(
                    child: Center(
                      child: Text(AppStrings.noimagefound_text,style: TextStyle(color: CustomizedColors.actionsheettext,fontFamily: AppFonts.regular,),),
                          ),
                         )
                        )
                      ),
                        ]
                )
        ]));
  }
}
