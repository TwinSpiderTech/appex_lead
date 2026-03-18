import 'package:appex_lead/main.dart';
import 'package:appex_lead/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? type;
  final String? date;
  final String? nextFollowup;
  final dynamic icon;
  final VoidCallback onTap;
  final List<Widget>? extraActions;

  const SummaryCard({
    super.key,
    required this.title,
    this.subtitle,
    this.type,
    this.date,
    this.nextFollowup,
    this.icon,
    required this.onTap,
    this.extraActions,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: colorManager.whiteColor,
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorManager.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: HugeIcon(
                      icon: icon ?? HugeIcons.strokeRoundedMessage01,
                      color: colorManager.primaryColor,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: primaryTextStyle.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: -0.5,
                          ),
                        ),
                        if (type != null && type!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Text(
                              type!,
                              style: primaryTextStyle.copyWith(
                                color: colorManager.primaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        if (subtitle != null && subtitle!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Text(
                              subtitle!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: primaryTextStyle.copyWith(
                                color: colorManager.textColor.withOpacity(0.6),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        if (nextFollowup != null &&
                            nextFollowup!.isNotEmpty &&
                            nextFollowup != "null")
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Text(
                              "Next Followup: $nextFollowup",
                              style: primaryTextStyle.copyWith(
                                color: colorManager.textColor,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (extraActions != null) ...extraActions!,
                ],
              ),
              if (date != null && date!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      date!,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
