import 'package:appex_lead/component/custom_appbar.dart';
import 'package:appex_lead/component/custom_button.dart';
import 'package:appex_lead/controller/form/generic_form_controller.dart';
import 'package:appex_lead/main.dart';
import 'package:appex_lead/utils/constants.dart';
import 'package:appex_lead/utils/custom_toast_messages.dart';
import 'package:appex_lead/utils/helpers.dart';
import 'package:appex_lead/view/form/form_field_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FormDetails extends StatefulWidget {
  final String url;
  final String title;
  final Map<String, dynamic>? draftData;

  const FormDetails({
    super.key,
    required this.url,
    this.draftData,
    required this.title,
  });

  @override
  State<FormDetails> createState() => _FormDetailsState();
}

class _FormDetailsState extends State<FormDetails> {
  final controller = Get.put(GenericFormController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.draftData != null) {
        controller.resumeDraft(widget.draftData!);
      } else {
        controller.clearSession();
      }
      controller.fetchTemplate(widget.url, forceRefresh: true);
    });
  }

  _isFormEmpty() {
    return controller.formValues.isNotEmpty &&
        controller.formValues.values.first != null;
  }

  @override
  void dispose() {
    // Explicitly delete the controller when leaving FormDetails
    // to ensure onClose is called and FocusNodes are disposed.
    // Use the tag if you started using them, otherwise this works for the singleton.
    Get.delete<GenericFormController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: CustomAppBar(
            title: widget.title,
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
            trailing: Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: IconButton(
                icon: Icon(Icons.info, color: colorManager.whiteColor),
                onPressed: () {
                  customPopup(
                    backgroundColor: colorManager.accentColor,
                    context: context,
                    title: 'Description',

                    content: Text(
                      controller.formModel?.description ??
                          "No description available",
                      style: primaryTextStyle.copyWith(
                        fontSize: 14,
                        color: colorManager.whiteColor,
                      ),
                    ),
                    showCancelBtn: false,
                    showConfrimBtn: false,
                  );
                },
              ),
            ),
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
              child: Form(
                key: controller.formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 0,
                        ),
                        children: controller.formGroupsData.map((group) {
                          final fields = group['fields'] as List? ?? [];
                          final groupTitle = group['group_title'];
                          final groupDescription =
                              group['group_description'] ?? '';
                          final groupIndex = controller.formGroupsData.indexOf(
                            group,
                          );

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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
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
                                          if (groupDescription.isNotEmpty)
                                            GestureDetector(
                                              onTap: () {
                                                customPopup(
                                                  backgroundColor:
                                                      colorManager.accentColor,
                                                  context: context,
                                                  title: 'Description',

                                                  content: Text(
                                                    groupDescription,

                                                    style: primaryTextStyle
                                                        .copyWith(
                                                          fontSize: 14,
                                                          color: colorManager
                                                              .whiteColor,
                                                        ),
                                                  ),
                                                  showCancelBtn: false,
                                                  showConfrimBtn: false,
                                                );
                                              },
                                              child: Icon(
                                                Icons.info,
                                                color:
                                                    colorManager.primaryColor,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        height: 2,
                                        width: 40,
                                        decoration: BoxDecoration(
                                          color: colorManager.primaryColor,
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
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
                                    color: colorManager.primaryColor
                                        .withOpacity(.3),
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(0),
                                    topRight: Radius.circular(18),
                                    bottomLeft: Radius.circular(18),
                                    bottomRight: Radius.circular(18),
                                  ),
                                  // color: Colors.grey.shade100,
                                ),
                                child: Column(
                                  children: [
                                    ...fields.map((fieldData) {
                                      final field = Map<String, dynamic>.from(
                                        fieldData,
                                      );
                                      return !controller.isFieldVisible(field)
                                          ? const SizedBox.shrink()
                                          : GenericFormFieldWidget(
                                              fieldData: field,
                                              controller: controller,
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
                        }).toList(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Obx(
                        () => Row(
                          spacing: 12,
                          children: [
                            Expanded(
                              child: CustomButton(
                                backgroundColor: colorManager.accentColor,
                                disabled: controller.isSubmitting.value,
                                onTap: () async {
                                  await controller.saveProgress();
                                  Get.back(); // Pop FormDetails
                                },
                                label: "Save Draft",
                              ),
                            ),
                            Expanded(
                              child: CustomButton(
                                // backgroundColor: coloman,
                                isLoading: controller.isSubmitting.value,
                                disabled: controller.isSubmitting.value,
                                onTap: () async {
                                  var res = await controller.submitForm(
                                    submissionURL:
                                        widget.draftData?['submission_url'],
                                  );
                                },
                                label: "Submit",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        Obx(() {
          if (controller.isSubmitting.value) {
            return Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 16),
                    Text(
                      "Submitting Form...",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }
}
