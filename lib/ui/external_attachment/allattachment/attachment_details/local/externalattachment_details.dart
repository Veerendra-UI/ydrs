import 'dart:io';
import 'package:YOURDRS_FlutterAPP/common/app_colors.dart';
import 'package:YOURDRS_FlutterAPP/common/app_strings.dart';
import 'package:YOURDRS_FlutterAPP/network/models/manual_dictations/photo_list.dart';
import 'package:YOURDRS_FlutterAPP/utils/route_generator.dart';
import 'package:flutter/services.dart';
import 'package:YOURDRS_FlutterAPP/helper/db_helper.dart';
import 'package:flutter/material.dart';
import '../../../../../common/app_text.dart';
import '../external_component.dart';
class Externalattachment_data extends StatefulWidget {
  static const String routeName = '/ExternalAttachments';
  var displayfilename;
  var practicename;
  var locationname;
  var externaldocumenttype;
  var providername;
  var patientfirstname;
  var patientdob;
  var isemergencyaddon;
  var description;
  var attachmentId;
  var attachmnetname;
  var physicalImage; //image fethcing variable
  var uploadedtoserver;
  Externalattachment_data(
      {this.attachmentId,
      this.displayfilename,
      this.practicename,
      this.locationname,
      this.externaldocumenttype,
      this.providername,
      this.patientfirstname,
      this.patientdob,
      this.isemergencyaddon,
      this.description,
      this.physicalImage,
      this.attachmnetname,
      this.uploadedtoserver
      });

  @override
  _Externalattachment_dataState createState() => _Externalattachment_dataState();
}
class _Externalattachment_dataState extends State<Externalattachment_data> {
  bool isLoadingPath = false;

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
                    .pushReplacementNamed(Externalattachment_data.routeName);
              },

              // );
          ),
          title: Container(
              child: Text(
            widget.displayfilename,
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
                    color: Colors.grey),
              ),
            ),
            CustomTile(text1: AppStrings.practice_text, text2: widget.practicename ?? 'Practice name NA'),
            Divider(
              color: Colors.blue,
              height: 0,
            ),
            CustomTile(
                text1: AppStrings.location_text,
                text2: widget.locationname ?? 'Location name NA'),
            Divider(
              color: Colors.blue,
              height: 0,
            ),
            CustomTile(text1: AppStrings.doc_text, text2: widget.externaldocumenttype?? 'ExternalDocumentType NA'),
            Divider(
              color: Colors.blue,
              height: 0,
            ),
            CustomTile(
                text1: AppStrings.provider_text,
                text2: widget.providername ?? 'Provider name NA'),
            Divider(
              color: Colors.blue,
              height: 0,
              thickness: 0.60,
            ),
            CustomTile(text1: AppStrings.name_text, text2: widget.patientfirstname??null),
            Divider(
              color: Colors.blue,
              height: 0,
              thickness: 0.60,
            ),
            CustomTile(text1: AppStrings.dob_text, text2: widget.patientdob??null),
            Divider(
              color: Colors.blue,
              height: 0,
            ),
            CustomTile(
                text1: AppStrings.isemergency_text,
                text2: widget.isemergencyaddon.toString()?? 'isemergencyaddOn NA'),
            Divider(
              color: Colors.blue,
              height: 0,
            ),
            CustomTile(text1: AppStrings.description_text, text2: widget.description?? null),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                AppStrings.uploadedattachments_text,
                style: TextStyle( fontFamily: AppFonts.regular,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey),
              ),
            ),
            //--------------fetching images from local data base
            Container(
              child: Container(
                  //  color: Colors.green,
                  width: MediaQuery.of(context).size.width,
                  height: 280,
                  // color: Colors.yellow,
                  child: FutureBuilder<List<PhotoList>>(
                      future: DatabaseHelper.db.getAttachmentImages(widget.attachmentId),
                      //future: DatabaseHelper.db.getAttachmentImages(widget.id),
                      builder: (BuildContext context,
                          AsyncSnapshot<List<PhotoList>> snapshot) {
                        try {
                          if (snapshot.hasData) {
                            return ListView.builder(
                              primary: false,
                              scrollDirection: Axis.vertical,
                              itemCount: snapshot.data.length,
                              itemBuilder: (context, index) {
                                //print("Id..../////${widget.id}");
                                PhotoList item = snapshot.data[index];
                                return Card(
                                  //color: Colors.green,
                                  child: ListTile(
                                      leading: Container(
                                        height: 100,
                                        width: 280,
                                        child: Text(item.attachmentname,style: TextStyle(fontFamily: AppFonts.regular,),),
                                      ),
                                      trailing: FlatButton(

                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (_) => Dialog(
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.7,
                                                decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                        image: FileImage(new File(item.physicalfilename)),
                                                        fit: BoxFit.cover)),
                                              ),
                                            ),
                                          );
                                        },
                                        child: Icon(Icons.remove_red_eye),
                                      )),
                                );
                              },
                            );
                          }
                        } on PlatformException catch (e) {}
                        return Container();
                      })),
            )
          ])
        ]));
  }
}
