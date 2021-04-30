import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:YOURDRS_FlutterAPP/common/app_colors.dart';
import 'package:YOURDRS_FlutterAPP/common/app_strings.dart';
import 'package:YOURDRS_FlutterAPP/common/app_text.dart';
import 'package:YOURDRS_FlutterAPP/common/app_toast_message.dart';
import 'package:YOURDRS_FlutterAPP/network/models/dictations/allImages_models.dart';
import 'package:YOURDRS_FlutterAPP/network/models/dictations/imageFilename_model.dart';
import 'package:YOURDRS_FlutterAPP/network/services/dictation/getAllImages_service.dart';
import 'package:YOURDRS_FlutterAPP/network/services/dictation/getFilename_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class ViewImages extends StatefulWidget {
  static const String routeName = "/ViewImages";

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ViewImagesState();
  }
}

class ViewImagesState extends State<ViewImages> {
  final GetImage getImage = GetImage();
  List imagesList = [];
  var decoded;
  int gIndex;

  @override
  Future<void> didChangeDependencies() async {
    final List image = ModalRoute.of(this.context).settings.arguments;
    for (int i = 0; i < image.length; i++) {
      GetFileNames getFileNames = await getImage.getImageFile(image[i]);
      if (getFileNames != null) {
        if (getFileNames.content != null && getFileNames.content.isNotEmpty) {
          Uint8List decoded = base64.decode(getFileNames.content);
          imagesList.add(decoded);
          setState(() {});
        }
      }
    }
    super.didChangeDependencies();
  }


  Widget _loader(String msg) {
    return Center(
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(
          width: 25,
        ),
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(CustomizedColors.primaryColor),
        ),
        SizedBox(
          width: 35,
        ),
        Text(
          msg,
          style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: AppFonts.regular),
        )
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: Text(
            AppStrings.uploadedImages,
            style: TextStyle(fontFamily: AppFonts.regular),
          ),
          backgroundColor: CustomizedColors.primaryColor,
        ),
        body: Column(children: [
          Container(
              margin: const EdgeInsets.fromLTRB(10, 10, 0, 0),
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(
                  color: CustomizedColors.homeSubtitleColor,
                ),
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(0),
                    bottomLeft: Radius.circular(10),
                    topLeft: Radius.circular(10),
                    bottomRight: Radius.zero),
              ),
              child: imagesList == null || imagesList.isEmpty
                  ? _loader(AppStrings.loading)
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: imagesList.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          child: Container(
                              margin: const EdgeInsets.all(10.0),
                              height: 130,
                              width: 150,
                              child: Image.memory(
                                imagesList[index],
                                fit: BoxFit.cover,
                              )),
                          onTap: () {
                            setState(() {
                              gIndex = index;
                            });
                          },
                        );
                      }

                      //  },
                      )),
          SizedBox(
            height: 20,
          ),
          Expanded(
            child: Container(
                margin: const EdgeInsets.all(30),
                child: gIndex == null
                    ? Container()
                    : Image.memory(
                        imagesList[gIndex],
                        frameBuilder:
                            (context, child, frame, wasSynchronouslyLoaded) {
                          return wasSynchronouslyLoaded ? child : _loader('');
                        },
                        fit: BoxFit.contain,
                      )),
          )
        ]));
  }
}
