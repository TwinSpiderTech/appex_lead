import 'dart:developer';
import 'package:appex_lead/controller/dash/dash_controller.dart';
import 'package:appex_lead/controller/interaction/interaction_form_controller.dart';
import 'package:appex_lead/main.dart';
import 'package:appex_lead/model/lead_model.dart';
import 'package:appex_lead/utils/helpers.dart';
import 'package:appex_lead/view/form/form_field_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class InteractionDetailsLayout extends StatefulWidget {
  final Followup? followup;
  final Map<String, dynamic>? interactionData;
  final String? leadTitle;

  const InteractionDetailsLayout({
    super.key,
    this.followup,
    this.interactionData,
    this.leadTitle,
  });

  @override
  State<InteractionDetailsLayout> createState() =>
      _InteractionDetailsLayoutState();
}

class _InteractionDetailsLayoutState extends State<InteractionDetailsLayout> {
  final controller = Get.put(InteractionFormController());
  Map<String, dynamic>? data;

  final List<String> _hiddenFields = ['captured_at', 'id', 'business_name'];

  bool _shouldHideField(String key, dynamic value) {
    if (key.startsWith("_")) return true;
    if (_hiddenFields.contains(key)) return true;

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

  final Map<String, String> _fieldMapper = {'setup_status': 'status'};

  Map<String, dynamic> _applyMapping(Map<String, dynamic> rawData) {
    final mappedData = Map<String, dynamic>.from(rawData);
    _fieldMapper.forEach((sourceKey, targetKey) {
      if (rawData.containsKey(sourceKey)) {
        mappedData[targetKey] = rawData[sourceKey];
      }
    });
    return mappedData;
  }

  @override
  void initState() {
    super.initState();
    initData();
  }

  initData() async {
    controller.clearSession();

    // Determine data source
    if (widget.interactionData != null) {
      data = widget.interactionData;
    } else if (widget.followup != null) {
      data =
          widget.followup!.rawData ??
          {
            'title': widget.followup!.title,
            'description': widget.followup!.description,
            'updated_at': widget.followup!.time,
            'interaction_type': widget.followup!.type,
          };
    }

    if (data != null) {
      prettyPrint(data);
      // Determine template to fetch
      final templateUrl =
          data!['template_url'] ??
          (data!['FOLLOWUP']?['template_url']) ??
          "/api/v1/business/interactions/get_form_template";

      await controller.fetchTemplate(templateUrl.toString());
      final mappedData = _applyMapping(data!);
      controller.resumeDraft(mappedData);
    }
    setState(() {});
  }

  @override
  void dispose() {
    Get.delete<InteractionFormController>();
    super.dispose();
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
        title: Obx(() {
          String title = Get.find<DashController>().interactionFormTitle.value;
          return Text(
            "$title Details",
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
              fontSize: 14,
              letterSpacing: 1,
            ),
          );
        }),
      ),
      body: Obx(() {
        if (controller.isLoadingTemplates.value || data == null) {
          return _buildShimmerLoading();
        }

        final title =
            data!['business_name'] ??
            data!['title'] ??
            widget.leadTitle ??
            "Interaction Details";
        final personName =
            controller.formValues['person_name'] ?? data!['person_name'] ?? "";
        final status = toParameterize(
          controller.formValues['setup_status'] ?? data!['setup_status'] ?? "",
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
                              title.toString(),
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
                            _buildQuickActions(data!),
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
                          return _buildFieldGroup(group);
                        }).toList(),
                        _buildExhaustiveMetadataSection(data!),
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
    );
  }

  Widget _buildFieldGroup(Map<String, dynamic> group) {
    final fields = group['fields'] as List? ?? [];
    final groupTitle = group['group_title'] ?? "Information";

    // Filter fields based on the new logic
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
              return Column(
                children: [
                  GenericFormFieldWidget(
                    fieldData: Map<String, dynamic>.from(fieldData),
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

  Widget _buildExhaustiveMetadataSection(Map<String, dynamic> interaction) {
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

    final allData = Map<String, dynamic>.from(controller.formValues);
    // Explicitly add potentially missing keys from interaction data
    interaction.forEach((key, value) {
      if (!allData.containsKey(key)) allData[key] = value;
    });

    List<Widget> extraRows = [];

    allData.forEach((key, value) {
      if (!renderedKeys.contains(key) && !_shouldHideField(key, value)) {
        String label = key.replaceAll('_', ' ').capitalizeFirstLetters();
        extraRows.add(_buildMetadataRow(label, value));
      }
    });

    if (extraRows.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12, top: 32),
          child: Text(
            "ADDITIONAL METADATA",
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
          ),
          child: Column(children: extraRows),
        ),
      ],
    );
  }

  Widget _buildMetadataRow(String label, dynamic value) {
    String displayValue = (value == null || value.toString().trim().isEmpty)
        ? "—"
        : value.toString();
    if (value is Map) {
      final values = value.values
          .where((v) => v != null && v.toString().trim().isNotEmpty)
          .toList();
      displayValue = values.isEmpty ? "—" : values.join(", ");
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: colorManager.textColor.withOpacity(0.5),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              displayValue,
              style: TextStyle(
                color: colorManager.textColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(Map<String, dynamic> interaction) {
    final phone =
        controller.formValues['mobile_no'] ??
        controller.formValues['phone_no'] ??
        interaction['mobile_no'];
    final gps =
        controller.formValues['gps_points'] ?? interaction['gps_points'];
    final String? lat = gps is Map ? gps['latitude']?.toString() : null;
    final String? lng = gps is Map ? gps['longitude']?.toString() : null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (phone != null && phone.toString().trim().isNotEmpty)
          _actionButton(
            icon: HugeIcons.strokeRoundedCall,
            label: "Call",
            color: colorManager.primaryColor,
            onTap: () => _launchUrl("tel:$phone"),
          ),
        _actionButton(
          icon: HugeIcons.strokeRoundedWhatsapp,
          label: "WhatsApp",
          color: Colors.green,
          onTap: () => _launchWhatsapp(phone?.toString() ?? ""),
        ),
        if (lat != null && lng != null)
          _actionButton(
            icon: HugeIcons.strokeRoundedLocation01,
            label: "Location",
            color: Colors.blue,
            onTap: () => _launchUrl(
              "https://www.google.com/maps/search/?api=1&query=$lat,$lng",
            ),
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
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: HugeIcon(icon: icon, color: color, size: 26),
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

  Future<void> _launchWhatsapp(String phoneNumber) async {
    String number = phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (number.startsWith("0")) {
      number = "92${number.substring(1)}";
    }
    await _launchUrl("https://wa.me/$number");
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
