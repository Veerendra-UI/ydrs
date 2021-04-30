import 'package:YOURDRS_FlutterAPP/common/app_colors.dart';
import 'package:YOURDRS_FlutterAPP/common/app_strings.dart';
import 'package:YOURDRS_FlutterAPP/common/app_toast_message.dart';
import 'package:YOURDRS_FlutterAPP/network/models/external_dictations/get_all_external_attachments_model.dart';
import 'package:YOURDRS_FlutterAPP/network/models/external_dictations/get_external_document_details.dart';
import 'package:YOURDRS_FlutterAPP/network/models/external_dictations/get_external_photos.dart';
import 'package:YOURDRS_FlutterAPP/network/services/external_attachment/all_external_attachment_service.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import '../../../../../common/app_text.dart';
import '../local/allattachment_screen.dart';
import 'externalattachment_server.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class GetMyAttachments extends StatefulWidget {
  static const String routeName = '/Externalattachmnet_server';
  @override
  State<StatefulWidget> createState() {
    return GetMyAttachmentsState();
  }
}

class GetMyAttachmentsState extends State<GetMyAttachments> {
  /// Declaring variables
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  AppToast appToast = AppToast();
  bool _hasMore;
  int _pageNumber;
  bool _error;
  bool _loading;
  final int _defaultDataPerPageCount = 20;
  List<ExternalDocumentList> _externalAttachments;
  int thresholdValue = 0;
  bool isInternetAvailable = true;
  int externalAttachmentId;
  String imageName;
  String displayFileName;
  String attachmentName;
  bool hasData = false;
  List imageList = [];

  AllMyExternalAttachments apiServices = AllMyExternalAttachments();
  GetExternalDocumentDetailsService apiService2=GetExternalDocumentDetailsService();
  GetExternalPhotosService apiService3=GetExternalPhotosService();

//------------------external attachment details api
 // GetExternalDocumentDetails getExternalDocumentDetails;

//---------external attachment photos api
  //GetExternalPhotos getExternalPhotos;


  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    GetAllExternalAttachments allMyExternalAttachments =
    await apiServices.getMyAllExternalAttachemnts(_pageNumber);
    if (!mounted) return;
    setState(() {
      _hasMore = allMyExternalAttachments.externalDocumentList?.length ==
          _defaultDataPerPageCount;
      _loading = false;
      _pageNumber = _pageNumber + 1;
      _externalAttachments.addAll(
          allMyExternalAttachments?.externalDocumentList);
    });
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

//---------------------------Check if internet connected or not
  void checkInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      setState(() {
        isInternetAvailable = true;
      });
    } else {
      setState(() {
        isInternetAvailable = false;
      });
      appToast.showToast(AppStrings.no_internet);
    }
  }

//-----------------------initState
  @override
  void initState() {
    super.initState();
    _hasMore = true;
    _pageNumber = 1;
    _error = false;
    _loading = true;
    _externalAttachments = [];
    checkInternet();
  }

  @override
  Widget build(BuildContext context) {
    return isInternetAvailable
        ? Container(
      child: getBody(),
    )
        : Container(
      child: Allattachmentlocal(),
    );
  }

  Widget getBody() {
    if (_externalAttachments?.isEmpty ?? false) {
      if (_loading) {
        return Center(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: CircularProgressIndicator(valueColor:
              AlwaysStoppedAnimation(
                  CustomizedColors
                      .primaryColor),),
            ));
      } else if (_error) {
        return Center(
            child: InkWell(
              onTap: () {
                setState(() {
                  _loading = true;
                  _error = false;
                  didChangeDependencies();
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                    AppStrings.errorloadingphotos_text,style: TextStyle(fontFamily: AppFonts.regular,),),
              ),
            ));
      }
    } else {
      return Container(
        child: ListView.builder(
            itemCount: _externalAttachments.length + (_hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _externalAttachments.length - thresholdValue) {
                didChangeDependencies();
              }
              if (index == _externalAttachments.length) {
                if (_error) {
                  return Center(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _loading = true;
                            _error = false;
                            didChangeDependencies();
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child:
                          Text(AppStrings.errorloadingphotos_text,style: TextStyle(fontFamily: AppFonts.regular,),),
                        ),
                      ));
                } else {
                  return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: CircularProgressIndicator(valueColor:
                        AlwaysStoppedAnimation(
                            CustomizedColors
                                .primaryColor),),
                      ));
                }
              }
              final ExternalDocumentList externalDocuments = _externalAttachments[index];
              // print("all data loaded successfully 7");
              return AnimationLimiter(
                  child: Column(
                  children: [
                  AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 10),
              child: FadeInAnimation(
              child: SlideAnimation(
              horizontalOffset: MediaQuery.of(context).size.width / 2,
              child: InkWell(
                onTap: () async {

                  showLoadingDialog(context, _keyLoader);

                  setState(() {
                    //-----------------------------external attachment details api
                    externalAttachmentId =
                        externalDocuments.externalAttachmentId;
                    externalAttachmentId =
                        externalDocuments.externalAttachmentId;

                    displayFileName = externalDocuments.displayFileName;
                  });

                  //--------------------------external attachment details api

                  GetExternalDocumentDetails getExternalDocumentDetails = await apiService2.getExternalDocumentDetails(externalAttachmentId);

                  for (var i = 0; i < getExternalDocumentDetails.attachments.length; i++) {
                    getExternalDocumentDetails.attachments.length != 0
                        ? attachmentName =
                        getExternalDocumentDetails.attachments[i].name
                        : attachmentName = "";

                    getExternalDocumentDetails.attachments.length != 0
                        ? imageName =
                        getExternalDocumentDetails.attachments[i].name
                        : imageName = "";

                    imageList.add({
                      "image_path": imageName
                    });
                  }
////---------------------------external attachment photos api
                  GetExternalPhotos getExternalPhotos = await apiService3.getExternalPhotos(imageName);

                  Navigator.of(_keyLoader.currentContext, rootNavigator: true)
                      .pop();
                    // RouteGenerator.navigatorKey.currentState
                    //     .pushNamedAndRemoveUntil(ExternalAttachments.routeName,
                    //       (Route<dynamic> route) => false,);

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            Externalattachmnet_server(
                              displayfilename: displayFileName ?? "",
                              externalAttachmentId: externalAttachmentId ?? "",
                              Practicename:
                              getExternalDocumentDetails.practiceName ?? "",
                              Locationname:
                              getExternalDocumentDetails.locationName ?? "",
                              Externaldocumenttypename:
                              getExternalDocumentDetails
                                  .externalDocumentTypeName ??
                                  "",
                              Providername:
                              getExternalDocumentDetails.providerName ?? "",
                              Patientfirstname:
                              getExternalDocumentDetails.patientFirstName ??
                                  "",
                              Dob: getExternalDocumentDetails.dob ?? "",
                              isemergencyAddon:
                              getExternalDocumentDetails.isEmergencyAddOn ??
                                  "",
                              Description:
                              getExternalDocumentDetails.description ?? "",
                              attachmentname: attachmentName,
                              filename: getExternalPhotos.fileName ?? "",
                            )),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.all(3),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 15,
                    shadowColor: CustomizedColors.accentColor,
                    child: ListTile(
                      leading: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(padding: new EdgeInsets.all(3.0)),
                          Container(
                            width: 320,
                            child: Text(
                              externalDocuments.displayFileName,
                              style: TextStyle( fontFamily: AppFonts.regular,
                                  fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      trailing: Card(
                        shadowColor: CustomizedColors.accentColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 10,
                        color: Colors.white,
                        child: IconButton(
                          icon: Icon(
                            Icons.cloud_done,
                            size: 34,
                            color: CustomizedColors.primaryColor,
                          ),
                          onPressed: () {


                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ))))]));
            }),
      );
    }
    return Container();
  }
}

