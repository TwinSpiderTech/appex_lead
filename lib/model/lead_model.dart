class LeadModel {
  Map<String, dynamic>? fieldsRecord;
  List<Followup>? followup;

  LeadModel({this.fieldsRecord, this.followup});

  LeadModel.fromJson(Map<String, dynamic> json) {
    fieldsRecord = json['fields_record'] != null
        ? Map<String, dynamic>.from(json['fields_record'])
        : null;
    if (json['followup_history'] != null) {
      followup = <Followup>[];
      json['followup_history'].forEach((v) {
        followup!.add(Followup.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (fieldsRecord != null) {
      data['fields_record'] = fieldsRecord;
    }
    if (followup != null) {
      data['followup_history'] = followup!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Followup {
  String? title;
  String? type;
  String? description;
  String? time;
  Map<String, dynamic>? rawData;

  Followup({this.title, this.description, this.time, this.rawData});

  Followup.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    description = json['description'];
    type = json['interaction_type'];
    time = json['time'];
    rawData = json;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['description'] = description;
    data['interaction_type'] = type;
    data['time'] = time;
    if (rawData != null) {
      data.addAll(rawData!);
    }
    return data;
  }
}
