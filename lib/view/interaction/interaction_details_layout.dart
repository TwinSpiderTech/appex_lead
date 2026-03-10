import 'package:appex_lead/component/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/interaction/interaction_form_controller.dart';
import '../../main.dart';
import '../../model/lead_model.dart';
import '../form/form_field_widgets.dart';

class InteractionDetailsLayout extends StatefulWidget {
  final Followup followup;
  final String? leadTitle;

  const InteractionDetailsLayout({
    super.key,
    required this.followup,
    this.leadTitle,
  });

  @override
  State<InteractionDetailsLayout> createState() =>
      _InteractionDetailsLayoutState();
}

class _InteractionDetailsLayoutState extends State<InteractionDetailsLayout> {
  final controller = Get.put(InteractionFormController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.clearSession();
      // Resume from rawData if available, otherwise fallback to basic followup data
      final data =
          widget.followup.rawData ??
          {
            'title': widget.followup.title,
            'description': widget.followup.description,
            'updated_at': widget.followup.time,
          };

      // If template_url is in rawData, fetch it
      final templateUrl =
          data['template_url'] ?? (data['FOLLOWUP']?['template_url']);

      controller.resumeDraft(data);

      if (templateUrl != null) {
        controller.fetchTemplate(templateUrl.toString());
      }
    });
  }

  @override
  void dispose() {
    Get.delete<InteractionFormController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorManager.whiteColor,
      appBar: CustomAppBar(
        title: widget.followup.title ?? "Interaction Details",
      ),
      body: Obx(() {
        if (controller.isLoadingTemplates.value &&
            controller.fieldsData.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            ...controller.formGroupsData.map((group) {
              final fields = group['fields'] as List? ?? [];
              final groupTitle = group['group_title'] ?? "Information";

              // Filter out hidden fields
              final visibleFields = fields
                  .where((f) => !controller.isHidden(f['field_visibility']))
                  .toList();

              if (visibleFields.isEmpty) return const SizedBox.shrink();

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: colorManager.secondaryColor.withOpacity(0.2),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 16),
                child: ExpansionTile(
                  initiallyExpanded: true,
                  title: Text(
                    groupTitle.toString(),
                    style: TextStyle(
                      color: colorManager.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  childrenPadding: const EdgeInsets.all(16),
                  children: visibleFields.map((fieldData) {
                    return GenericFormFieldWidget(
                      fieldData: Map<String, dynamic>.from(fieldData),
                      controller: controller,
                      isReadOnly: true,
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          ],
        );
      }),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorManager.accentColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorManager.accentColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.leadTitle != null) ...[
            Text(
              "Lead",
              style: TextStyle(
                color: colorManager.textColor.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
            Text(
              widget.leadTitle!,
              style: TextStyle(
                color: colorManager.textColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 14,
                color: colorManager.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                widget.followup.time ?? "N/A",
                style: TextStyle(
                  color: colorManager.textColor.withOpacity(0.7),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
