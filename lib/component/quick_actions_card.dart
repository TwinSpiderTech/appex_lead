import 'dart:developer';

import 'package:appex_lead/controller/form/generic_form_controller.dart';
import 'package:appex_lead/main.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';

class QuickActionsCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final controller;
  const QuickActionsCard({
    super.key,
    required this.data,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final mobileNo =
        controller.formValues['mobile_number'] ??
        controller.formValues['mobile_no'] ??
        data['mobile_number'] ??
        data['mobile_no'];

    final phoneNo =
        controller.formValues['phone_number'] ??
        controller.formValues['phone_no'] ??
        data['phone_number'] ??
        data['phone_no'];

    final whatsapp =
        controller.formValues['whatsapp'] ?? mobileNo ?? data['whatsapp'];

    final email =
        controller.formValues['email_address'] ??
        controller.formValues['email'] ??
        data['email_address'] ??
        data['email'];

    final gps = controller.formValues['gps_points'] ?? data['gps_points'];

    final String? lat = gps is Map ? gps['latitude']?.toString() : null;
    final String? lng = gps is Map ? gps['longitude']?.toString() : null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (mobileNo != null && mobileNo.toString().trim().isNotEmpty)
          _actionButton(
            icon: HugeIcons.strokeRoundedCall,
            label: "Call",
            color: colorManager.primaryColor,
            onTap: () => _launchUrl("tel:$mobileNo"),
          ),

        if (whatsapp != null && whatsapp.toString().trim().isNotEmpty)
          _actionButton(
            icon: HugeIcons.strokeRoundedWhatsapp,
            label: "WhatsApp",
            color: Colors.green,
            onTap: () => _launchWhatsapp(whatsapp.toString()),
          ),

        if (phoneNo != null && phoneNo.toString().trim().isNotEmpty)
          _actionButton(
            icon: HugeIcons.strokeRoundedTelephone,
            label: "Phone",
            color: Colors.orange,
            onTap: () => _launchUrl("tel:$phoneNo"),
          ),

        if (email != null && email.toString().trim().isNotEmpty)
          _actionButton(
            icon: HugeIcons.strokeRoundedMail01,
            label: "Email",
            color: Colors.blue,
            onTap: () => _launchEmail(email.toString()),
          ),

        if (lat != null && lng != null)
          _actionButton(
            icon: HugeIcons.strokeRoundedLocation01,
            label: "Location",
            color: Colors.indigo,
            onTap: () => _launchUrl(
              "https://www.google.com/maps/search/?api=1&query=$lat,$lng",
            ),
          ),
      ],
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      log("Error launching URL: $e");
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      log("Error launching email: $e");
    }
  }

  Future<void> _launchWhatsapp(String phoneNumber) async {
    String number = phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (number.startsWith("0")) {
      number = "92${number.substring(1)}";
    }
    await _launchUrl("https://wa.me/$number");
  }

  Widget _actionButton({
    required icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: HugeIcon(icon: icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: colorManager.textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
