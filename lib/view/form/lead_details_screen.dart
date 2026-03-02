import 'package:appex_lead/component/custom_appbar.dart';
import 'package:appex_lead/controller/form/generic_form_controller.dart';
import 'package:appex_lead/main.dart';
import 'package:appex_lead/view/form/form_field_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LeadDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> apiData;
  final String title;

  const LeadDetailsScreen({
    super.key,
    required this.apiData,
    this.title = "Lead Details",
  });

  @override
  State<LeadDetailsScreen> createState() => _LeadDetailsScreenState();
}

class _LeadDetailsScreenState extends State<LeadDetailsScreen> {
  final controller = Get.put(GenericFormController());

  @override
  void initState() {
    super.initState();
    // Use the parsed fields_record to populate the form layout
    controller.resumeDraft(widget.apiData);
  }

  @override
  Widget build(BuildContext context) {
    final followups = widget.apiData['followup'] as List? ?? [];

    return Scaffold(
      appBar: CustomAppBar(
        title: widget.title,
        onNavigateBack: () => Get.back(),
      ),
      body: Obx(() {
        if (controller.isLoadingTemplates.value &&
            controller.fieldsData.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Lead Info (Form Fields)
              ...controller.formGroupsData.map((group) {
                final fields = group['fields'] as List? ?? [];
                final groupTitle = group['group_title'];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (groupTitle != null && groupTitle.toString().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
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
                        children: fields.map((fieldData) {
                          final field = Map<String, dynamic>.from(fieldData);
                          return controller.isHidden(field['field_visibility'])
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
                  "Follow-up History",
                  style: TextStyle(
                    color: colorManager.textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 12),
                ...followups.map((f) => _buildFollowupItem(f)).toList(),
                const SizedBox(height: 24),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildFollowupItem(Map<String, dynamic> followup) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorManager.secondaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorManager.secondaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  followup['title'] ?? "No Title",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                followup['time'] ?? "",
                style: TextStyle(
                  color: colorManager.primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            followup['description'] ?? "",
            style: TextStyle(
              color: colorManager.textColor.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
