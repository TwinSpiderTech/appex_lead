class NotificationModel {
  String? id;
  String title;
  String description;
  String time;
  String route;
  String contentType;
  String contentURL;
  String? type;

  NotificationModel({
    required this.title,
    required this.description,
    required this.contentType,
    required this.contentURL,
    required this.route,
    required this.time,
    this.id,
    this.type,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> data) {
    return NotificationModel(
      id: data['notification_id'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      contentType: data['contentType'] ?? '',
      contentURL: data['contentURL'] ?? '',
      route: data['route'] ?? '',
      time: data['time'] ?? '',
      type: data['type'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "notification_id": id,
      "title": title,
      "description": description,
      "contentType": contentType,
      "contentURL": contentURL,
      "time": time,
      "route": route,
      "type": type,
    };
  }
}
