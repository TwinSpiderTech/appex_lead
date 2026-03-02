import 'dart:io';
import 'package:appex_lead/utils/helpers.dart';
import 'package:appex_lead/utils/validations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'image_preview_screen.dart';
import '../../controller/form/generic_form_controller.dart';
import '../../view/camera/camera_screen.dart';
import '../../component/custom_input_field.dart';
import '../../component/custom_searchable_dropdown.dart';
import '../../component/custom_searchable_dropdown2.dart';
import '../../component/custom_button.dart';
import '../../main.dart'; // for colorManager

class GenericFormFieldWidget extends StatelessWidget {
  final Map<String, dynamic> fieldData;
  final GenericFormController controller;
  final double borderRadius;
  final bool isReadOnly;

  const GenericFormFieldWidget({
    super.key,
    required this.fieldData,
    required this.controller,
    this.borderRadius = 12,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    String fieldType = fieldData['field_type'] ?? "string";
    bool isEditable = (fieldData['field_editable'] ?? true) && !isReadOnly;
    String fieldName = fieldData['field_name'] ?? "unknown";

    // debugPrint(
    //   "Building $fieldType: $fieldName (Editable: $isEditable) RawEditable: ${fieldData['field_editable']}",
    // );

    switch (fieldType) {
      case 'string':
        return _buildStringField(isEditable, TextInputType.text);
      case 'email':
        return _buildStringField(isEditable, TextInputType.emailAddress);
      case 'phone':
        return _buildStringField(isEditable, TextInputType.phone);
      case 'text':
        return _buildTextField(isEditable, TextInputType.text);
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
        return _buildStringField(isEditable, TextInputType.text);
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
                fieldData['field_text'] ?? '',
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

  Widget _buildStringField(bool isEditable, TextInputType keyboardType) {
    String fieldName = fieldData['field_name'] ?? "unknown";
    bool isRequired = controller.isTrue(fieldData['field_required']);
    Map<String, dynamic> config = Map<String, dynamic>.from(
      dig(fieldData, ['field_config']) ?? {},
    );
    int? maxLength = config['max_length'] != null
        ? int.tryParse(config['max_length'].toString())
        : null;
    int? minLength = config['min_length'] != null
        ? int.tryParse(config['min_length'].toString())
        : null;
    String regex = config['regax'] ?? '';

    return _buildWrapper(
      child: CustomInputField(
        isRequired: isRequired,
        minLength: minLength,
        maxLength: maxLength,
        type: keyboardType,
        enable: isEditable,
        borderRadius: borderRadius,
        validator: (value) {
          if (value != null && value.isNotEmpty && regex.isNotEmpty) {
            return Validations.isValidPattern(value, regex)
                ? null
                : "Invalid ${fieldData['field_text'] ?? toParameterize(fieldName)}";
          }
          return null;
        },
        initialValue: controller.formValues[fieldName]?.toString(),
        onChanged: (val) => controller.updateFieldValue(fieldName, val),
        hint: "Enter ${fieldData['field_text'] ?? fieldName}",
      ),
    );
  }

  Widget _buildTextField(bool isEditable, TextInputType keyboardType) {
    String fieldName = fieldData['field_name'] ?? "unknown";

    bool isRequired = controller.isTrue(fieldData['field_required']);
    Map<String, dynamic> config = Map<String, dynamic>.from(
      dig(fieldData, ['field_config']) ?? {},
    );
    int? maxLength = config['max_length'] != null
        ? int.tryParse(config['max_length'].toString())
        : null;
    int? minLength = config['min_length'] != null
        ? int.tryParse(config['min_length'].toString())
        : null;
    String regex = config['regax'] ?? '';

    return _buildWrapper(
      child: CustomInputField(
        isRequired: isRequired,
        minLength: minLength,
        maxLength: maxLength,
        maxLine: 4,
        type: keyboardType,
        enable: isEditable,
        borderRadius: borderRadius,
        validator: (value) {
          if (value != null && value.isNotEmpty && regex.isNotEmpty) {
            return Validations.isValidPattern(value, regex)
                ? null
                : "Invalid ${fieldData['field_text'] ?? toParameterize(fieldName)}";
          }
          return null;
        },
        initialValue: controller.formValues[fieldName]?.toString(),
        onChanged: (val) => controller.updateFieldValue(fieldName, val),
        hint: "Enter ${fieldData['field_text'] ?? fieldName}",
      ),
    );
  }

  Widget _buildDropdownField(bool isEditable) {
    String fieldName = fieldData['field_name'] ?? "unknown";
    var rawOptions =
        fieldData['field_options'] ??
        fieldData['options'] ??
        fieldData['choices'];

    return _buildWrapper(
      child: Obx(() {
        var currentValue = controller.formValues[fieldName];

        if (rawOptions is Map) {
          Map<String, dynamic> optionsMap = Map<String, dynamic>.from(
            rawOptions,
          );
          return CustomSearchableDropdown2(
            items: optionsMap,
            enabled: isEditable,
            allowCustomValue: true,
            // fieldType == 'select_with_add' || fieldType == 'select_or_auto',
            selectedValue: currentValue?.toString(),
            label: fieldData['field_text'] ?? fieldName,
            borderRadius: borderRadius,
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
        }

        List<String> options = [];
        if (rawOptions is List) {
          options = List<String>.from(rawOptions.map((e) => e.toString()));
        } else if (rawOptions is String && rawOptions.isNotEmpty) {
          options = rawOptions.split(',').map((e) => e.trim()).toList();
        }

        return CustomSearchableDropdown(
          items: options,
          enabled: isEditable, // Pass enablement here
          allowCustomValue: true,
          selectedValue: currentValue is String ? currentValue : null,
          label: fieldData['field_text'] ?? fieldName,
          borderRadius: borderRadius,
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
    Map<String, dynamic> config = Map<String, dynamic>.from(
      dig(fieldData, ['field_config']) ?? {},
    );
    DateTime minDate = DateTime.now().add(
      Duration(days: config['min_date'] ?? -1),
    );
    DateTime maxDate = DateTime.now().add(
      Duration(days: config['max_date'] ?? 365),
    );

    return _buildWrapper(
      child: InkWell(
        onTap: isEditable
            ? () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: minDate,
                  lastDate: maxDate,
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
                        DateFormat('yyyy-MM-dd hh:mm:ss a').format(dt),
                      );
                    }
                  }
                }
              }
            : null,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.only(
            left: 18,
            right: 18,
            top: 15,
            bottom: 15,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: colorManager.secondaryColor),
            borderRadius: BorderRadius.circular(borderRadius),
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
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.blueAccent),
            const SizedBox(width: 8),
            Expanded(
              child: Obx(() {
                var val = controller.formValues[fieldName];
                String displayValue = "Getting location...";

                if (val is Map) {
                  double? lat = val['latitude'];
                  double? lng = val['longitude'];
                  String? address = val['position'] ?? val['address'];
                  if (lat != null && lng != null) {
                    displayValue = address ?? "";
                    //     "Lat: ${lat.toStringAsFixed(4)}, Long: ${lng.toStringAsFixed(4)}";
                    // if (address != null && address.isNotEmpty) {
                    //   displayValue += "\n$address";
                    // }
                  }
                } else if (val != null) {
                  displayValue = val.toString();
                } else {
                  // Fallback for null
                  displayValue = controller.hasCameraField()
                      ? "Capture photo to update GPS"
                      : "Fetching GPS automatically...";
                }

                return Text(
                  displayValue,
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
                  child: GestureDetector(
                    onTap: () {
                      Get.to(
                        () => ImagePreviewScreen(
                          imagePath: imagePath,
                          title: fieldData['field_text'] ?? "Image Preview",
                        ),
                      );
                    },
                    child: Hero(
                      tag: imagePath,
                      child: imagePath.startsWith('http')
                          ? Image.network(
                              imagePath,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              alignment: Alignment.bottomCenter,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image, size: 50),
                            )
                          : Image.file(
                              File(imagePath),
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              alignment: Alignment.bottomCenter,
                            ),
                    ),
                  ),
                ),
              ),
            if (isEditable) // Hide buttons if not editable
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  onTap: () async {
                    final result = await Get.to(
                      () => CameraScreen(
                        usedOnForm: true,
                        onProcessed: (path) {
                          debugPrint("Background processing done: $path");
                          controller.updateFieldValue(fieldName, path);
                          controller.updateAllGpsFields();
                        },
                      ),
                    );
                    if (result != null && result is String) {
                      controller.updateFieldValue(fieldName, result);
                      controller.updateAllGpsFields();
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
