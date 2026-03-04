import 'dart:developer';
import 'package:appex_lead/component/custom_appbar.dart';
import 'package:appex_lead/controller/form/generic_form_controller.dart';
import 'package:appex_lead/controller/lead/lead_controller.dart';
import 'package:appex_lead/main.dart';
import 'package:appex_lead/model/lead_model.dart';
import 'package:appex_lead/utils/helpers.dart';
import 'package:appex_lead/view/form/form_field_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LeadDetailsScreen extends StatefulWidget {
  final LeadController cont;
  // final String title;
  final String? url;
  // final String? templateUrl;

  const LeadDetailsScreen({
    super.key,
    // required this.lead,
    // this.title = "Lead Details",
    this.url,
    required this.cont,
    // this.templateUrl,
  });

  @override
  State<LeadDetailsScreen> createState() => _LeadDetailsScreenState();
}

class _LeadDetailsScreenState extends State<LeadDetailsScreen> {
  final controller = Get.put(GenericFormController());
  LeadModel? lead;
  @override
  void initState() {
    super.initState();
    initData();
  }

  initData() async {
    log("Initializing LeadDetailsScreen for URL: ${widget.url}");
    controller.clearSession(); // Clear previous data

    lead = await widget.cont.loadLeadDetails(widget.url!);
    log("Fetched Lead: ${lead?.toJson()}");

    if (lead != null) {
      // 1. Set current lead
      controller.currentLead.value = lead;

      // 2. Fetch template
      await controller.fetchTemplate(
        "/api/v1/business/leads/get_form_template",
      );

      // 3. Resume draft (populates formValues from lead data)
      controller.resumeDraft(lead!);
    } else {
      log("Lead data is NULL after loading.");
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Lead Details",
        onNavigateBack: () => Get.back(),
      ),
      body: Obx(() {
        if (controller.isLoadingTemplates.value || lead == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final _lead = controller.currentLead.value ?? lead!;
        final followups = _lead.followup ?? [];

        return RefreshIndicator(
          onRefresh: () async {
            if (widget.url != null) {
              await controller.fetchLeadDetails(widget.url!);
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (controller.fieldsData.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        "No template loaded to display fields.",
                        style: TextStyle(color: colorManager.textColor),
                      ),
                    ),
                  ),

                // Lead Info (Form Fields)
                ...controller.formGroupsData.map((group) {
                  final fields = group['fields'] as List? ?? [];
                  final groupTitle = group['group_title'];

                  // Filter fields that have values
                  final visibleFields = fields.where((fieldData) {
                    final fieldName = fieldData['field_name'];
                    final value = controller.formValues[fieldName];
                    if (value == null) return false;
                    final strVal = value.toString().trim();
                    return strVal.isNotEmpty && strVal.toLowerCase() != "null";
                  }).toList();

                  if (visibleFields.isEmpty) return const SizedBox.shrink();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (groupTitle != null &&
                          groupTitle.toString().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 24.0,
                            bottom: 12.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                groupTitle.toString(),
                                style: TextStyle(
                                  color: colorManager.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                height: 2,
                                width: 40,
                                decoration: BoxDecoration(
                                  color: colorManager.primaryColor,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: colorManager.primaryColor.withOpacity(.3),
                          ),
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(18),
                            bottomLeft: Radius.circular(18),
                            bottomRight: Radius.circular(18),
                          ),
                        ),
                        child: Column(
                          children: visibleFields.map((fieldData) {
                            final field = Map<String, dynamic>.from(fieldData);
                            return controller.isHidden(
                                  field['field_visibility'],
                                )
                                ? const SizedBox.shrink()
                                : GenericFormFieldWidget(
                                    fieldData: field,
                                    controller: controller,
                                    isReadOnly: true,
                                  );
                          }).toList(),
                        ),
                      ),
                    ],
                  );
                }).toList(),

                const SizedBox(height: 32),

                // Follow-up Section
                if (followups.isNotEmpty) ...[
                  Text(
                    "Follow up History",
                    style: TextStyle(
                      color: colorManager.textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...followups.map((f) => _buildTimelineItem(f)).toList(),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTimelineItem(
    Followup followup, {
    bool isAgent = false,
    bool isSystem = false,
    Widget? icon,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: isSystem
                    ? Colors.blue.withOpacity(0.1)
                    : (isAgent
                          ? colorManager.primaryColor.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1)),
                child:
                    icon ??
                    Icon(
                      isSystem
                          ? Icons.info_outline
                          : (isAgent
                                ? Icons.support_agent
                                : Icons.person_outline),
                      size: 14,
                      color: isSystem
                          ? Colors.blue
                          : (isAgent ? colorManager.primaryColor : Colors.grey),
                    ),
              ),
              Expanded(
                child: Container(width: 2, color: Colors.grey.withOpacity(0.2)),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        followup.title ?? "",
                        style: primaryTextStyle.copyWith(
                          color: colorManager.textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      followup.time ?? "",
                      style: primaryTextStyle.copyWith(
                        fontSize: 11,
                        color: colorManager.textColor.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  followup.description ?? "",
                  style: primaryTextStyle.copyWith(
                    fontSize: 13,
                    color: colorManager.textColor.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //   Widget _buildFollowupItem(Followup followup) {
  //     return Container(
  //       margin: const EdgeInsets.only(bottom: 12),
  //       padding: const EdgeInsets.all(16),
  //       decoration: BoxDecoration(
  //         color: colorManager.secondaryColor.withOpacity(0.05),
  //         borderRadius: BorderRadius.circular(12),
  //         border: Border.all(color: colorManager.secondaryColor.withOpacity(0.2)),
  //       ),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Expanded(
  //                 child: Text(
  //                   followup.title ?? "No Title",
  //                   style: const TextStyle(
  //                     fontWeight: FontWeight.bold,
  //                     fontSize: 16,
  //                   ),
  //                 ),
  //               ),
  //               const SizedBox(width: 8),
  //               Text(
  //                 followup.time ?? "",
  //                 style: TextStyle(
  //                   color: colorManager.primaryColor,
  //                   fontSize: 12,
  //                   fontWeight: FontWeight.w600,
  //                 ),
  //               ),
  //             ],
  //           ),
  //           const SizedBox(height: 8),
  //           Text(
  //             followup.description ?? "",
  //             style: TextStyle(
  //               color: colorManager.textColor.withOpacity(0.8),
  //               fontSize: 14,
  //             ),
  //           ),
  //         ],
  //       ),
  //     );
  //   }
}
