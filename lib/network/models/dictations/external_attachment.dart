class ExternalAttachment {
  int id;
  int externalattachmentid;
  int memberid;
  int StatusId;
  bool uploadedtoserver;
  int statusid;
  String createddate;
  String displayfilename;
  String filename; //name of the audio file
  String patientfirstname;
  String patientlastname;
  String patientdob;
  String dos;
  String externaldocumenttype;
  int practiceid;
  String practicename;
  int locationid;
  String locationname;
  int providerid;
  String providername;
  int appointmenttypeid;
  String appointmenttype;
  int isemergencyaddon; //pending
  int externaldocumenttypeid;
  String description;

  ExternalAttachment(
      {this.id,
      this.externalattachmentid,
      this.memberid,
      this.statusid,
      this.uploadedtoserver,
      this.createddate,
      this.displayfilename,
      this.filename,
      this.patientfirstname,
      this.patientlastname,
      this.patientdob,
      this.dos,
      this.externaldocumenttype,
      this.practiceid,
      this.practicename,
      this.locationid,
      this.locationname,
      this.providerid,
      this.providername,
      this.appointmenttypeid,
      this.appointmenttype,
      this.isemergencyaddon, //pending
      this.externaldocumenttypeid,
      this.description});
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'externalAttachmentId': externalattachmentid,
      'memberId': memberid,
      'statusId': statusid,
      'uploadedtoserver': uploadedtoserver,
      'createddate': createddate,
      'displayfilename': displayfilename,
      'filename': filename,
      'patientfirstname': patientfirstname,
      'patientlastname': patientlastname,
      'patientdob': patientdob,
      'dos': dos,
      'practiceid': practiceid,
      'practicename': practicename, //
      'locationid': locationid,
      'locationname': locationname,
      'providerid': providerid,
      'providername': providername,
      'appointmenttypeid': appointmenttypeid,
      'appointmenttype': appointmenttype,
      'isemergencyaddon': isemergencyaddon, //pending
      'externaldocumenttype': externaldocumenttype,
      'externaldocumenttypeid': externaldocumenttypeid,
      'description': description,
    };
    return map;
  }

  ExternalAttachment.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    memberid = map['memberid'];
    statusid = map['statusid'];
    uploadedtoserver = map['uploadedtoserver'];
    createddate = map['createddate'];
    displayfilename = map['displayfilename'];
    filename = map['filename'];
    patientfirstname = map['patientfirstname'];
    patientlastname = map['patientlastname'];
    patientdob = map['patientdob'];
    dos = map['dos'];
    practiceid = map['practiceid'];
    practicename = map['practicename'];
    locationid = map['locationid'];
    locationname = map['locationname'];
    providerid = map['providerid'];
    providername = map['providername'];
    appointmenttypeid = map['appointmenttypeid'];
    appointmenttype = map['appointmenttype'];
    externaldocumenttype = map['externaldocumenttype']; //changing
    isemergencyaddon = map['isEmergencyAddOn']; //pending
    externaldocumenttypeid = map['externalDocumentTypeId'];
    description = map['description'];
  }

  @override
  String toString() {
    return toMap().toString();
  }
}
