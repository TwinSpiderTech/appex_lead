import 'dart:io';
import 'package:appex_lead/component/custom_searchable_dropdown.dart';
import 'package:appex_lead/utils/helpers.dart';
import 'package:appex_lead/utils/validations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'image_preview_screen.dart';
import '../../view/camera/camera_screen.dart';
import 'package:appex_lead/component/custom_input_field.dart';
import 'package:appex_lead/component/custom_checkbox_field.dart';
import '../../component/custom_searchable_dropdown2.dart';
import 'package:appex_lead/component/custom_button.dart';
import '../../main.dart'; // for colorManager

class GenericFormFieldWidget extends StatelessWidget {
  final Map<String, dynamic> fieldData;
  final dynamic controller;
  final double borderRadius;
  final FocusNode? focusNode;
  final bool isReadOnly;

  const GenericFormFieldWidget({
    super.key,
    required this.fieldData,
    required this.controller,
    this.borderRadius = 12,
    this.isReadOnly = false,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    String fieldType = fieldData['field_type'] ?? "string";
    bool isEditable = (fieldData['field_editable'] ?? true) && !isReadOnly;
    String fieldName = fieldData['field_name'] ?? "unknown";
    String fieldMessage = dig(fieldData, ['field_config', 'message']) ?? "";
    String fieldHint =
        dig(fieldData, ['field_config', 'placeholder']) ??
        "Enter ${fieldData['field_text'] ?? fieldName}";

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

    switch (fieldType) {
      case 'string':
        return _buildStringField(
          isEditable,
          TextInputType.text,
          fieldName,
          minLength,
          maxLength,
          fieldMessage,
          regex,
          fieldHint,
        );
      case 'email':
        return _buildStringField(
          isEditable,
          TextInputType.emailAddress,
          fieldName,
          minLength,
          maxLength,
          fieldMessage,
          regex,
          fieldHint,
        );
      case 'phone':
        return _buildStringField(
          isEditable,
          TextInputType.phone,
          fieldName,
          minLength,
          maxLength,
          fieldMessage,
          regex,
          fieldHint,
        );
      case 'text':
        return _buildTextField(
          isEditable,
          TextInputType.text,
          fieldName,
          minLength,
          maxLength,
          fieldMessage,
          regex,
          fieldHint,
        );
      case 'select':
      case 'dropdown':
      case 'creatable_dropdown':
      case 'select_with_add':
      case 'select_or_auto':
        return _buildDropdownField(
          isEditable,
          fieldName,
          fieldMessage,
          fieldHint,
        );
      case 'datetime':
      case 'date':
        return _buildDateTimeField(
          context,
          isEditable,
          fieldName,
          fieldMessage,
          config,
          fieldHint,
        );
      case 'checkbox':
      case 'checkbox_group':
        return _buildCheckboxFieldMap(isEditable, fieldName, fieldMessage);

      case 'gps':
        return _buildGpsField(fieldName, fieldMessage);
      case 'camera':
        return _buildCameraField(isEditable, fieldName, fieldMessage);
      default:
        return _buildStringField(
          isEditable,
          TextInputType.text,
          fieldName,
          minLength,
          maxLength,
          fieldMessage,
          regex,
          fieldHint,
        );
    }
  }

  Widget _buildWrapper({
    required Widget child,
    String fieldName = "",
    String fieldMessage = "",
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                fieldData['field_text'] ?? '',
                style: primaryTextStyle.copyWith(
                  color: colorManager.textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Obx(
                () => controller.isFieldRequired(fieldData)
                    ? const Text(" *", style: TextStyle(color: Colors.red))
                    : const SizedBox.shrink(),
              ),
            ],
          ),
          const SizedBox(height: 6),
          child,
          Obx(() {
            final error = controller.errors[fieldName];
            if (error != null && error.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.only(top: 4.0, left: 4.0),
                child: Text(
                  error,
                  style: const TextStyle(color: Colors.red, fontSize: 11),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          if (fieldMessage.isNotEmpty) const SizedBox(height: 6),
          if (fieldMessage.isNotEmpty)
            Text(
              fieldMessage,
              style: primaryTextStyle.copyWith(
                color: colorManager.textColor.withOpacity(0.6),
                fontSize: 10,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStringField(
    bool isEditable,
    TextInputType keyboardType,
    String fieldName,
    int? minLength,
    int? maxLength,
    String fieldMessage,
    String regex,
    String fieldHint,
  ) {
    return _buildWrapper(
      fieldName: fieldName,
      fieldMessage: fieldMessage,
      child: Obx(() {
        String? value = controller.formValues[fieldName]?.toString();
        bool isRequired = controller.isFieldRequired(fieldData);
        return CustomInputField(
          focusNode: controller.getOrCreateFocusNode(fieldName),
          key: isEditable
              ? ValueKey(fieldName)
              : ValueKey("${fieldName}_${value ?? ''}_$isRequired"),
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
          initialValue: value,
          onChanged: (val) => controller.updateFieldValue(fieldName, val),
          hint: fieldHint,
        );
      }),
    );
  }

  Widget _buildTextField(
    bool isEditable,
    TextInputType keyboardType,
    String fieldName,
    int? minLength,
    int? maxLength,
    String fieldMessage,
    String regex,
    String fieldHint,
  ) {
    return _buildWrapper(
      fieldName: fieldName,
      fieldMessage: fieldMessage,
      child: Obx(() {
        String? value = controller.formValues[fieldName]?.toString();
        bool isRequired = controller.isFieldRequired(fieldData);
        return CustomInputField(
          focusNode: controller.getOrCreateFocusNode(fieldName),
          key: isEditable
              ? ValueKey(fieldName)
              : ValueKey("${fieldName}_${value ?? ''}_$isRequired"),
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
          initialValue: value,
          onChanged: (val) => controller.updateFieldValue(fieldName, val),

          hint: fieldHint,
        );
      }),
    );
  }

  Widget _buildDropdownField(
    bool isEditable,
    String fieldName,
    String fieldMessage,
    String fieldHint,
  ) {
    var rawOptions =
        fieldData['field_options'] ??
        fieldData['options'] ??
        fieldData['choices'];

    return _buildWrapper(
      fieldName: fieldName,
      fieldMessage: fieldMessage,
      child: Obx(() {
        var currentValue = controller.formValues[fieldName];

        if (rawOptions is Map) {
          Map<String, dynamic> optionsMap = Map<String, dynamic>.from(
            rawOptions,
          );
          return CustomSearchableDropdown2(
            focusNode: controller.getOrCreateFocusNode(fieldName),
            items: optionsMap,
            enabled: isEditable,
            allowCustomValue: fieldData['field_type'] == 'creatable_dropdown',
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
          hint: fieldHint,
          focusNode: controller.getOrCreateFocusNode(fieldName),
          items: options,
          enabled: isEditable, // Pass enablement here
          allowCustomValue: fieldData['field_type'] == 'creatable_dropdown',
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

  Widget _buildDateTimeField(
    BuildContext context,
    bool isEditable,
    String fieldName,
    String fieldMessage,
    Map<String, dynamic> config,
    String fieldHint,
  ) {
    bool isDateOnly = fieldData['field_type'] == 'date';

    // Use num.tryParse to handle doubles or ints, default to 0 and 30 for safety
    int minDays = (num.tryParse(config['min_date']?.toString() ?? '') ?? 0)
        .toInt();
    int maxDays = (num.tryParse(config['max_date']?.toString() ?? '') ?? 30)
        .toInt();

    DateTime now = DateTime.now();
    // Normalize to start of day to avoid time-of-day edge cases in picker
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime minDate = today.add(Duration(days: minDays));
    DateTime maxDate = today.add(Duration(days: maxDays));

    // Ensure minDate is before or equal to maxDate
    if (minDate.isAfter(maxDate)) {
      maxDate = minDate.add(const Duration(days: 1));
    }

    return _buildWrapper(
      fieldName: fieldName,
      fieldMessage: fieldMessage,
      child: InkWell(
        focusNode: controller.getOrCreateFocusNode(fieldName),
        onTap: isEditable
            ? () async {
                // Get current value from controller
                var currentVal = controller.formValues[fieldName];
                DateTime initial = today;

                if (currentVal != null && currentVal.toString().isNotEmpty) {
                  try {
                    if (isDateOnly) {
                      initial = DateFormat(
                        'yyyy-MM-dd',
                      ).parse(currentVal.toString());
                    } else {
                      initial = DateFormat(
                        'dd MMM, yyyy - hh:mm a',
                      ).parse(currentVal.toString());
                    }
                  } catch (e) {
                    debugPrint("Error parsing date for picker: $e");
                  }
                }

                // Clamp initial date within range to prevent Flutter crash/hang
                if (initial.isBefore(minDate)) initial = minDate;
                if (initial.isAfter(maxDate)) initial = maxDate;

                DateTime? pickedDate = await showCustomDatePicker(
                  context: context,
                  initialDate: initial,
                  firstDate: minDate,
                  lastDate: maxDate,
                );

                if (pickedDate != null) {
                  if (isDateOnly) {
                    controller.updateFieldValue(
                      fieldName,
                      formatDateToString(pickedDate),
                    );
                  } else {
                    if (!context.mounted) return;

                    // Try to get existing time if available
                    TimeOfDay initialTime = TimeOfDay.now();
                    if (currentVal != null &&
                        currentVal.toString().isNotEmpty) {
                      try {
                        DateTime dt = DateFormat(
                          'dd MMM, yyyy - hh:mm a',
                        ).parse(currentVal.toString());
                        initialTime = TimeOfDay.fromDateTime(dt);
                      } catch (_) {}
                    }

                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: initialTime,
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
                        previewableDateTimeFormat(dt),
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
              val?.toString() ?? fieldHint,
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

  Widget _buildCheckboxField(
    bool isEditable,
    String fieldName,
    String fieldMessage,
  ) {
    var rawOptions =
        fieldData['field_options'] ??
        fieldData['options'] ??
        fieldData['choices'];

    List<String> options = [];
    if (rawOptions is List) {
      options = List<String>.from(rawOptions.map((e) => e.toString()));
    } else if (rawOptions is String && rawOptions.isNotEmpty) {
      options = rawOptions.split(',').map((e) => e.trim()).toList();
    }

    return _buildWrapper(
      fieldName: fieldName,
      fieldMessage: fieldMessage,
      child: Focus(
        focusNode: controller.getOrCreateFocusNode(fieldName),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: colorManager.secondaryColor),
            borderRadius: BorderRadius.circular(borderRadius),
            color: isEditable
                ? Colors.transparent
                : colorManager.primaryColor.withAlpha(25),
          ),
          child: Obx(() {
            var rawValue = controller.formValues[fieldName];
            List<String> currentSelections = [];

            if (rawValue is List) {
              currentSelections = List<String>.from(
                rawValue.map((e) => e.toString()),
              );
            } else if (rawValue is String && rawValue.isNotEmpty) {
              // Trim brackets just in case it's saved as a stringified list like "[A, B]"
              String cleanVal = rawValue
                  .replaceAll('[', '')
                  .replaceAll(']', '');
              currentSelections = cleanVal
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();
            }

            if (options.isEmpty) {
              return Text(
                "No options available",
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              );
            }

            return Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: options.map((option) {
                final isSelected = currentSelections.contains(option);
                return GestureDetector(
                  onTap: isEditable
                      ? () {
                          List<String> newSelections = List.from(
                            currentSelections,
                          );
                          if (isSelected) {
                            newSelections.remove(option);
                          } else {
                            newSelections.add(option);
                          }
                          // Update form values with the new List of strings
                          controller.updateFieldValue(fieldName, newSelections);
                        }
                      : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorManager.primaryColor.withOpacity(0.08)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? colorManager.primaryColor
                            : colorManager.secondaryColor,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSelected
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: isSelected
                              ? colorManager.primaryColor
                              : colorManager.textColor.withOpacity(0.5),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          option,
                          style: primaryTextStyle.copyWith(
                            color: isSelected
                                ? colorManager.primaryColor
                                : colorManager.textColor,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildCheckboxFieldMap(
    bool isEditable,
    String fieldName,
    String fieldMessage,
  ) {
    var rawOptions =
        fieldData['field_options'] ??
        fieldData['options'] ??
        fieldData['choices'];

    Map<String, dynamic> optionsMap = {};
    if (rawOptions is Map) {
      optionsMap = Map<String, dynamic>.from(rawOptions);
    }

    return _buildWrapper(
      fieldMessage: fieldMessage,
      child: Obx(() {
        var rawValue = controller.formValues[fieldName];
        List<String> currentSelections = [];

        if (rawValue is List) {
          currentSelections = List<String>.from(
            rawValue.map((e) => e.toString()),
          );
        } else if (rawValue is String && rawValue.isNotEmpty) {
          String cleanVal = rawValue.replaceAll('[', '').replaceAll(']', '');
          currentSelections = cleanVal
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
        }

        return CustomCheckboxField(
          focusNode: controller.getOrCreateFocusNode(fieldName),
          items: optionsMap,
          initialSelections: currentSelections,
          enabled: isEditable,
          label: fieldData['field_text'] ?? fieldName,
          borderRadius: borderRadius,
          onChange: (newSelections) {
            controller.updateFieldValue(fieldName, newSelections);
          },
        );
      }),
    );
  }

  Widget _buildGpsField(String fieldName, String fieldMessage) {
    return _buildWrapper(
      fieldName: fieldName,
      fieldMessage: fieldMessage,
      child: Focus(
        focusNode: controller.getOrCreateFocusNode(fieldName),
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
                    }
                  } else if (val != null) {
                    displayValue = val.toString();
                  } else {
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
      ),
    );
  }

  Widget _buildCameraField(
    bool isEditable,
    String fieldName,
    String fieldMessage,
  ) {
    return _buildWrapper(
      fieldName: fieldName,
      fieldMessage: fieldMessage,
      child: Obx(() {
        var imagePath = controller.formValues[fieldName] as String?;

        return Focus(
          focusNode: controller.getOrCreateFocusNode(fieldName),
          child: Column(
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
              if (isEditable)
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
                            controller.updateAllTimestampFields();
                          },
                        ),
                      );
                      if (result != null && result is String) {
                        controller.updateFieldValue(fieldName, result);
                        controller.updateAllGpsFields();
                        controller.updateAllTimestampFields();
                      }
                    },
                    label: imagePath == null ? "Capture Photo" : "Retake Photo",
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
