import 'package:YOURDRS_FlutterAPP/common/app_colors.dart';
import 'package:YOURDRS_FlutterAPP/common/app_text.dart';
import 'package:YOURDRS_FlutterAPP/cubit/document_type_cubit.dart';
import 'package:YOURDRS_FlutterAPP/network/services/schedules/appointment_service.dart';
import 'package:YOURDRS_FlutterAPP/widget/dropdowns/searchable_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:YOURDRS_FlutterAPP/network/models/manual_dictations/document_type.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DocumentDropDown extends StatefulWidget {
  final onTapDocument;
  String selectedDocumentType;
  DocumentDropDown({@required this.onTapDocument, this.selectedDocumentType});
  @override
  _DocumentState createState() => _DocumentState();
}

class _DocumentState extends State<DocumentDropDown>
    with AutomaticKeepAliveClientMixin {
  bool asTabs = false;
  var _currSelectedDoc;
  //------------------service
  Services apiServices = Services();
  ExternalDocumentTypesList externalDocumentTypesList;
  //List<LocationList> _list=[];
  List data = List();

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    BlocProvider.of<DocumentTypeCubit>(context).getRecordsDocumentType();
//_currentSelectedValue=data;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _currSelectedDoc = widget.selectedDocumentType;
  }

  List<Widget> get appBarActions {
    return ([
      Center(child: Text("Tabs:",style: TextStyle(fontFamily: AppFonts.regular,fontSize: 12),)),
      Switch(
        activeColor: Colors.white,
        value: asTabs,
        onChanged: (value) {
          setState(() {
            asTabs = value;
          });
        },
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DocumentTypeCubit, DocumentTypeCubitState>(
      listener: (context, state) {
        if (state.errorMsg != null) {
          print(state.errorMsg);
        }
        if (state.documentType != null) {
          data = state.documentType;
        }
      },
      child: BlocBuilder<DocumentTypeCubit, DocumentTypeCubitState>(
        builder: (context, state) {
          return Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: CustomizedColors.accentColor,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            padding: const EdgeInsets.all(5),
            width: MediaQuery
                .of(context)
                .size
                .width * 0.95,
            child: SearchableDropdown.single(
              displayClearIcon: false,
              //validator: (value) => value == null ? 'Cannot be empty' : null,
              hint: Text('Document Type',
                style: TextStyle(fontFamily: AppFonts.regular, fontSize: 14),),

              items: data.map((item) {
                return DropdownMenuItem<ExternalDocumentTypesList>(
                    child: Text(
                      item.externalDocumentTypeName,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontFamily: AppFonts.regular,
                          fontSize: 12),
                    ),
                    value: item);
              }).toList(),
              isExpanded: true,
              underline: Padding(
                padding: EdgeInsets.all(1),
              ),
              value: externalDocumentTypesList,
              searchHint: Text('Select ', style: TextStyle(fontSize: 14,
                  fontFamily: AppFonts.regular,
                  fontWeight: FontWeight.bold)),
              onChanged: (value) {
                setState(() {
                  externalDocumentTypesList = value;
                  widget.onTapDocument(value);
                });
              },
            ),
          );
        },
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
