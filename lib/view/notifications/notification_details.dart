import 'package:appex_lead/component/custom_appbar.dart';
import 'package:appex_lead/component/media_viewer.dart';
import 'package:appex_lead/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:appex_lead/main.dart';

import 'package:appex_lead/view/dashboard.dart';

class NotificaionDetailScreen extends StatefulWidget {
  const NotificaionDetailScreen({super.key});

  @override
  State<NotificaionDetailScreen> createState() =>
      _NotificaionDetailScreenState();
}

class _NotificaionDetailScreenState extends State<NotificaionDetailScreen> {
  final args = Get.arguments as Map<String, dynamic>?;
  var title, descrtiption, contentType, url, extra;
  fetchNotificaionPayloadDetails() {
    if (mounted) {
      setState(() {
        title = args?['title'] ?? 'No title';
        descrtiption = args?['body'] ?? 'No body';
        contentType = args?['contentType'] ?? '';
        url = args?['contentURL'] ?? '';
        extra = args?['extra'] ?? '';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchNotificaionPayloadDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorManager.bgDark,
      appBar: CustomAppBar(
        onNavigateBack: () {
          Get.offAll(() => Dashboard());
        },
        title: 'Notification Details',
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 18),
        child: ListView(
          children: [
            if (url != null && url.isNotEmpty)
              MediaViewer(
                autoRatio: true,
                contentType: contentType ?? '',
                url: url ?? '',
                shortsEnabled: false, // url:
                //     'https://images.pexels.com/photos/674010/pexels-photo-674010.jpeg?cs=srgb&dl=pexels-anjana-c-169994-674010.jpg&fm=jpg'
              ),
            SizedBox(height: 12),
            Text(
              '${title ?? 'Notificaion Title '}',
              style: primaryTextStyle.copyWith(
                color: colorManager.primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '${descrtiption ?? 'Notifcaion Body / Description '}',
              style: primaryTextStyle.copyWith(color: colorManager.textColor),
            ),
          ],
        ),
      ),
    );
  }
}
