class LeadModel {
  FieldsRecord? fieldsRecord;
  List<Followup>? followup;

  LeadModel({this.fieldsRecord, this.followup});

  LeadModel.fromJson(Map<String, dynamic> json) {
    fieldsRecord = json['fields_record'] != null
        ? FieldsRecord.fromJson(json['fields_record'])
        : null;
    if (json['followup'] != null) {
      followup = <Followup>[];
      json['followup'].forEach((v) {
        followup!.add(Followup.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (fieldsRecord != null) {
      data['fields_record'] = fieldsRecord!.toJson();
    }
    if (followup != null) {
      data['followup'] = followup!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class FieldsRecord {
  int? id;
  String? visitProofImage;
  String? capturedAt;
  String? businessName;
  String? mobileNo;
  String? phoneNo;
  String? emailAddress;
  String? address;
  int? areaId;
  String? visitType;
  String? visitDate;
  String? setupStatus;
  String? gpsPoints;
  String? personName;
  String? personDesignation;
  String? requirementStatus;
  List<dynamic>? requirementTypes;
  String? requirementSummary;
  String? expectedClosingTimeline;
  String? leadStatus;
  String? primaryNextAction;
  String? nextFollowup;
  String? leadSource;

  FieldsRecord({
    this.id,
    this.visitProofImage,
    this.capturedAt,
    this.businessName,
    this.mobileNo,
    this.phoneNo,
    this.emailAddress,
    this.address,
    this.areaId,
    this.visitType,
    this.visitDate,
    this.setupStatus,
    this.gpsPoints,
    this.personName,
    this.personDesignation,
    this.requirementStatus,
    this.requirementTypes,
    this.requirementSummary,
    this.expectedClosingTimeline,
    this.leadStatus,
    this.primaryNextAction,
    this.nextFollowup,
    this.leadSource,
  });

  FieldsRecord.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    visitProofImage = json['visit_proof_image'];
    capturedAt = json['captured_at'];
    businessName = json['business_name'];
    mobileNo = json['mobile_no'];
    phoneNo = json['phone_no'];
    emailAddress = json['email_address'];
    address = json['address'];
    areaId = json['area_id'];
    visitType = json['visit_type'];
    visitDate = json['visit_date']?.toString();
    setupStatus = json['setup_status'];
    gpsPoints = json['gps_points'];
    personName = json['person_name'];
    personDesignation = json['person_designation'];
    requirementStatus = json['requirement_status']?.toString();
    if (json['requirement_types'] != null) {
      requirementTypes = List<dynamic>.from(json['requirement_types']);
    }
    requirementSummary = json['requirement_summary']?.toString();
    expectedClosingTimeline = json['expected_closing_timeline'];
    leadStatus = json['lead_status'];
    primaryNextAction = json['primary_next_action'];
    nextFollowup = json['next_followup'];
    leadSource = json['lead_source'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['visit_proof_image'] = visitProofImage;
    data['captured_at'] = capturedAt;
    data['business_name'] = businessName;
    data['mobile_no'] = mobileNo;
    data['phone_no'] = phoneNo;
    data['email_address'] = emailAddress;
    data['address'] = address;
    data['area_id'] = areaId;
    data['visit_type'] = visitType;
    data['visit_date'] = visitDate;
    data['setup_status'] = setupStatus;
    data['gps_points'] = gpsPoints;
    data['person_name'] = personName;
    data['person_designation'] = personDesignation;
    data['requirement_status'] = requirementStatus;
    if (requirementTypes != null) {
      data['requirement_types'] = requirementTypes;
    }
    data['requirement_summary'] = requirementSummary;
    data['expected_closing_timeline'] = expectedClosingTimeline;
    data['lead_status'] = leadStatus;
    data['primary_next_action'] = primaryNextAction;
    data['next_followup'] = nextFollowup;
    data['lead_source'] = leadSource;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['description'] = description;
    data['time'] = time;
    return data;
  }
}
