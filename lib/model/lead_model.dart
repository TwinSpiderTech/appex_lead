class LeadModel {
  Map<String, dynamic>? fieldsRecord;
  List<Followup>? followup;

  LeadModel({this.fieldsRecord, this.followup});

  LeadModel.fromJson(Map<String, dynamic> json) {
    fieldsRecord = json['fields_record'] != null
        ? Map<String, dynamic>.from(json['fields_record'])
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
      data['fields_record'] = fieldsRecord;
    }
    if (followup != null) {
      data['followup'] = followup!.map((v) => v.toJson()).toList();
    }
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
