class LeadModel {
  FieldsRecord? fieldsRecord;
  List<Followup>? followup;

  LeadModel({this.fieldsRecord, this.followup});

  LeadModel.fromJson(Map<String, dynamic> json) {
    fieldsRecord = json['fields_record'] != null
        ? new FieldsRecord.fromJson(json['fields_record'])
        : null;
    if (json['followup'] != null) {
      followup = <Followup>[];
      json['followup'].forEach((v) {
        followup!.add(new Followup.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.fieldsRecord != null) {
      data['fields_record'] = this.fieldsRecord!.toJson();
    }
    if (this.followup != null) {
      data['followup'] = this.followup!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class FieldsRecord {
  String? visitProofImage;
  String? businessName;
  String? mobileNo;
  int? areaId;
  String? setupStatus;
  String? gpsPoints;
  String? personName;
  String? personDesignation;
  String? phoneNo;
  String? emailAddress;
  String? address;
  String? expectedClosingTimeline;
  String? leadStatus;

  FieldsRecord({
    this.visitProofImage,
    this.businessName,
    this.mobileNo,
    this.areaId,
    this.setupStatus,
    this.gpsPoints,
    this.personName,
    this.personDesignation,
    this.phoneNo,
    this.emailAddress,
    this.address,
    this.expectedClosingTimeline,
    this.leadStatus,
  });

  FieldsRecord.fromJson(Map<String, dynamic> json) {
    visitProofImage = json['visit_proof_image'];
    businessName = json['business_name'];
    mobileNo = json['mobile_no'];
    areaId = json['area_id'];
    setupStatus = json['setup_status'];
    gpsPoints = json['gps_points'];
    personName = json['person_name'];
    personDesignation = json['person_designation'];
    phoneNo = json['phone_no'];
    emailAddress = json['email_address'];
    address = json['address'];
    expectedClosingTimeline = json['expected_closing_timeline'];
    leadStatus = json['lead_status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['visit_proof_image'] = this.visitProofImage;
    data['business_name'] = this.businessName;
    data['mobile_no'] = this.mobileNo;
    data['area_id'] = this.areaId;
    data['setup_status'] = this.setupStatus;
    data['gps_points'] = this.gpsPoints;
    data['person_name'] = this.personName;
    data['person_designation'] = this.personDesignation;
    data['phone_no'] = this.phoneNo;
    data['email_address'] = this.emailAddress;
    data['address'] = this.address;
    data['expected_closing_timeline'] = this.expectedClosingTimeline;
    data['lead_status'] = this.leadStatus;
    return data;
  }
}

class Followup {
  String? title;
  String? description;
  String? time;

  Followup({this.title, this.description, this.time});

  Followup.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    description = json['description'];
    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['description'] = this.description;
    data['time'] = this.time;
    return data;
  }
}
