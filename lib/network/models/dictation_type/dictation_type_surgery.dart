class DictationTypeSurgery {
  DictationTypeSurgery({
    this.dictationtypeid,
    this.dictationtype,
    this.appointmentType,
  });

  String dictationtypeid;
  String dictationtype;
  String appointmentType;

  factory DictationTypeSurgery.fromJson(Map<String, dynamic> json) =>
      DictationTypeSurgery(
        dictationtypeid:
            json["dictationtypeid"] == null ? null : json["dictationtypeid"],
        dictationtype:
            json["dictationtype"] == null ? null : json["dictationtype"],
        appointmentType:
            json["appointmentType"] == null ? null : json["appointmentType"],
      );

  Map<String, dynamic> toJson() => {
        "dictationtypeid": dictationtypeid == null ? null : dictationtypeid,
        "dictationtype": dictationtype == null ? null : dictationtype,
        "appointmentType": appointmentType == null ? null : appointmentType,
      };

  @override
  String toString() {
    return 'DictationTypeSurgery{dictationtype: ${dictationtype}, dictationTypeId: ${dictationtypeid}';
  }
}
