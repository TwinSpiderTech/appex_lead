import 'package:appex_lead/controller/theme/theme_controller.dart';
import 'package:appex_lead/main.dart';
import 'package:appex_lead/model/notification_model.dart';
import 'package:appex_lead/utils/app_routes.dart';
import 'package:appex_lead/utils/constants.dart';
import 'package:appex_lead/utils/custom_toast_messages.dart';
import 'package:appex_lead/utils/helpers.dart';
import 'package:appex_lead/view/dashboard.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:appex_lead/utils/notification_helper.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

String formatDateTime(String? dateTimeString) {
  if (dateTimeString == null || dateTimeString.isEmpty) return "N/A";
  try {
    DateTime dt = DateTime.parse(dateTimeString).toLocal();
    return previewableDateTimeFormat(dt);
  } catch (e) {
    return dateTimeString;
  }
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationModel> savedNotifications = [];
  bool isLoading = true;

  final data = Get.arguments;
  late ColorManager themeCont;
  @override
  void initState() {
    super.initState();
    themeCont = Get.put(ColorManager());
    _initData();
  }

  Future<void> _initData() async {
    if (data != null) {
      if (data is Map<String, dynamic>) {
        await _saveNotificaion(data);
      } else if (data is RemoteMessage) {
        await services.saveNotificationToLocal(data);
      }
    }
    await _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => isLoading = true);
    final results = await services.getSavedNotifications();
    setState(() {
      savedNotifications = results.whereType<NotificationModel>().toList();
      // Sort by time descending (newest first)
      savedNotifications.sort((a, b) => b.time.compareTo(a.time));
      isLoading = false;
    });
  }

  _saveNotificaion(Map<String, dynamic> data) async {
    String title = data["title"] ?? '';
    String body = data["body"] ?? '';

    // Always return a list from prefs
    final List<dynamic> rawList = await getDecodedListFromPrefs(
      key: localNotificationsKey,
    );

    List<Map<String, dynamic>> savedList = rawList
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    String notificationId = data['notification_id'] ?? '';

    if ((notificationId.isNotEmpty &&
            savedList.any((e) => e['notification_id'] == notificationId)) ||
        title.isEmpty) {
      return;
    } else {
      // Create notification
      NotificationModel notification = NotificationModel(
        id: notificationId,
        title: title,
        description: body,
        contentType: data["content_type"] ?? "",
        contentURL: data["content_url"] ?? "",
        route: data["route"] ?? "",
        time: DateTime.now().toIso8601String(),
        type: data["type"],
      );

      savedList.add(notification.toMap());

      // Save back
      await setDataToPrefsEncoded(key: localNotificationsKey, value: savedList);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorManager.bgDark,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorManager.bgDark,
        leading: IconButton(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            color: colorManager.iconColor,
          ),
          onPressed: () => Get.offAll(Dashboard()),
        ),
        title: Text(
          "Notifications",
          style: primaryTextStyle.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          if (savedNotifications.isNotEmpty)
            IconButton(
              onPressed: () async {
                await customPopup(
                  btnHeight: 30,
                  onConfirm: () async {
                    showLoading(message: 'Clearing...');
                    await setDataToPrefsEncoded(
                      key: localNotificationsKey,
                      value: [],
                    );
                    Get.back();
                    Get.forceAppUpdate();

                    showSuccessMessage(message: 'Notifications cleard!');
                  },
                  context: context,
                  title: 'Are you sure',
                  message: 'Do you want to clear all notificaions?',
                );
              },

              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedDelete02,
                color: Colors.redAccent,
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        color: colorManager.primaryColor,
        onRefresh: _loadNotifications,
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: colorManager.primaryColor,
                ),
              )
            : savedNotifications.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: Get.height * 0.3),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedNotification01,
                          color: colorManager.textColor.withOpacity(0.3),
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No notifications yet",
                          style: primaryTextStyle.copyWith(
                            color: colorManager.textColor.withOpacity(0.5),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(18),
                itemCount: savedNotifications.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = savedNotifications[index];
                  final style = NotificationHelper.getNotificationStyle(
                    item.type,
                  );

                  return NotificationCard(
                    notification: item,
                    isUnread: false, // Could be enhanced later
                    icon: style.icon,
                    iconColor: style.color,
                  );
                },
              ),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final bool isUnread;
  final icon;
  final Color iconColor;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.isUnread,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(
          AppPages.notification_detail_screen,
          arguments: {
            "title": notification.title,
            "body": notification.description,
            "contentType": notification.contentType,
            "contentURL": notification.contentURL,
            "extra": '',
            "type": notification.type,
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorManager.bgDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnread
                ? colorManager.primaryColor.withOpacity(0.3)
                : colorManager.borderColor,
            width: 1,
          ),
          boxShadow: isUnread
              ? [
                  BoxShadow(
                    color: colorManager.primaryColor.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: HugeIcon(icon: icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: primaryTextStyle.copyWith(
                            fontSize: 16,
                            color: colorManager.textColor,
                            fontWeight: isUnread
                                ? FontWeight.w700
                                : FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatDateTime(notification.time),
                    style: primaryTextStyle.copyWith(
                      fontSize: 10,
                      color: colorManager.textColor.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notification.description,
                    style: primaryTextStyle.copyWith(
                      fontSize: 14,
                      color: colorManager.textColor.withOpacity(0.7),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isUnread) ...[
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: colorManager.primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
