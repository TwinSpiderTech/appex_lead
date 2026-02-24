import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class NotificationStyle {
  final dynamic icon;
  final Color color;

  NotificationStyle({required this.icon, required this.color});
}

class NotificationHelper {
  static NotificationStyle getNotificationStyle(String? type) {
    switch (type?.toLowerCase()) {
      case 'order':
        return NotificationStyle(
          icon: HugeIcons.strokeRoundedTick01,
          color: Colors.green,
        );
      case 'payment':
        return NotificationStyle(
          icon: HugeIcons.strokeRoundedMoney03,
          color: Colors.blue,
        );
      case 'alert':
        return NotificationStyle(
          icon: HugeIcons.strokeRoundedAlert02,
          color: Colors.red,
        );
      case 'delivery':
        return NotificationStyle(
          icon: HugeIcons.strokeRoundedDeliveryTruck01,
          color: Colors.orange,
        );
      case 'invoice':
        return NotificationStyle(
          icon: HugeIcons.strokeRoundedFile02,
          color: Colors.purple,
        );
      default:
        return NotificationStyle(
          icon: HugeIcons.strokeRoundedNotification01,
          color: Colors.blueGrey,
        );
    }
  }
}
