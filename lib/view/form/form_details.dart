import 'package:appex_lead/component/custom_appbar.dart';
import 'package:appex_lead/component/custom_button.dart';
import 'package:appex_lead/controller/form/generic_form_controller.dart';
import 'package:appex_lead/main.dart';
import 'package:appex_lead/utils/constants.dart';
import 'package:appex_lead/utils/custom_toast_messages.dart';
import 'package:appex_lead/view/form/form_field_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FormDetails extends StatefulWidget {
  final String url;
  final Map<String, dynamic>? draftData; // Optional data for resumption

  const FormDetails({super.key, required this.url, this.draftData});

  @override
  State<FormDetails> createState() => _FormDetailsState();
}

class _FormDetailsState extends State<FormDetails> {
  final controller = Get.put(GenericFormController());

  @override
  void initState() {
    super.initState();
    if (widget.draftData != null) {
      controller.resumeDraft(widget.draftData!);
    } else {
      controller.fetchTemplate(widget.url);
    }
  }

  _isFormEmpty() {
    return controller.formValues.isNotEmpty &&
        controller.formValues.values.first != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Form Details',
        onNavigateBack: () {
          // print(controller.formValues.values.first != null);
          if (false && !_isFormEmpty()) {
            customPopup(
              context: context,
              title: "Save Draft",
              message: "Do you want to save the draft?",
              onConfirm: () {
                controller.saveProgress();

                Get.back();
              },
              onCancel: () {},
            );
          } else {
            Get.back();
          }
        },
      ),
      body: Obx(() {
        if (controller.isLoadingTemplates.value &&
            controller.fieldsData.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          backgroundColor: colorManager.bgDark,
          color: colorManager.primaryColor,
          onRefresh: () =>
              controller.fetchTemplate(widget.url, forceRefresh: true),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.fieldsData.length,
                  itemBuilder: (context, i) {
                    final field = controller.fieldsData[i];
                    return controller.isHidden(field['field_visibility'])
                        ? SizedBox()
                        : GenericFormFieldWidget(
                            fieldData: field,
                            controller: controller,
                          );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  spacing: 12,
                  children: [
                    Expanded(
                      child: CustomButton(
                        backgroundColor: colorManager.accentColor,
                        onTap: () async {
                          await controller.saveProgress();
                          Get.back();
                        },
                        label: "Save Draft",
                      ),
                    ),
                    Expanded(
                      child: CustomButton(
                        onTap: () async {
                          await controller.submitForm(
                            submissionURL: widget.draftData?['submission_url'],
                          );
                          Get.back();
                        },
                        label: "Submit",
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
