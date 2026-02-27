import 'package:appex_lead/component/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/form/generic_form_controller.dart';
import '../../component/custom_button.dart';
import '../../main.dart';
import 'form_field_widgets.dart';

class GenericFormScreen extends StatelessWidget {
  GenericFormScreen({super.key});

  final GenericFormController controller = Get.put(GenericFormController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorManager.bgDark,
      appBar: CustomAppBar(),
      body: SafeArea(
        child: Obx(() {
          if (controller.currentFormTitle.isEmpty) {
            return Center(
              child: Text(
                "No form selected",
                style: TextStyle(color: colorManager.textColor),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.currentFormTitle.value,
                  style: TextStyle(
                    color: colorManager.primaryColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Please fill out the following details:",
                  style: TextStyle(color: colorManager.textColor, fontSize: 16),
                ),
                const SizedBox(height: 24),

                // Map entirely via the JSON structure
                ...controller.fieldsData.map((fieldData) {
                  return GenericFormFieldWidget(
                    fieldData: fieldData,
                    controller: controller,
                  );
                }),

                const SizedBox(height: 32),

                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        onTap: () {
                          controller.saveProgress();
                        },
                        label: "Save Draft",
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomButton(
                        onTap: () {
                          final formData = controller.submitForm();
                          // if (formData != null) {
                          //   debugPrint("RECEIVED FORM DATA:");
                          //   debugPrint(formData.toString());
                          // }
                        },
                        label: "Submit Form",
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),
          );
        }),
      ),
    );
  }
}
