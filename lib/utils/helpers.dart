// hex code to Color code

import 'dart:convert';
import 'dart:developer';

import 'package:appex_lead/service/api_service.dart';
import 'package:appex_lead/utils/constants.dart';
import 'package:appex_lead/utils/custom_toast_messages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:appex_lead/main.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

String hexToColor(String hexColor) {
  String onlyCode = hexColor.substring(1);
  String color = "0xff$onlyCode";
  return color;
}

copyToClipboard({String? text}) async {
  await Clipboard.setData(ClipboardData(text: text ?? ""));
}

//
final TextStyle primaryTextStyle = TextStyle(
  color: colorManager.textColor,
  fontFamily: 'SF Pro',
);
//
toggleDrawer(GlobalKey<ScaffoldState> key) {
  key.currentState!.isDrawerOpen
      ? key.currentState!.closeDrawer()
      : key.currentState!.openDrawer();
}

String toParameterize(String key) {
  if (key.contains("_")) {
    var words = key
        .split('_')
        .map((word) {
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
    return words;
  } else {
    return key[0].toUpperCase() + key.substring(1).toLowerCase();
  }
}

extension StringCasingExtension on String {
  String capitalizeFirstLetters() {
    return split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }
}

extension StringCapitalizeExtension on String {
  String capitalizeOnlyFirstLetter() {
    return split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
  }
}

Future<bool> setData({
  required String key,
  required dynamic value,
  required String type,
}) async {
  final prefs = await SharedPreferences.getInstance();

  switch (type) {
    case "string":
      return prefs.setString(key, value);
    case "bool":
      return prefs.setBool(key, value);
    case "double":
      return prefs.setDouble(key, value);
    case "int":
      return prefs.setInt(key, value);
    case "list":
    case "map":
      return prefs.setString(key, jsonEncode(value));
    default:
      throw Exception("Unsupported type: $type");
  }
}

Future<dynamic> getData({required String key, required String type}) async {
  final prefs = await SharedPreferences.getInstance();

  switch (type) {
    case "string":
      return prefs.getString(key);
    case "bool":
      return prefs.getBool(key);
    case "double":
      return prefs.getDouble(key);
    case "int":
      return prefs.getInt(key);
    case "list":
    case "map":
      final raw = prefs.getString(key);
      return raw != null ? jsonDecode(raw) : null;
    default:
      throw Exception("Unsupported type: $type");
  }
}

prettyPrint(mapData) {
  var data = JsonEncoder.withIndent('  ').convert(mapData);
  log(data);
}

dynamic dig(Map data, dynamic keys) {
  dynamic value = data;
  for (var k in keys) {
    if (value is Map && value.containsKey(k)) {
      value = value[k];
    } else {
      return null;
    }
  }
  return value;
}

dynamic buildIcons(String title) {
  switch (title.toLowerCase()) {
    case "accounts":
      return HugeIcons.strokeRoundedUser;
    case "sale":
    case "cash sale":
    case "credit sale":
    case "returns":
      return HugeIcons.strokeRoundedInvoice;
    case "purchase":
      return HugeIcons.strokeRoundedInvoice02;
    case "bank receipts":
    case "bank payments":
      return HugeIcons.strokeRoundedBank;
    case "payments":
      return HugeIcons.strokeRoundedPayment01;
    case "cash payments":
    case "cash receipts":
      return HugeIcons.strokeRoundedPayment02;
    case "complaints":
    case "unresolved":
    case "unassigned":
      return HugeIcons.strokeRoundedComplaint;
    default:
      return HugeIcons.strokeRoundedUser;
  }
}

setDataToPrefs({
  required String key,
  required var value,
  required String type,
}) async {
  await SharedPreferences.getInstance().then((v) {
    if (type == "string") {
      v.setString(key, value);
    }
    if (type == "bool") {
      v.setBool(key, value);
    }
    if (type == "double") {
      v.setDouble(key, value);
    }
    if (type == "int") {
      v.setInt(key, value);
    }
  });
}

logoutUser({String toastMessage = 'Logging out...'}) async {
  String token = await getData(key: sessionToken, type: 'string') ?? '';
  if (token.isNotEmpty) showLoading(message: toastMessage);
  // final dash = Get.put(DashController());
  ApiServices service = ApiServices();
  // await dash.clearMemberships();
  // await Get.put(HomeController()).clearMemberships();
  await service.logout();
  await clearUserSession();
}

clearUserSession() async {
  await setDataToPrefs(key: sessionToken, value: '', type: 'string');

  await setDataToPrefs(key: userDetailsKey, value: '', type: 'string');
}

Future<List<dynamic>> getDecodedListFromPrefs({required String key}) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(key);

    if (data == null || data.isEmpty) {
      return [];
    }
    final decoded = jsonDecode(data);
    if (decoded is List) {
      return decoded;
    }
    return [];
  } catch (e) {
    print("Error decoding prefs for key '$key': $e");
    return [];
  }
}

setDataToPrefsEncoded({key, value}) async {
  String encodedValue = json.encode(value);
  await setDataToPrefs(key: key, value: encodedValue, type: 'string');
}

getDataFromPrefsDecoded({key}) async {
  String? jsonString = await getData(key: key, type: 'string');

  var decodedData = jsonString != null ? json.decode(jsonString) : {};
  return decodedData;
}

validateURL(String url) {
  if (url.startsWith("/")) {
    return url;
  } else {
    return "/$url";
  }
}

// dynamic form required condition

bool evaluateFieldRequired(
  dynamic requiredCondition,
  Map<String, dynamic> formValues,
) {
  if (requiredCondition == null) return false;

  // Simple boolean or string "1"/"true"
  if (requiredCondition is bool) return requiredCondition;
  if (requiredCondition is String) {
    String lower = requiredCondition.toLowerCase();
    return lower == 'true' || lower == '1' || lower == 'required';
  }

  // Complex logic Map
  if (requiredCondition is Map<String, dynamic>) {
    return _evaluateCondition(requiredCondition, formValues);
  }

  return false;
}

bool _evaluateCondition(
  Map<String, dynamic> condition,
  Map<String, dynamic> formValues,
) {
  if (condition.isEmpty) return false;

  // Logical AND
  if (condition.containsKey('_and')) {
    final list = condition['_and'];
    if (list is List) {
      return list.every(
        (item) =>
            item is Map<String, dynamic> &&
            _evaluateCondition(item, formValues),
      );
    }
  }

  // Logical OR
  if (condition.containsKey('_or')) {
    final list = condition['_or'];
    if (list is List) {
      return list.any(
        (item) =>
            item is Map<String, dynamic> &&
            _evaluateCondition(item, formValues),
      );
    }
  }

  // Single field condition: { "field_name": { "operator": expected_value } }
  // or shorthand: { "field_name": expected_value } (treated as equal)
  final fieldName = condition.keys.first;
  final operatorData = condition[fieldName];
  final actualValue = formValues[fieldName];

  if (operatorData is Map<String, dynamic>) {
    final operator = operatorData.keys.first;
    final expectedValue = operatorData[operator];

    switch (operator) {
      case 'equal':
      case 'eq':
        return actualValue.toString().trim() == expectedValue.toString().trim();
      case 'not_equal':
      case 'neq':
        return actualValue.toString().trim() != expectedValue.toString().trim();
      case 'in':
        if (expectedValue is List) {
          return expectedValue
              .map((e) => e.toString().trim())
              .contains(actualValue.toString().trim());
        }
        return false;
      case 'not_in':
        if (expectedValue is List) {
          return !expectedValue
              .map((e) => e.toString().trim())
              .contains(actualValue.toString().trim());
        }
        return true;
      case 'contains':
        return actualValue.toString().contains(expectedValue.toString());
      case 'not_contains':
        return !actualValue.toString().contains(expectedValue.toString());
      default:
        return false;
    }
  } else {
    // Shorthand: { "field_name": expected_value }
    return actualValue.toString().trim() == operatorData.toString().trim();
  }
}

const demoCondition = {
  "_and": [
    {
      "person_designation": {"not_equal": 'none_avialable'},
    },
    {
      "person_name": {"equal": 'ali'},
    },
    {
      "_or": [
        {
          "area_id": {"equal": 3},
        },
        {
          "_and": [
            {
              "province": {"equal": 'Punjab'},
            },
            {
              "_or": [
                {
                  "status": {"equal": 'verified'},
                },
                {
                  "priority": {
                    "in": ['High', 'Urgent'],
                  },
                },
              ],
            },
          ],
        },
      ],
    },
  ],
};

String previewableDateTimeFormat(DateTime dateTime) {
  return DateFormat('dd MMM, yyyy - hh:mm a').format(dateTime);
}

String formatDateTimeToString(DateTime dateTime) {
  return DateFormat('yyyy-MM-dd hh:mm:ss a').format(dateTime);
}

String formatDateToString(DateTime dateTime) {
  return DateFormat('yyyy-MM-dd').format(dateTime);
}

String previewableDateFormat(DateTime dateTime) {
  return DateFormat('dd MMM, yyyy').format(dateTime);
}

Future<DateTime?> showCustomDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) async {
  return showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: colorManager
                .primaryColor, // Header background color, Selector color
            onPrimary: Colors.white, // Header text color, Selected text color
            surface: colorManager.accentColor, // Picker background color
            onSurface: Colors.white, // Default text color for the calendar grid
          ),
          dialogTheme: DialogThemeData(
            backgroundColor: colorManager.accentColor,
          ),
          dialogBackgroundColor:
              colorManager.accentColor, // Dialog background color
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.white), // Dates text
            bodyMedium: TextStyle(color: Colors.white), // Secondary dates/text
            titleSmall: TextStyle(color: Colors.white), // Header label
            labelSmall: TextStyle(color: Colors.white), // AM/PM or small labels
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: colorManager.primaryColor, // Button text color
            ),
          ),
        ),
        child: child!,
      );
    },
  );
}

String leadformTitleKey = 'leadform_title';
String inteactionformTitleKey = 'interactionform_title';

getleadFormTitle() async {
  await getData(key: leadformTitleKey, type: 'string') ?? 'Lead';
}

getinteractionFormTitle() async {
  await getData(key: inteactionformTitleKey, type: 'string') ?? 'Interaction';
}

updateLeadFormTitle(String title) async {
  await setDataToPrefs(key: leadformTitleKey, value: title, type: 'string');
}

updateInteractionFormTitle(String title) {
  setDataToPrefs(key: inteactionformTitleKey, value: title, type: 'string');
}
