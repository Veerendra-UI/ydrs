class DictationTypeSurgery {
  String dictationtypeid;
  String dictationtype;

  DictationTypeSurgery({
    this.dictationtypeid,
    this.dictationtype,
  });

  factory DictationTypeSurgery.fromJson(Map<String, dynamic> json) =>
      DictationTypeSurgery(
        dictationtypeid:
            json["dictationtypeid"] == null ? null : json["dictationtypeid"],
        dictationtype:
            json["dictationtype"] == null ? null : json["dictationtype"],
      );

  Map<String, dynamic> toJson() => {
        "dictationtypeid": dictationtypeid == null ? null : dictationtypeid,
        "dictationtype": dictationtype == null ? null : dictationtype,
      };

  @override
  String toString() {
    return 'DictationTypeSurgery{dictationtype: ${dictationtype}';
  }
}
