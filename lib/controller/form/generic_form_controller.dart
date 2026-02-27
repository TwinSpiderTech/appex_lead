import 'dart:developer';
import 'dart:io';
import 'dart:convert';
// import 'dart:math';
import 'package:appex_lead/utils/custom_toast_messages.dart';
import 'package:appex_lead/utils/helpers.dart';
import 'package:appex_lead/utils/urls.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../../main.dart';
import '../../model/form_model.dart';
import '../../utils/auth_service.dart';

class GenericFormController extends GetxController {
  // List of available form templates (Mocking API data)
  var availableTemplates = <Map<String, dynamic>>[].obs;
  var isLoadingTemplates = false.obs;

  // Track the current form being edited
  var currentFormTitle = "".obs;
  var currentDraftId = "".obs; // Unique ID for each draft session
  var currentTemplateUrl = "".obs; // Store URL for re-fetching
  var currentSubmissionUrl = "".obs; // Store URL for re-fetching
  var fieldsData = <Map<String, dynamic>>[].obs;
  var formGroupsData = <Map<String, dynamic>>[].obs;
  FormModel? formModel;

  // Map to hold dynamic form values
  var formValues = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> fetchTemplate(
    String templateUrl, {
    bool forceRefresh = false,
  }) async {
    String url = Urls.base + validateURL(templateUrl);
    currentTemplateUrl.value = templateUrl;
    isLoadingTemplates.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'template_cache_${url.replaceAll("/", "_")}';

      if (!forceRefresh) {
        String? cached = prefs.getString(cacheKey);
        if (cached != null) {
          debugPrint("Loading template from cache: $cacheKey");
          final data = jsonDecode(cached);
          _applyTemplate(data);
          isLoadingTemplates.value = false;
          return;
        }
      }

      String token = await AuthService.getSessionToken() ?? '';
      var response = await api.getData(token, url);
      if (response != null && response['status'] == 200) {
        var data = dig(response, ['data']);
        await prefs.setString(cacheKey, jsonEncode(data));
        _applyTemplate(data);
      }
    } catch (e) {
      debugPrint("Error fetching template: $e");
    } finally {
      isLoadingTemplates.value = false;
    }
  }

  void _applyTemplate(Map<String, dynamic> data) {
    prettyPrint(data);
    try {
      formModel = FormModel.fromJson(data);
      currentFormTitle.value = formModel?.title ?? "";
      debugPrint("Applied Template: ${currentFormTitle.value}");
      currentSubmissionUrl.value = formModel?.submissionUrl ?? '';
      // Build groupList and flatFieldList while preserving order
      var groupList = <Map<String, dynamic>>[];
      var flatFieldList = <Map<String, dynamic>>[];

      List<Map<String, dynamic>> currentFieldBuffer = [];

      void flushBuffer() {
        if (currentFieldBuffer.isNotEmpty) {
          groupList.add({
            'group_title': null,
            'fields': List<Map<String, dynamic>>.from(currentFieldBuffer),
          });
          currentFieldBuffer.clear();
        }
      }

      if (formModel?.formElements != null) {
        for (var element in formModel!.formElements!) {
          if (element is FormFieldGroup) {
            flushBuffer(); // Before adding a titled group, flush any pending root fields

            var groupMap = element.toJson();
            groupList.add(groupMap);

            if (element.fields != null) {
              for (var f in element.fields!) {
                var fJson = f.toJson();
                if (!flatFieldList.any(
                  (e) => e['field_name'] == fJson['field_name'],
                )) {
                  flatFieldList.add(fJson);
                }
              }
            }
          } else if (element is FormFileds) {
            var fJson = element.toJson();
            currentFieldBuffer.add(fJson);

            if (!flatFieldList.any(
              (e) => e['field_name'] == fJson['field_name'],
            )) {
              flatFieldList.add(fJson);
            }
          }
        }
        flushBuffer(); // Final flush
      }

      fieldsData.assignAll(flatFieldList);
      formGroupsData.assignAll(groupList);
      debugPrint(
        "Fields loaded: ${fieldsData.length}, Groups: ${formGroupsData.length}",
      );

      // If we are starting a NEW form session (not resuming), initialize
      if (currentDraftId.isEmpty) {
        formValues.clear();
        _initializeForm();
      } else {
        // If resuming, just ensure any missing auto-generated fields are handled
        _initializeForm();
      }
    } catch (e) {
      debugPrint("Error applying template: $e");
    }
    update();
  }

  void selectTemplate(Map<String, dynamic> template) {
    // This is used for navigation from the forms list screen
    // We clear the draft ID to indicate a new session
    currentDraftId.value = "";
    _applyTemplate(template);
  }

  void clearSession() {
    currentDraftId.value = "";
    formValues.clear();
    fieldsData.clear();
    formGroupsData.clear();
    debugPrint("Form session cleared.");
  }

  void resumeDraft(Map<String, dynamic> draftData) {
    currentDraftId.value = (draftData['id'] ?? "").toString();
    currentFormTitle.value = (draftData['title'] ?? "").toString();

    // Load fields from draft
    if (draftData['fields'] != null) {
      fieldsData.assignAll(
        List<Map<String, dynamic>>.from(draftData['fields']),
      );
    }

    // Load groups if available, otherwise reconstruct a default group
    if (draftData['groups'] != null) {
      formGroupsData.assignAll(
        List<Map<String, dynamic>>.from(draftData['groups']),
      );
    } else if (fieldsData.isNotEmpty) {
      formGroupsData.assignAll([
        {'group_title': null, 'fields': fieldsData.toList()},
      ]);
    }

    // Load values
    if (draftData['values'] != null) {
      formValues.assignAll(Map<String, dynamic>.from(draftData['values']));
    }

    // Restore URL if present
    if (draftData['template_url'] != null) {
      currentTemplateUrl.value = draftData['template_url'];
    }

    // Ensure any auto-generated fields that might have been null/empty are handled
    _initializeForm();

    debugPrint("Resumed draft: ${currentDraftId.value}");
  }

  // Removed automatic initialize from onInit as it happens on selectTemplate

  bool _isTrue(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == "true" || value == "1";
    return false;
  }

  bool isHidden(value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == "hidden" || value == "1";
    return false;
  }

  void _initializeForm() {
    for (var field in fieldsData) {
      String name = (field['field_name'] ?? "").toString();
      if (name.isEmpty) continue;

      // Only initialize if the value is currently null
      if (formValues[name] == null) {
        // Auto generate values if needed
        if (_isTrue(field['field_auto_generated']) ||
            isHidden(field['field_visibility'])) {
          if (field['field_type'] == 'datetime') {
            formValues[name] = DateFormat(
              'yyyy-MM-dd - HH:mm:ss a',
            ).format(DateTime.now());
          } else if (field['field_type'] == 'gps') {
            formValues[name] = "Capture photo to update GPS";
          }
        } else if (field['field_default'] != null &&
            field['field_default'] != "") {
          // Handle pre-filled fixed defaults (note: field_default from API)
          formValues[name] = field['field_default'];
        } else {
          // Initialize with null or empty
          formValues[name] = null;
        }
      }
    }
  }

  void updateAllGpsFields() {
    for (var field in fieldsData) {
      String name = (field['field_name'] ?? "").toString();
      if (name.isNotEmpty && field['field_type'] == 'gps') {
        _fetchLocation(name);
      }
    }
  }

  Future<void> _fetchLocation(String fieldName) async {
    try {
      debugPrint("Fetching GPS for field: $fieldName");
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        updateFieldValue(fieldName, "Location Service Disabled");
        showToast(message: "Please enable Location Services");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          updateFieldValue(fieldName, "Permission Denied");
          showToast(message: "Location permission denied");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        updateFieldValue(fieldName, "Permission Denied Forever");
        showToast(
          message: "Location permission denied forever. Enable in settings.",
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      Map<String, dynamic> loc = {
        "latitude": position.latitude,
        "longitude": position.longitude,
        "accuracy": position.accuracy,
        "altitude": position.altitude,
        "altitudeAccuracy": position.altitudeAccuracy,
        "floor": position.floor,
        "heading": position.heading,
        "headingAccuracy": position.headingAccuracy,
        "speed": position.speed,
        "speedAccuracy": position.speedAccuracy,
        "timestamp": position.timestamp.toIso8601String(),
        "isMocked": position.isMocked,
      };
      prettyPrint(loc);
      Map<String, dynamic> latLong = {
        "latitude": position.latitude,
        "longitude": position.longitude,
      };
      // String locString = "${position.latitude}, ${position.longitude}";
      debugPrint("Location fetched: $latLong");
      updateFieldValue(fieldName, latLong);
    } catch (e) {
      updateFieldValue(fieldName, "Error fetching location");
      debugPrint("Location error: $e");
      showToast(message: "Failed to fetch GPS: ${e.toString()}");
    }
  }

  void resetForm() {
    formValues.clear();
    currentDraftId.value = "";
    _initializeForm();
  }

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

  Future<Map<String, dynamic>?> submitForm({String? submissionURL}) async {
    // print(submissionURL ?? formModel?.submissionUrl ?? 'no submission url');
    log("Submitting form data....");
    if (true || validateForm()) {
      // prettyPrint(formValues.toJson());

      var _data = await getFormData();
      print(_data);
      String url = Urls.base + validateURL(currentSubmissionUrl.value);
      log(url);
      Map<String, dynamic> data = {"business_lead": _data};

      var _formData = dio.FormData.fromMap(data);

      try {
        var res = await api.postData(url, formData: _formData);
        if (res != null) {
          prettyPrint(res);
          if (res['status'] == 200) {
            deleteProgress();
          }
          return Map<String, dynamic>.from(formValues);
        }
      } catch (e) {
        showToast(message: "Failed to submit form: ${e.toString()}");
        log(e.toString());
        return null;
      }

      // Get.snackbar(
      //   "Success",
      //   "Form Validated Successfully!",
      //   backgroundColor: Colors.green,
      //   colorText: Colors.white,
      //   snackPosition: SnackPosition.BOTTOM,
      // );

      // When successfully validated/submitted, delete it from local storage

      // Return the key-value pair of the form data
    }
    return null;
  }

  // --- SharedPreferences Progress Saving (Multiple Drafts) ---

  String get _storageKey {
    if (currentDraftId.isEmpty) return "";
    return 'form_draft_${currentDraftId.value}';
  }

  Future<void> saveProgress() async {
    if (currentFormTitle.value.isEmpty) {
      debugPrint("Cannot save draft: Form title is empty.");
      showToast(message: "Error: Form title is missing. Cannot save.");
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();

      // If we don't have a draft ID, create one
      if (currentDraftId.isEmpty) {
        currentDraftId.value =
            "${currentFormTitle.value}_${DateTime.now().millisecondsSinceEpoch}";
      }

      // Dynamically determine the draft title from form fields if possible
      String draftTitle = currentFormTitle.value;
      for (var field in fieldsData) {
        String name = (field['field_name'] ?? "").toString().toLowerCase();
        String text = (field['field_text'] ?? "").toString().toLowerCase();
        // Look for business name field
        if ((name.contains("business") && name.contains("name")) ||
            (text.contains("business") && text.contains("name"))) {
          var val = formValues[field['field_name']];
          if (val != null && val.toString().trim().isNotEmpty) {
            draftTitle = val.toString().trim();
            break;
          }
        }
      }

      // Save title, fields, groups, values, and timestamp
      Map<String, dynamic> saveData = {
        'id': currentDraftId.value,
        'title': draftTitle,
        'template_url': currentTemplateUrl.value,
        'submission_url': currentSubmissionUrl.value,
        'fields': fieldsData.toList(),
        'groups': formGroupsData.toList(),
        'values': Map<String, dynamic>.from(formValues),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await prefs.setString(_storageKey, jsonEncode(saveData));
      debugPrint("Draft saved locally with Key: $_storageKey");

      showToast(message: "Draft saved successfully!");

      // Get.snackbar(
      //   "Saved",
      //   "Draft saved successfully.",
      //   backgroundColor: Colors.blueAccent,
      //   colorText: Colors.white,
      //   snackPosition: SnackPosition.BOTTOM,
      //   duration: const Duration(seconds: 2),
      // );
    } catch (e) {
      debugPrint("Error saving progress: $e");
    }
  }

  Future<void> deleteProgress() async {
    if (currentDraftId.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      debugPrint("Progress deleted for Key: $_storageKey");
      update();
    } catch (e) {
      debugPrint("Error clearing progress: $e");
    }
  }

  // Future method to retrieve list of all saved drafts metadata
  Future<List<Map<String, dynamic>>> getSavedDrafts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      Set<String> keys = prefs.getKeys();
      List<Map<String, dynamic>> drafts = [];

      for (var key in keys) {
        if (key.startsWith('form_draft_')) {
          try {
            String? jsonStr = prefs.getString(key);
            if (jsonStr != null) {
              var decoded = jsonDecode(jsonStr);
              if (decoded is Map<String, dynamic>) {
                drafts.add(decoded);
              }
            }
          } catch (e) {
            debugPrint("Error decoding draft $key: $e");
          }
        }
      }

      // Sort by updated_at descending
      drafts.sort((a, b) {
        String timeA = a['updated_at']?.toString() ?? "";
        String timeB = b['updated_at']?.toString() ?? "";
        return timeB.compareTo(timeA);
      });
      return drafts;
    } catch (e) {
      debugPrint("Error retrieving saved forms: $e");
    }
    return [];
  }

  Future<Map<String, dynamic>?> getFormData() async {
    // Future<dio.FormData?> getFormData() async {
    if (!validateForm()) return null;

    Map<String, dynamic> map = {};

    for (var entry in formValues.entries) {
      String name = entry.key;
      var value = entry.value;

      // Skip empty string or null values
      if (value == null || (value is String && value.isEmpty)) continue;

      // Find field type from metadata
      String type = 'string';
      var fieldDef = fieldsData.firstWhere(
        (f) => f['field_name'] == name,
        orElse: () => <String, dynamic>{},
      );
      if (fieldDef.isNotEmpty) {
        type = (fieldDef['field_type'] ?? 'string').toString();
      }

      if (type == 'camera') {
        // Assume value is a file path for images
        File file = File(value.toString());
        if (await file.exists()) {
          map[name] = await dio.MultipartFile.fromFile(
            file.path,
            filename: file.path.split(Platform.pathSeparator).last,
          );
        } else {
          debugPrint("Failed to find file at path: $value");
        }
      } else {
        map[name] = value.toString();
      }
    }

    return map;
    // return dio.FormData.fromMap(map);
  }
}
