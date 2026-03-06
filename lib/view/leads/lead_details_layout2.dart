import 'dart:developer';
import 'package:appex_lead/controller/form/generic_form_controller.dart';
import 'package:appex_lead/controller/lead/lead_controller.dart';
import 'package:appex_lead/main.dart';
import 'package:appex_lead/model/lead_model.dart'; // for Followup
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
  Map<String, dynamic>? lead;

  // Fields to hide from group cards (still accessible via controller.formValues)
  final Set<String> _hiddenDetailFields = {'id', 'lead_status', 'whatsapp'};

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
        final followupRaw = _lead['followup'] as List? ?? [];
        final followups = followupRaw
            .map((f) => Followup.fromJson(Map<String, dynamic>.from(f)))
            .toList();
        final businessName =
            controller.formValues['business_name'] ?? "Lead Details";

        return NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 100.0,
                floating: false,
                pinned: true,
                elevation: 0,
                backgroundColor: colorManager.accentColor,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Padding(
                    padding: const EdgeInsets.only(
                      top: 32.0,
                      left: 16.0,
                      right: 16.0,
                    ),
                    child: Text(
                      businessName.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          colorManager.accentColor,
                          colorManager.accentColor,
                        ],
                      ),
                    ),
                    child:
                        (controller.formValues['person_name'] != null &&
                            controller.formValues['person_name']
                                .toString()
                                .trim()
                                .isNotEmpty)
                        ? Padding(
                            padding: const EdgeInsets.only(
                              top: 0,
                              left: 52.0,
                              right: 18,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        // radius: 20,
                                        backgroundColor: Colors.white
                                            .withOpacity(0.0),
                                        child: const HugeIcon(
                                          icon: HugeIcons.strokeRoundedUser,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),

                                      if (controller
                                                  .formValues['person_name'] !=
                                              null &&
                                          controller.formValues['person_name']
                                              .toString()
                                              .trim()
                                              .isNotEmpty)
                                        Expanded(
                                          child: Text(
                                            controller.formValues['person_name']
                                                .toString()
                                                .toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Container(
                                  child:
                                      (controller.formValues['lead_status'] !=
                                              null &&
                                          controller.formValues['lead_status']
                                              .toString()
                                              .trim()
                                              .isNotEmpty)
                                      ? Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            controller.formValues['lead_status']
                                                .toString()
                                                .toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        )
                                      : SizedBox(),
                                ),
                              ],
                            ),
                          )
                        : SizedBox(),
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

                  _buildAdditionalInfoGroup(
                    controller.currentLead.value ?? lead!,
                  ),
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
        backgroundColor: colorManager.primaryColor,
        onPressed: () {
          Get.to(() => InteractionForm(leadId: "1"));
        },
        child: Icon(Icons.add, color: colorManager.whiteColor),
      ),
    );
  }

  Widget _buildQuickActions(Map<String, dynamic> lead) {
    final phone =
        controller.formValues['phone_number'] ??
        controller.formValues['phone_no'];
    final mobileNO =
        controller.formValues['mobile_number'] ??
        controller.formValues['mobile_no'];
    final whatsapp = controller.formValues['whatsapp'];
    final email = controller.formValues['email_address'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (mobileNO != null && mobileNO.toString().trim().isNotEmpty)
          _actionButton(
            icon: HugeIcons.strokeRoundedCall,
            label: "Call",
            color: colorManager.primaryColor,
            onTap: () => _launchUrl("tel:$mobileNO"),
          ),
        if (whatsapp != null && whatsapp.toString().trim().isNotEmpty)
          _actionButton(
            icon: HugeIcons.strokeRoundedWhatsapp,
            label: "Whatsapp",
            color: Colors.green,
            onTap: () => _launchUrl(whatsapp),
          ),
        if (phone != null && phone.toString().trim().isNotEmpty)
          _actionButton(
            icon: HugeIcons.strokeRoundedTelephone,
            label: "Call",
            color: colorManager.accentColor,
            onTap: () => _launchUrl("tel:$phone"),
          ),
        if (email != null && email.toString().trim().isNotEmpty)
          _actionButton(
            icon: HugeIcons.strokeRoundedMail01,
            label: "Email",
            color: Colors.blue,
            onTap: () => _launchEmail(email),
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
      if (_hiddenDetailFields.contains(fieldName)) return false;
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

  Widget _buildAdditionalInfoGroup(Map<String, dynamic> lead) {
    final fieldsRecord = lead['fields_record'];
    if (fieldsRecord == null) return const SizedBox.shrink();

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

    final data = Map<String, dynamic>.from(fieldsRecord);

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

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': 'Hello',
        'body': 'I want to contact you about...',
      },
    );

    try {
      bool launched = await launchUrl(
        emailUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        // fallback: open Gmail web page in browser
        final Uri gmailWeb = Uri.parse(
          'https://mail.google.com/mail/?view=cm&to=$email',
        );
        await launchUrl(gmailWeb, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Could not launch email: $e');
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
