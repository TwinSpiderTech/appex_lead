import 'package:appex_lead/component/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/form/generic_form_controller.dart';
import '../../component/custom_button.dart';
import '../../main.dart'; // added for colorManager
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Please fill out the following details:",
                style: TextStyle(
                  color: colorManager.textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

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
                        // Save progress using the controller's internal ID tracking
                        controller.saveProgress();
                      },
                      label: "Save Draft",
                      // You might want to pass a backgroundColor that's secondary color in a real scenario
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      onTap: () {
                        final formData = controller.submitForm();
                        if (formData != null) {
                          debugPrint("RECEIVED FORM DATA:");
                          debugPrint(formData.toString());
                        }
                      },
                      label: "Submit Form",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
