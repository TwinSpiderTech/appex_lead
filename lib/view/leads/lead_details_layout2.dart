import 'dart:developer';
import 'package:ts_fieldforce/component/quick_actions_card.dart';
import 'package:ts_fieldforce/controller/dash/dash_controller.dart';
import 'package:ts_fieldforce/controller/form/generic_form_controller.dart';
import 'package:ts_fieldforce/controller/lead/lead_controller.dart';
import 'package:ts_fieldforce/main.dart';
import 'package:ts_fieldforce/model/lead_model.dart'; // for Followup
import 'package:ts_fieldforce/utils/helpers.dart';
import 'package:ts_fieldforce/view/form/form_field_widgets.dart';
import 'package:ts_fieldforce/view/interaction/interaction_details_layout.dart';
import 'package:ts_fieldforce/view/interaction/interaction_form.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class LeadDetailsLayout2 extends StatefulWidget {
  final LeadController cont;
  final String? url;

  const LeadDetailsLayout2({super.key, this.url, required this.cont});

  @override
  State<LeadDetailsLayout2> createState() => _LeadDetailsLayout2State();
}

class _LeadDetailsLayout2State extends State<LeadDetailsLayout2> {
  final controller = Get.put(GenericFormController());
  Map<String, dynamic>? lead;

  // Fields to hide from group cards (still accessible via controller.formValues)
  final List<String> _hiddenDetailFields = [
    'id',
    'lead_status',
    'whatsapp',
    'business_name',
    'person_name',
  ];

  bool _shouldHideField(String key, dynamic value) {
    if (key.startsWith("_")) return true;
    if (_hiddenDetailFields.contains(key)) return true;

    // Hide empty/null values
    if (value == null) return true;

    if (value is String) {
      final strVal = value.trim();
      if (strVal.isEmpty || strVal.toLowerCase() == "null") return true;
    }

    if (value is Iterable && value.isEmpty) return true;
    if (value is Map && value.isEmpty) return true;

    // Alternative "null" string check for non-string types
    if (value.toString().trim().toLowerCase() == "null") return true;
    if (value.toString().trim() == "[]" || value.toString().trim() == "{}") {
      return true;
    }

    return false;
  }

  @override
  void initState() {
    super.initState();
    initData();
  }

  initData() async {
    log("Initializing LeadDetailsLayout2 for URL: ${widget.url}");
    controller.clearSession();

    lead = await widget.cont.loadLeadDetails(widget.url!);
    if (lead != null) {
      prettyPrint(lead);
      controller.currentLead.value = lead;
      await controller.fetchTemplate(
        "/api/v1/business/leads/get_form_template",
      );
      controller.resumeDraft(lead!);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Off-white modern background
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Text(
          toParameterize(Get.find<DashController>().leadFormTitle.value) +
              " Details",
          style: TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w600,
            fontSize: 14,
            letterSpacing: 1,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoadingTemplates.value || lead == null) {
          return _buildShimmerLoading();
        }

        final _lead = controller.currentLead.value ?? lead!;
        final followupRaw = _lead['followup_history'] as List? ?? [];
        final followups = followupRaw
            .map((f) => Followup.fromJson(Map<String, dynamic>.from(f)))
            .toList();
        final businessName =
            controller.formValues['business_name'] ?? "Lead Details";
        final personName = controller.formValues['person_name'] ?? "";
        final status = toParameterize(
          controller.formValues['lead_status'] ?? "",
        );

        return Stack(
          children: [
            // 1. Vibrant Header Background
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [colorManager.accentColor, colorManager.accentColor],
                ),
              ),
            ),

            // 2. Main Scrollable Content
            SafeArea(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Overlapping Profile Card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        margin: const EdgeInsets.only(top: 20),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              businessName.toString(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: colorManager.textColor,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            if (personName.toString().trim().isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                personName.toString(),
                                style: TextStyle(
                                  color: colorManager.textColor.withOpacity(
                                    0.6,
                                  ),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            if (status.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: colorManager.primaryColor.withOpacity(
                                    0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    color: colorManager.primaryColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            const Divider(height: 32),
                            QuickActionsCard(
                              data: _lead,
                              controller: controller,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Data Sections
                  SliverPadding(
                    padding: const EdgeInsets.all(16.0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: 8),
                        ...controller.formGroupsData.map((group) {
                          return _buildGroupCard(group);
                        }).toList(),
                        _buildAdditionalInfoGroup(_lead),

                        if (followups.isNotEmpty) ...[
                          const SizedBox(height: 32),
                          Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: 16),
                            child: Text(
                              "FOLLOW UP HISTORY",
                              style: TextStyle(
                                color: colorManager.textColor.withOpacity(0.5),
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: followups
                                  .map((f) => _buildTimelineItem(f))
                                  .toList(),
                            ),
                          ),
                        ],
                        const SizedBox(height: 100),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorManager.primaryColor,
        elevation: 8,
        onPressed: () {
          Get.to(
            () => InteractionForm(
              callbackFunction: () => initData(),
              fromLead: true,
              leadDetails: lead,
              url: 'api/v1/business/interactions/get_form_template',
              title:
                  'Add ${Get.find<DashController>().interactionFormTitle.value}',
            ),
          );
        },
        child: Icon(Icons.add, color: colorManager.whiteColor),
      ),
    );
  }

  Widget _buildGroupCard(Map<String, dynamic> group) {
    final fields = group['fields'] as List? ?? [];
    final groupTitle = group['group_title'] ?? "Information";

    final visibleFields = fields.where((fieldData) {
      final fieldName = fieldData['field_name']?.toString() ?? "";
      final value = controller.formValues[fieldName];
      return !_shouldHideField(fieldName, value);
    }).toList();

    if (visibleFields.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12, top: 24),
          child: Text(
            groupTitle.toString().toUpperCase(),
            style: TextStyle(
              color: colorManager.textColor.withOpacity(0.5),
              fontWeight: FontWeight.w800,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withOpacity(0.05)),
          ),
          child: Column(
            children: visibleFields.map((fieldData) {
              final isLast = visibleFields.last == fieldData;
              final field = Map<String, dynamic>.from(fieldData);
              return Column(
                children: [
                  GenericFormFieldWidget(
                    fieldData: field,
                    controller: controller,
                    isReadOnly: true,
                  ),
                  if (!isLast)
                    Divider(height: 24, color: Colors.grey.withOpacity(0.05)),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalInfoGroup(Map<String, dynamic> lead) {
    final fieldsRecord = lead['fields_record'];
    if (fieldsRecord == null) return const SizedBox.shrink();

    // Collect keys already shown in groups
    Set<String> renderedKeys = {};
    for (var group in controller.formGroupsData) {
      final fields = group['fields'] as List? ?? [];
      for (var f in fields) {
        if (f['field_name'] != null) {
          renderedKeys.add(f['field_name'].toString());
        }
      }
    }

    final data = Map<String, dynamic>.from(fieldsRecord);
    List<Map<String, dynamic>> extraFields = [];

    data.forEach((key, value) {
      if (!renderedKeys.contains(key) && !_shouldHideField(key, value)) {
        String label = key.replaceAll('_', ' ').capitalizeFirstLetters();
        extraFields.add({
          'field_name': key,
          'field_text': label,
          'field_type': 'string',
        });
      }
    });

    if (extraFields.isEmpty) return const SizedBox.shrink();

    return _buildGroupCard({
      'group_title': 'Additional Information',
      'fields': extraFields,
    });
  }

  // Widget _buildQuickActions(Map<String, dynamic> lead) {
  //   final phoneNum =
  //       controller.formValues['phone_number'] ??
  //       controller.formValues['phone_no'];
  //   final mobileNO =
  //       controller.formValues['mobile_number'] ??
  //       controller.formValues['mobile_no'];
  //   final whatsapp = controller.formValues['whatsapp'];
  //   final email = controller.formValues['email_address'];

  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //     children: [
  //       if (mobileNO != null && mobileNO.toString().trim().isNotEmpty)
  //         _actionButton(
  //           icon: HugeIcons.strokeRoundedCall,
  //           label: "Call",
  //           color: colorManager.primaryColor,
  //           onTap: () => _launchUrl("tel:$mobileNO"),
  //         ),
  //       if (whatsapp != null && whatsapp.toString().trim().isNotEmpty)
  //         _actionButton(
  //           icon: HugeIcons.strokeRoundedWhatsapp,
  //           label: "WhatsApp",
  //           color: Colors.green,
  //           onTap: () => _launchWhatsapp(whatsapp.toString()),
  //         ),
  //       if (phoneNum != null && phoneNum.toString().trim().isNotEmpty)
  //         _actionButton(
  //           icon: HugeIcons.strokeRoundedTelephone,
  //           label: "Phone",
  //           color: Colors.orange,
  //           onTap: () => _launchUrl("tel:$phoneNum"),
  //         ),
  //       if (email != null && email.toString().trim().isNotEmpty)
  //         _actionButton(
  //           icon: HugeIcons.strokeRoundedMail01,
  //           label: "Email",
  //           color: Colors.blue,
  //           onTap: () => _launchEmail(email.toString()),
  //         ),
  //     ],
  //   );
  // }

  Widget _buildTimelineItem(Followup followup) {
    return GestureDetector(
      onTap: () {
        Get.to(
          () => InteractionDetailsLayout(
            followup: followup,
            leadTitle:
                controller.formValues['business_name']?.toString() ?? "Lead",
          ),
        );
      },
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colorManager.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedClock01,
                    color: colorManager.primaryColor,
                    size: 14,
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey.withOpacity(0.1),
                  ),
                ),
              ],
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
                          followup.title ?? "",
                          style: TextStyle(
                            color: colorManager.textColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Text(
                        followup.time ?? "",
                        style: TextStyle(
                          fontSize: 11,
                          color: colorManager.textColor.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (followup.type != null)
                    Text(
                      toParameterize(followup.type!),
                      style: TextStyle(
                        fontSize: 12,
                        color: colorManager.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const SizedBox(height: 2),
                  Text(
                    followup.description ?? "",
                    style: TextStyle(
                      fontSize: 13,
                      color: colorManager.textColor.withOpacity(0.7),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          Container(height: 220, color: Colors.white),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: List.generate(
                3,
                (index) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
