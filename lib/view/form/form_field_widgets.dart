import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controller/form/generic_form_controller.dart';
import '../../view/camera/camera_screen.dart';
import '../../component/custom_input_field.dart';
import '../../component/custom_searchable_dropdown.dart';
import '../../component/custom_button.dart';
import '../../main.dart'; // for colorManager

class GenericFormFieldWidget extends StatelessWidget {
  final Map<String, dynamic> fieldData;
  final GenericFormController controller;

  const GenericFormFieldWidget({
    super.key,
    required this.fieldData,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    String fieldType = fieldData['field_type'] ?? "string";
    bool isEditable = fieldData['field_editable'] ?? true;
    String fieldName = fieldData['field_name'] ?? "unknown";

    // debugPrint(
    //   "Building $fieldType: $fieldName (Editable: $isEditable) RawEditable: ${fieldData['field_editable']}",
    // );

    switch (fieldType) {
      case 'string':
        return _buildStringField(isEditable);
      case 'text':
        return _buildTextField(isEditable);
      case 'select':
      case 'dropdown':
      case 'select_with_add':
      case 'select_or_auto':
        return _buildDropdownField(isEditable);
      case 'datetime':
      case 'date':
        return _buildDateTimeField(context, isEditable);
      case 'gps':
        return _buildGpsField();
      case 'camera':
        return _buildCameraField(isEditable);
      default:
        // Assume anything else might be a custom type that defaults to string behavior
        return _buildStringField(isEditable);
    }
  }

  Widget _buildWrapper({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                fieldData['field_text'],
                style: TextStyle(
                  color: colorManager.textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              if (fieldData['field_required'] == true)
                const Text(" *", style: TextStyle(color: Colors.red)),
            ],
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }

  Widget _buildStringField(bool isEditable) {
    String fieldName = fieldData['field_name'] ?? "unknown";

    return _buildWrapper(
      child: CustomInputField(
        enable: isEditable,
        initialValue: controller.formValues[fieldName]?.toString(),
        onChanged: (val) => controller.updateFieldValue(fieldName, val),
        hint: "Enter ${fieldData['field_text'] ?? fieldName}",
      ),
    );
  }

  Widget _buildTextField(bool isEditable) {
    String fieldName = fieldData['field_name'] ?? "unknown";

    return _buildWrapper(
      child: CustomInputField(
        maxLine: 4,
        enable: isEditable,
        initialValue: controller.formValues[fieldName]?.toString(),
        onChanged: (val) => controller.updateFieldValue(fieldName, val),
        hint: "Enter ${fieldData['field_text'] ?? fieldName}",
      ),
    );
  }

  Widget _buildDropdownField(bool isEditable) {
    String fieldName = fieldData['field_name'] ?? "unknown";
    List<String> options = List<String>.from(fieldData['options'] ?? []);

    return _buildWrapper(
      child: Obx(() {
        var currentValue = controller.formValues[fieldName];

        return CustomSearchableDropdown(
          items: options,
          enabled: isEditable, // Pass enablement here
          selectedValue:
              currentValue is String && options.contains(currentValue)
              ? currentValue
              : null,
          label: fieldData['field_text'] ?? fieldName,
          borderRadius: 30,
          padding: const EdgeInsets.only(
            left: 24,
            right: 24,
            top: 18,
            bottom: 18,
          ),
          onChange: (val) {
            controller.updateFieldValue(fieldName, val);
          },
        );
      }),
    );
  }

  Widget _buildDateTimeField(BuildContext context, bool isEditable) {
    String fieldName = fieldData['field_name'] ?? "unknown";
    bool isDateOnly = fieldData['field_type'] == 'date';

    return _buildWrapper(
      child: InkWell(
        onTap: isEditable
            ? () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );

                if (pickedDate != null) {
                  if (isDateOnly) {
                    controller.updateFieldValue(
                      fieldName,
                      DateFormat('yyyy-MM-dd').format(pickedDate),
                    );
                  } else {
                    if (!context.mounted) return;
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      final dt = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                      controller.updateFieldValue(
                        fieldName,
                        DateFormat('yyyy-MM-dd HH:mm:ss').format(dt),
                      );
                    }
                  }
                }
              }
            : null,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.only(
            left: 24,
            right: 24,
            top: 18,
            bottom: 18,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: colorManager.secondaryColor),
            borderRadius: BorderRadius.circular(30),
            color: isEditable
                ? Colors.transparent
                : colorManager.primaryColor.withAlpha(25),
          ),
          child: Obx(() {
            var val = controller.formValues[fieldName];
            return Text(
              val?.toString() ?? "Select ${fieldData['field_text']}",
              style: TextStyle(
                color: val == null
                    ? Colors.grey.shade500
                    : colorManager.textColor,
                fontSize: 12,
                fontWeight: val == null ? FontWeight.w300 : FontWeight.normal,
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildGpsField() {
    String fieldName = fieldData['field_name'];

    return _buildWrapper(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(
          left: 24,
          right: 24,
          top: 18,
          bottom: 18,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: colorManager.secondaryColor),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.blueAccent),
            const SizedBox(width: 8),
            Expanded(
              child: Obx(() {
                var val = controller.formValues[fieldName];
                return Text(
                  val?.toString() ?? "Getting location...",
                  style: TextStyle(color: colorManager.textColor),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraField(bool isEditable) {
    String fieldName = fieldData['field_name'] ?? "unknown";

    return _buildWrapper(
      child: Obx(() {
        var imagePath = controller.formValues[fieldName] as String?;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imagePath != null && imagePath.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(imagePath),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            if (isEditable) // Hide buttons if not editable
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  onTap: () async {
                    final result = await Get.to(() => CameraScreen());
                    if (result != null && result is String) {
                      controller.updateFieldValue(fieldName, result);
                    }
                  },
                  label: imagePath == null ? "Capture Photo" : "Retake Photo",
                ),
              ),
          ],
        );
      }),
    );
  }
}
