import 'dart:developer';
import 'package:appex_lead/controller/form/generic_form_controller.dart';
import 'package:appex_lead/controller/lead/lead_controller.dart';
import 'package:appex_lead/main.dart';
import 'package:appex_lead/model/lead_model.dart';
import 'package:appex_lead/utils/helpers.dart';
import 'package:appex_lead/view/form/form_field_widgets.dart';
import 'package:appex_lead/view/interaction/interaction_form.dart';
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
  LeadModel? lead;

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
      backgroundColor: colorManager.whiteColor,
      body: Obx(() {
        if (controller.isLoadingTemplates.value || lead == null) {
          return _buildShimmerLoading();
        }

        final _lead = controller.currentLead.value ?? lead!;
        final followups = _lead.followup ?? [];
        final businessName =
            controller.formValues['business_name'] ??
            _lead.fieldsRecord?.businessName ??
            "Lead Details";

        return NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                elevation: 0,
                backgroundColor: colorManager.primaryColor,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    businessName.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          colorManager.primaryColor,
                          colorManager.primaryColor.withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            child: const HugeIcon(
                              icon: HugeIcons.strokeRoundedUser,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (_lead.fieldsRecord?.leadStatus != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _lead.fieldsRecord?.leadStatus?.toUpperCase() ??
                                    "",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          if (_lead.fieldsRecord?.personName != null)
                            Container(
                              margin: const EdgeInsets.only(top: 6, bottom: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _lead.fieldsRecord?.personName?.toUpperCase() ??
                                    "",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ];
          },
          body: RefreshIndicator(
            color: colorManager.primaryColor,
            onRefresh: () async {
              await initData();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuickActions(_lead),
                  const SizedBox(height: 24),

                  // Form Fields Grouped in Cards
                  ...controller.formGroupsData.map((group) {
                    return _buildGroupCard(group);
                  }).toList(),

                  // _buildAdditionalInfoGroup(
                  //   controller.currentLead.value ?? lead!,
                  // ),
                  const SizedBox(height: 32),

                  if (followups.isNotEmpty) ...[
                    Text(
                      "Follow up History",
                      style: TextStyle(
                        color: colorManager.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...followups.map((f) => _buildTimelineItem(f)).toList(),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => InteractionForm(leadId: "1"));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildQuickActions(LeadModel lead) {
    final phone =
        controller.formValues['phone_number'] ?? lead.fieldsRecord?.phoneNo;
    final mobileNO =
        controller.formValues['mobile_number'] ?? lead.fieldsRecord?.mobileNo;

    final email = lead.fieldsRecord?.emailAddress;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (mobileNO != null && mobileNO.toString().trim().isNotEmpty)
          _actionButton(
            icon: HugeIcons.strokeRoundedCall,
            label: "Call",
            color: Colors.green,
            onTap: () => _launchWhatsappUrl(mobileNO),
          ),
        if (phone != null && phone.toString().trim().isNotEmpty)
          _actionButton(
            icon: HugeIcons.strokeRoundedTelephone,
            label: "Call",
            color: Colors.green,
            onTap: () => _launchUrl("tel:$phone"),
          ),
        if (email != null && email.toString().trim().isNotEmpty)
          _actionButton(
            icon: HugeIcons.strokeRoundedMail01,
            label: "Email",
            color: Colors.blue,
            onTap: () => _launchUrl("mailto:$email"),
          ),
      ],
    );
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
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: HugeIcon(icon: icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: colorManager.textColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupCard(Map<String, dynamic> group) {
    final fields = group['fields'] as List? ?? [];
    final groupTitle = group['group_title'] ?? "Information";

    final visibleFields = fields.where((fieldData) {
      final fieldName = fieldData['field_name'];
      final value = controller.formValues[fieldName];
      if (value == null) return false;
      final strVal = value.toString().trim();
      return strVal.isNotEmpty && strVal.toLowerCase() != "null";
    }).toList();

    if (visibleFields.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: colorManager.secondaryColor.withOpacity(0.1)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          collapsedShape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorManager.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedNotebook,
              color: colorManager.primaryColor,
              size: 20,
            ),
          ),
          title: Text(
            groupTitle.toString(),
            style: TextStyle(
              color: colorManager.textColor,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            const Divider(height: 1),
            const SizedBox(height: 8),
            ...visibleFields.map((fieldData) {
              final field = Map<String, dynamic>.from(fieldData);
              return controller.isHidden(field['field_visibility'])
                  ? const SizedBox.shrink()
                  : GenericFormFieldWidget(
                      fieldData: field,
                      controller: controller,
                      isReadOnly: true,
                    );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoGroup(LeadModel lead) {
    if (lead.fieldsRecord == null) return const SizedBox.shrink();

    // Get all rendered keys from the template
    Set<String> renderedKeys = {};
    for (var group in controller.formGroupsData) {
      final fields = group['fields'] as List? ?? [];
      for (var f in fields) {
        if (f['field_name'] != null) {
          renderedKeys.add(f['field_name'].toString());
        }
      }
    }

    final data = lead.fieldsRecord!.toJson();

    List<Map<String, dynamic>> extraFields = [];
    data.forEach((key, value) {
      if (!renderedKeys.contains(key) &&
          value != null &&
          value.toString().trim().isNotEmpty &&
          value.toString().toLowerCase() != "null") {
        // Convert snake_case to Title Case for labels
        String label = key
            .replaceAll('_', ' ')
            .split(' ')
            .map((word) {
              if (word.isEmpty) return word;
              return word[0].toUpperCase() + word.substring(1);
            })
            .join(' ');

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

  Widget _buildTimelineItem(Followup followup) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: colorManager.primaryColor.withOpacity(0.1),
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedClock01,
                  color: colorManager.primaryColor,
                  size: 14,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        followup.title ?? "",
                        style: primaryTextStyle.copyWith(
                          color: colorManager.textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
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
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        log("Could not launch $url");
      }
    } catch (e) {
      log("Error launching URL: $e");
    }
  }

  Future<void> _launchWhatsappUrl(String phoneNumber) async {
    String number = phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (number.startsWith("0")) {
      number = "92${number.substring(1)}";
    }
    String url = "https://wa.me/$number";
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        log("Could not launch $url");
      }
    } catch (e) {
      log("Error launching URL: $e");
    }
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(color: Colors.white),
            ),
          ),
          SliverFillRemaining(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //   children: [
                  //     CircleAvatar(radius: 30, backgroundColor: Colors.white),
                  //     CircleAvatar(radius: 30, backgroundColor: Colors.white),
                  //   ],
                  // ),
                  const SizedBox(height: 24),
                  ...List.generate(
                    3,
                    (index) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
