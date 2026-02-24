import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class GenericFormController extends GetxController {
  // List of available form templates (Mocking API data)
  var availableTemplates = <Map<String, dynamic>>[].obs;
  var isLoadingTemplates = false.obs;

  // Track the current form being edited
  var currentFormTitle = "".obs;
  var fieldsData = <Map<String, dynamic>>[].obs;

  // Map to hold dynamic form values
  var formValues = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTemplates();
  }

  Future<void> fetchTemplates() async {
    isLoadingTemplates.value = true;
    try {
      // Mocking API delay
      await Future.delayed(const Duration(seconds: 1));
      availableTemplates.assignAll([
        {
          "title": "Visit Form",
          "fields": [
            {
              "field_name": "auto_visit_datetime",
              "field_text": "Auto Date & Time",
              "field_type": "datetime",
              "field_required": true,
              "field_auto_generated": true,
              "field_editable": false,
            },
            {
              "field_name": "auto_gps_location",
              "field_text": "Auto GPS Location",
              "field_type": "gps",
              "field_required": true,
              "field_auto_generated": true,
              "field_editable": false,
            },
            {
              "field_name": "hospital_setup_name",
              "field_text": "Hospital / Setup Name",
              "field_type": "select_with_add",
              "options": [
                "Aga Khan Hospital",
                "LNH Hospital",
                "Ziauddin Hospital",
                "South City Hospital",
                "Other",
              ],
              "field_required": true,
            },
            {
              "field_name": "contact_person_name",
              "field_text": "Contact Person Name",
              "field_type": "string",
              "field_required": true,
            },
          ],
        },
        {
          "title": "Client Feedback",
          "fields": [
            {
              "field_name": "client_name",
              "field_text": "Client Name",
              "field_type": "string",
              "field_required": true,
            },
            {
              "field_name": "rating",
              "field_text": "Rating (1-5)",
              "field_type": "select",
              "options": ["1", "2", "3", "4", "5"],
              "field_required": true,
            },
            {
              "field_name": "comments",
              "field_text": "Detailed Comments",
              "field_type": "string",
            },
          ],
        },
      ]);
    } catch (e) {
      debugPrint("Error fetching templates: $e");
    } finally {
      isLoadingTemplates.value = false;
    }
  }

  void selectTemplate(Map<String, dynamic> template) {
    currentFormTitle.value = template['title'];
    fieldsData.assignAll(List<Map<String, dynamic>>.from(template['fields']));

    // Check if we have saved progress for this specific title
    loadProgress();

    // If not loaded, initialize the defaults
    _initializeForm();
  }

  // Removed automatic initialize from onInit as it happens on selectTemplate

  void _initializeForm() {
    for (var field in fieldsData) {
      String name = field['field_name'] as String;

      // Only initialize if the value is currently null (not loaded from shared preferences)
      if (formValues[name] == null) {
        // Auto generate values if needed
        if (field['field_auto_generated'] == true) {
          if (field['field_type'] == 'datetime') {
            formValues[name] = DateFormat(
              'yyyy-MM-dd HH:mm:ss',
            ).format(DateTime.now());
          } else if (field['field_type'] == 'gps') {
            formValues[name] = "Fetching location...";
            _fetchLocation(name);
          }
        } else if (field['default_value'] != null) {
          // Handle pre-filled fixed defaults
          formValues[name] = field['default_value'];
        } else {
          // Initialize with null or empty
          formValues[name] = null;
        }
      }
    }
  }

  Future<void> _fetchLocation(String fieldName) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        updateFieldValue(fieldName, "Location Service Disabled");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          updateFieldValue(fieldName, "Permission Denied");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        updateFieldValue(fieldName, "Permission Denied Forever");
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      updateFieldValue(
        fieldName,
        "${position.latitude}, ${position.longitude}",
      );
    } catch (e) {
      updateFieldValue(fieldName, "Error fetching location");
      debugPrint("Location error: $e");
    }
  }

  void resetForm() {
    formValues.clear();

    _initializeForm();
  }

  // void setCurrentDraftId(String? id) {
  //   currentDraftId.value = id;
  // }

  void updateFieldValue(String fieldName, dynamic value) {
    formValues[fieldName] = value;
  }

  bool validateForm() {
    bool isValid = true;
    for (var field in fieldsData) {
      if (field['field_required'] == true) {
        String name = field['field_name'] as String;
        var value = formValues[name];

        if (value == null || (value is String && value.trim().isEmpty)) {
          isValid = false;
          Get.snackbar(
            "Validation Error",
            "${field['field_text']} is required.",
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
          break; // Stop at first error to prevent notification spam
        }
      }
    }
    return isValid;
  }

  Map<String, dynamic>? submitForm() {
    if (validateForm()) {
      debugPrint("Form Map: ${formValues.toString()}");

      Get.snackbar(
        "Success",
        "Form Validated Successfully!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

      // When successfully validated/submitted, delete it from local storage
      deleteProgress();

      // Return the key-value pair of the form data
      return Map<String, dynamic>.from(formValues);
    }
    return null;
  }

  // --- SharedPreferences Progress Saving (Per-Form Title) ---

  String get _storageKey => 'form_draft_${currentFormTitle.value}';

  Future<void> saveProgress() async {
    if (currentFormTitle.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();

      Map<String, dynamic> saveData = {
        'title': currentFormTitle.value,
        'timestamp': DateTime.now().toIso8601String(),
        'data': Map.from(formValues),
      };

      await prefs.setString(_storageKey, jsonEncode(saveData));
      debugPrint("Form progress saved locally with Key: $_storageKey");

      Get.snackbar(
        "Saved",
        "${currentFormTitle.value} progress saved successfully.",
        backgroundColor: Colors.blueAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      debugPrint("Error saving progress: $e");
    }
  }

  Future<void> loadProgress() async {
    if (currentFormTitle.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      String? savedJson = prefs.getString(_storageKey);

      if (savedJson != null && savedJson.isNotEmpty) {
        Map<String, dynamic> saveData = jsonDecode(savedJson);
        Map<String, dynamic> decodedData = saveData['data'];
        formValues.addAll(decodedData);
        debugPrint("Progress loaded successfully for Key: $_storageKey");
      }
    } catch (e) {
      debugPrint("Error loading progress: $e");
    }
  }

  Future<void> deleteProgress() async {
    if (currentFormTitle.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      debugPrint("Progress deleted for Key: $_storageKey");
    } catch (e) {
      debugPrint("Error clearing progress: $e");
    }
  }

  // Future method to retrieve list of all saved incomplete forms titles (for Listing)
  Future<List<String>> getSavedFormTitles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      Set<String> keys = prefs.getKeys();
      return keys
          .where((key) => key.startsWith('form_draft_'))
          .map((key) => key.replaceFirst('form_draft_', ''))
          .toList();
    } catch (e) {
      debugPrint("Error retrieving saved forms: $e");
    }
    return [];
  }

  Future<dio.FormData?> getFormData() async {
    if (!validateForm()) return null;

    Map<String, dynamic> map = {};

    for (var field in fieldsData) {
      String name = field['field_name'] as String;
      String type = field['field_type'] as String;
      var value = formValues[name];

      // Skip empty string or null values
      if (value == null || (value is String && value.isEmpty)) continue;

      if (type == 'camera') {
        // Assume value is a file path
        File file = File(value as String);
        if (await file.exists()) {
          // Wrap the path as a dio MultipartFile
          map[name] = await dio.MultipartFile.fromFile(
            file.path,
            filename: value.split(Platform.pathSeparator).last,
          );
        } else {
          debugPrint("Failed to find file at path: $value");
        }
      } else {
        map[name] = value.toString();
      }
    }

    return dio.FormData.fromMap(map);
  }
}
