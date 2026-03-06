import 'dart:developer';
import 'dart:io';
import 'dart:convert';
// import 'dart:math';
import 'package:appex_lead/utils/custom_toast_messages.dart';
import 'package:appex_lead/utils/helpers.dart';
import 'package:appex_lead/utils/urls.dart';
import 'package:geocoding/geocoding.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../../main.dart';
import '../../model/form_model.dart';
import '../../utils/auth_service.dart';

import '../dash/dash_controller.dart';
import '../lead/lead_controller.dart';

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
  Rx<Map<String, dynamic>?> currentLead = Rx<Map<String, dynamic>?>(null);

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
    // prettyPrint(data);
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
      // prettyPrint(formGroupsData);
      debugPrint(
        "Fields loaded: ${fieldsData.length}, Groups: ${formGroupsData.length}",
      );

      // If we are starting a NEW form session (not resuming), initialize
      if (currentDraftId.isEmpty && currentLead.value == null) {
        formValues.clear();
        _initializeForm();
      } else {
        // If resuming or viewing a lead, just ensure any missing auto-generated fields are handled
        _initializeForm();

        // Re-apply lead data if needed to ensure fields are populated correctly with the new structure
        if (currentLead.value != null) {
          resumeDraft(currentLead.value!);
        }
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

  void resumeDraft(dynamic draftData) {
    if (draftData == null) return;

    // If this is an API lead response (has fields_record but no fields/groups),
    // only populate formValues — don't overwrite the template structure.
    if (draftData['fields_record'] != null &&
        draftData['fields'] == null &&
        draftData['groups'] == null) {
      currentLead.value = Map<String, dynamic>.from(draftData);
      Map<String, dynamic> record = Map<String, dynamic>.from(
        draftData['fields_record'],
      );

      // Parse stringified GPS if present
      record.forEach((key, value) {
        if (value is String &&
            value.contains('latitutde') &&
            value.contains('{')) {
          record[key] = _parseGpsString(value);
        }
      });

      formValues.assignAll(record);
      _initializeForm();
      debugPrint("Resumed lead from API data.");
      return;
    }

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
    } else if (draftData['fields_record'] != null) {
      // Handle the case where record is nested in fields_record (API response)
      Map<String, dynamic> record = Map<String, dynamic>.from(
        draftData['fields_record'],
      );

      // Parse stringified GPS if present
      record.forEach((key, value) {
        if (value is String &&
            value.contains('latitutde') &&
            value.contains('{')) {
          record[key] = _parseGpsString(value);
        }
      });

      formValues.assignAll(record);
    } else if (draftData['FOLLOWUP'] != null &&
        draftData['FOLLOWUP']['fields_record'] != null) {
      // Handle FOLLOWUP data structure
      Map<String, dynamic> record = Map<String, dynamic>.from(
        draftData['FOLLOWUP']['fields_record'],
      );

      record.forEach((key, value) {
        if (value is String &&
            value.contains('latitutde') &&
            value.contains('{')) {
          record[key] = _parseGpsString(value);
        }
      });
      formValues.assignAll(record);
    }

    // Restore URL if present
    if (draftData['template_url'] != null) {
      currentTemplateUrl.value = draftData['template_url'];
    }

    // Ensure any auto-generated fields that might have been null/empty are handled
    _initializeForm();

    debugPrint("Resumed draft: ${currentDraftId.value}");
  }

  Future<void> fetchLeadDetails(String url) async {
    isLoadingTemplates.value = true;
    try {
      final response = await api.getLeadDetails(url);
      if (response != null && response['response_status'] == 'success') {
        final data = response['data'];
        if (data != null) {
          currentLead.value = Map<String, dynamic>.from(data);
          resumeDraft(data);
        }
      }
    } catch (e) {
      debugPrint("Error fetching lead details: $e");
      showToast(message: "Failed to refresh lead details");
    } finally {
      isLoadingTemplates.value = false;
    }
  }

  // Helper to parse messy stringified GPS data from API
  Map<String, dynamic>? _parseGpsString(String gpsStr) {
    try {
      // Basic extraction of lat/long/location from string like "{latitutde: 1212.23, longitude: 121.32, location: \"...\"}"
      double? lat;
      double? lng;
      String? loc;

      final latMatch = RegExp(r'latit?utde:\s*([0-9.-]+)').firstMatch(gpsStr);
      final lngMatch = RegExp(r'longitude:\s*([0-9.-]+)').firstMatch(gpsStr);
      final locMatch = RegExp(
        r'location:\s*\\?"([^"]+)\\?"',
      ).firstMatch(gpsStr);

      if (latMatch != null) lat = double.tryParse(latMatch.group(1)!);
      if (lngMatch != null) lng = double.tryParse(lngMatch.group(1)!);
      if (locMatch != null) loc = locMatch.group(1);

      if (lat != null && lng != null) {
        return {
          'latitude': lat,
          'longitude': lng,
          'address': loc,
          'position': loc,
        };
      }
    } catch (e) {
      debugPrint("Error parsing GPS string: $e");
    }
    return null;
  }

  // Removed automatic initialize from onInit as it happens on selectTemplate

  bool isTrue(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == "true" || value == "1";
    return false;
  }

  bool isConditionalFieldRequired(dynamic condition) {
    // Access keys to ensure GetX tracks this dependency even if condition is simple
    final _ = formValues.keys;
    return evaluateFieldRequired(condition, formValues);
  }

  bool isFieldVisible(Map<String, dynamic> field) {
    // Touch formValues to ensure GetX tracks this dependency even for static fields
    final _ = formValues.keys;

    if (isHidden(field['field_visibility'])) return false;

    return true;
  }

  bool isFieldRequired(Map<String, dynamic> field) {
    // Touch formValues to ensure GetX tracks this dependency even for static fields
    final _ = formValues.keys;

    if (isTrue(field['field_required'])) {
      return true;
    }

    if (field['required_condition'] != null) {
      bool isRequired = isConditionalFieldRequired(
        field['required_condition'] ?? {},
      );
      print("${field['field_name']} isRequired: $isRequired");
      return isRequired;
    }
    return false;
  }

  bool isHidden(value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == "hidden" || value == "1";
    if (value is Map) return !isConditionalFieldRequired(value);
    return false;
  }

  bool hasCameraField() {
    return fieldsData.any((f) => f['field_type'] == 'camera');
  }

  void _initializeForm() {
    bool cameraPresent = hasCameraField();
    bool gpsUpdated = false;

    for (var field in fieldsData) {
      String name = (field['field_name'] ?? "").toString();
      if (name.isEmpty) continue;

      // Only initialize if the value is currently null or strictly an empty string
      final currentValue = formValues[name];
      if (currentValue == null ||
          (currentValue is String && currentValue.trim().isEmpty)) {
        // Auto generate values if needed
        if (isTrue(field['field_auto_generated']) ||
            isHidden(field['field_visibility'])) {
          if (field['field_type'] == 'datetime') {
            formValues[name] = formatDateTimeToString(DateTime.now());
          } else if (field['field_type'] == 'gps') {
            if (cameraPresent) {
              formValues[name] = "Capture photo to update GPS";
            } else {
              formValues[name] = "Fetching GPS automatically...";
              gpsUpdated = true;
            }
          }
        } else if (field['field_default'] != null &&
            field['field_default'] != "") {
          // Handle pre-filled fixed defaults
          formValues[name] = field['field_default'];
        } else {
          // Initialize with null
          formValues[name] = null;
        }
      } else if (field['field_type'] == 'gps' && !cameraPresent) {
        // If resuming but no camera, and it was "Capture photo...", refresh it
        if (currentValue == "Capture photo to update GPS") {
          formValues[name] = "Fetching GPS automatically...";
          gpsUpdated = true;
        }
      }
    }

    if (gpsUpdated) {
      updateAllGpsFields();
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

      String address = "Unknown address";
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          List<String> addressParts = [];
          if (place.street != null && place.street!.isNotEmpty) {
            addressParts.add(place.street!);
          }
          if (place.subLocality != null && place.subLocality!.isNotEmpty) {
            addressParts.add(place.subLocality!);
          }
          if (place.locality != null && place.locality!.isNotEmpty) {
            addressParts.add(place.locality!);
          }
          if (place.administrativeArea != null &&
              place.administrativeArea!.isNotEmpty) {
            addressParts.add(place.administrativeArea!);
          }
          address = addressParts.join(", ");
        }
      } catch (e) {
        debugPrint("Geocoding error: $e");
        address = "Error fetching address";
      }

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
        "address": address,
      };
      prettyPrint(loc);
      Map<String, dynamic> latLong = {
        "latitude": position.latitude,
        "longitude": position.longitude,
        "position": address,
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

  /// Updates `captured_at` form field with the current datetime.
  void updateAllTimestampFields() {
    final now = formatDateTimeToString(DateTime.now());

    // Always update captured_at directly in form values
    formValues['captured_at'] = now;

    // Additionally ensure if it exists in the template, it gets updated
    for (var field in fieldsData) {
      final fieldName = (field['field_name'] ?? '').toString().toLowerCase();

      if (fieldName == 'captured_at') {
        final key = field['field_name']?.toString();
        if (key != null && key.isNotEmpty) {
          formValues[key] = now;
          debugPrint("Timestamp field '$key' updated to: $now");
        }
      }
    }
  }

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool validateForm() {
    bool isValid = true;
    log("Validating form...");

    // First, check basic Form widget validation (regex, length, etc.)
    if (formKey.currentState != null && !formKey.currentState!.validate()) {
      isValid = false;
      showToast(message: "Please fix the errors in the form.");
      // return false; // Stop here to let user fix visible errors
    }

    // Second, check required fields specifically in formValues
    for (var field in fieldsData) {
      // Skip validation if field is hidden (statically or dynamically)
      if (!isFieldVisible(field)) continue;

      if (isFieldRequired(field)) {
        String name = (field['field_name'] ?? "").toString();
        if (name.isEmpty) continue;

        var value = formValues[name];

        if (value == null || (value is String && value.trim().isEmpty)) {
          isValid = false;
          String label = field['field_text'] ?? name;
          showToast(message: "$label is required.");
          return false; // Show only the first missing field
        }
      }
    }
    return isValid;
  }

  Future<Map<String, dynamic>?> submitForm({String? submissionURL}) async {
    // print(submissionURL ?? formModel?.submissionUrl ?? 'no submission url');
    log("Submitting form data....");
    if (validateForm()) {
      showLoading(message: "Submitting...");
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

            // Refresh dashboards and lead lists
            try {
              if (Get.isRegistered<DashController>()) {
                Get.find<DashController>().refreshDashboard();
              }
            } catch (e) {
              debugPrint("Error refreshing DashController: $e");
            }

            try {
              if (Get.isRegistered<LeadController>()) {
                Get.find<LeadController>().getLeads(
                  status: 'pending',
                  reset: true,
                );
              }
            } catch (e) {
              debugPrint("Error refreshing LeadController: $e");
            }
          }
          Get.back();
          showSuccessMessage(message: "Lead submitted successfully!");
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

      // Refresh draft list on dashboard if it is active
      try {
        if (Get.isRegistered<DashController>()) {
          Get.find<DashController>().fetchDrafts();
        }
      } catch (_) {}
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
      print("name: $name, value: $value");
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
      } else if (type == 'checkbox') {
        // map[name] = {'options': value};
        List options = value;
        String val = '';
        for (var i = 0; i < options.length; i++) {
          val += options[i] + (i == options.length - 1 ? '' : ',');
        }
        map[name] = val;
      } else {
        map[name] = value;
      }
    }
    return map;
    // return dio.FormData.fromMap(map);
  }
}
