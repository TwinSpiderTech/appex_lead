import 'package:appex_lead/component/custom_appbar.dart';
import 'package:appex_lead/controller/form/generic_form_controller.dart';
import 'package:appex_lead/main.dart';
import 'package:appex_lead/view/form/form_field_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FormShow extends StatefulWidget {
  final Map<String, dynamic> leadData;
  final String title;

  const FormShow({super.key, required this.leadData, required this.title});

  @override
  State<FormShow> createState() => _FormShowState();
}

class _FormShowState extends State<FormShow> {
  final controller = Get.put(GenericFormController());

  @override
  void initState() {
    super.initState();
    // Load the lead data into the controller
    controller.resumeDraft(widget.leadData);
  }

  @override
  Widget build(BuildContext context) {
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

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.formGroupsData.length,
                itemBuilder: (context, groupIndex) {
                  final group = controller.formGroupsData[groupIndex];
                  final fields = group['fields'] as List? ?? [];
                  final groupTitle = group['group_title'];

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
                                  letterSpacing: 0.5,
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
                          children: [
                            ...fields.map((fieldData) {
                              final field = Map<String, dynamic>.from(
                                fieldData,
                              );
                              return controller.isHidden(
                                    field['field_visibility'],
                                  )
                                  ? const SizedBox.shrink()
                                  : GenericFormFieldWidget(
                                      fieldData: field,
                                      controller: controller,
                                      isReadOnly: true, // Lock all fields
                                    );
                            }).toList(),
                            if (groupIndex <
                                controller.formGroupsData.length - 1)
                              const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}
