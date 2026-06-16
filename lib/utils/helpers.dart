// hex code to Color code

import 'dart:convert';
import 'dart:developer';

import 'package:field_force/service/api_service.dart';
import 'package:field_force/utils/constants.dart';
import 'package:field_force/utils/custom_toast_messages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:field_force/main.dart';
import 'package:geolocator/geolocator.dart';
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
TextStyle get primaryTextStyle =>
    TextStyle(color: colorManager.textColor, fontFamily: 'SF Pro');
//
toggleDrawer(GlobalKey<ScaffoldState> key) {
  key.currentState!.isDrawerOpen
      ? key.currentState!.closeDrawer()
      : key.currentState!.openDrawer();
}

String toParameterize(dynamic key) {
  String strKey = key?.toString() ?? "";
  if (strKey.isEmpty) return "";
  if (strKey.contains("_")) {
    var words = strKey
        .split('_')
        .map((word) {
          if (word.isEmpty) return "";
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
    return words;
  } else {
    return strKey[0].toUpperCase() + strKey.substring(1).toLowerCase();
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

// String formatDateTimeToString(DateTime dateTime) {
//   return DateFormat('yyyy-MM-dd hh:mm:ss a').format(dateTime);
// }

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
            primary: colorManager.primaryColor,
            onPrimary: Colors.white,
            surface: colorManager.accentColor,
            onSurface: Colors.white,
          ),
          dialogBackgroundColor: colorManager.accentColor,
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.white),
            bodyMedium: TextStyle(color: Colors.white),
            titleSmall: TextStyle(color: Colors.white),
            labelSmall: TextStyle(color: Colors.white),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: colorManager.primaryColor,
            ),
          ),
        ),
        child: child!,
      );
    },
  );
}

Future<List<DateTime>?> showCustomDateRangePicker({
  required BuildContext context,
  DateTimeRange? initialDateRange,
  required DateTime firstDate,
  required DateTime lastDate,
}) async {
  final DateTimeRange? range = await showDateRangePicker(
    context: context,
    initialDateRange: initialDateRange,
    firstDate: firstDate,
    lastDate: lastDate,
    builder: (context, child) {
      return Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(
            primary: colorManager.primaryColor,
            onPrimary: Colors.white,
            surface: colorManager.accentColor,
            onSurface: Colors.white,
            secondary: colorManager.primaryColor,
            primaryContainer: colorManager.primaryColor.withOpacity(0.2),
            onPrimaryContainer: Colors.white,
          ),
          dialogBackgroundColor: colorManager.accentColor,
          scaffoldBackgroundColor: colorManager.accentColor,
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.white),
            bodyMedium: TextStyle(color: Colors.white),
            titleSmall: TextStyle(color: Colors.white),
            labelSmall: TextStyle(color: Colors.white),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: colorManager.accentColor,
            iconTheme: const IconThemeData(color: Colors.white),
            titleTextStyle: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: colorManager.primaryColor,
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        child: child!,
      );
    },
  );

  if (range != null) {
    return [range.start, range.end];
  }
  return null;
}

Future<TimeOfDay?> showCustomTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
}) async {
  return showTimePicker(
    context: context,
    initialTime: initialTime,
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: colorManager.primaryColor,
            onPrimary: Colors.white,
            secondary: colorManager.primaryColor,
            tertiary: colorManager.primaryColor,
            surface: colorManager.accentColor,
            onSurface: Colors.white,
          ),
          dialogTheme: DialogThemeData(
            backgroundColor: colorManager.accentColor,
          ),
          dialogBackgroundColor: colorManager.accentColor,
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.white),
            bodyMedium: TextStyle(color: Colors.white),
            titleSmall: TextStyle(color: Colors.white),
            labelSmall: TextStyle(color: Colors.white),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: colorManager.primaryColor,
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

// Home Screen Titles
String headerTitleKey = 'header_title';
String headerSubTitleKey = 'header_subtitle';
String leadTicketTitleKey = 'lead_ticket_title';
String interactionTicketTitleKey = 'interaction_ticket_title';
String upcomingInteractionTitleKey = 'upcoming_interaction_title';
String upcomingInteractionSubTitleKey = 'upcoming_interaction_subtitle';

// Sidebar Titles
String mainMenuTitleKey = 'main_menu_title';
String leadsTitleKey = 'leads_title';
String interactionsTitleKey = 'interactions_title';
String pendingVisitsTitleKey = 'pending_visits_title';
String draftMenuTitleKey = 'draft_menu_title';
String draftLeadTitleKey = 'draft_lead_title';
String draftInteractionTitleKey = 'draft_interaction_title';

Future<String> getleadFormTitle() async {
  return await getData(key: leadformTitleKey, type: 'string') ?? 'Lead';
}

Future<String> getinteractionFormTitle() async {
  return await getData(key: inteactionformTitleKey, type: 'string') ??
      'Interaction';
}

updateLeadFormTitle(String title) async {
  await setDataToPrefs(key: leadformTitleKey, value: title, type: 'string');
}

updateInteractionFormTitle(String title) async {
  await setDataToPrefs(
    key: inteactionformTitleKey,
    value: title,
    type: 'string',
  );
}

// Home Screen Title Getters/Setters
Future<String> getHeaderTitle() async =>
    await getData(key: headerTitleKey, type: 'string') ?? "Welcome back!";
updateHeaderTitle(String title) async =>
    await setDataToPrefs(key: headerTitleKey, value: title, type: 'string');

Future<String> getHeaderSubTitle() async =>
    await getData(key: headerSubTitleKey, type: 'string') ??
    "Here's the latest update on your leads.";
updateHeaderSubTitle(String title) async =>
    await setDataToPrefs(key: headerSubTitleKey, value: title, type: 'string');

Future<String> getLeadTicketTitle() async =>
    await getData(key: leadTicketTitleKey, type: 'string') ?? "Add Setup";
updateLeadTicketTitle(String title) async =>
    await setDataToPrefs(key: leadTicketTitleKey, value: title, type: 'string');

Future<String> getInteractionTicketTitle() async =>
    await getData(key: interactionTicketTitleKey, type: 'string') ??
    "Add Visit";
updateInteractionTicketTitle(String title) async => await setDataToPrefs(
  key: interactionTicketTitleKey,
  value: title,
  type: 'string',
);

Future<String> getUpcomingInteractionTitle() async =>
    await getData(key: upcomingInteractionTitleKey, type: 'string') ??
    "Upcoming Follow-ups";
updateUpcomingInteractionTitle(String title) async => await setDataToPrefs(
  key: upcomingInteractionTitleKey,
  value: title,
  type: 'string',
);

Future<String> getUpcomingInteractionSubTitle() async =>
    await getData(key: upcomingInteractionSubTitleKey, type: 'string') ?? "";
updateUpcomingInteractionSubTitle(String title) async => await setDataToPrefs(
  key: upcomingInteractionSubTitleKey,
  value: title,
  type: 'string',
);

// Sidebar Title Getters/Setters
Future<String> getMainMenuTitle() async =>
    await getData(key: mainMenuTitleKey, type: 'string') ?? "Main Menu";
updateMainMenuTitle(String title) async =>
    await setDataToPrefs(key: mainMenuTitleKey, value: title, type: 'string');

Future<String> getLeadsTitle() async =>
    await getData(key: leadsTitleKey, type: 'string') ?? "My Setups";
updateLeadsTitle(String title) async =>
    await setDataToPrefs(key: leadsTitleKey, value: title, type: 'string');

Future<String> getInteractionsTitle() async =>
    await getData(key: interactionsTitleKey, type: 'string') ?? "My Visits";
updateInteractionsTitle(String title) async => await setDataToPrefs(
  key: interactionsTitleKey,
  value: title,
  type: 'string',
);

Future<String> getPendingVisitsTitle() async =>
    await getData(key: pendingVisitsTitleKey, type: 'string') ??
    "Pending Visits";
updatePendingVisitsTitle(String title) async => await setDataToPrefs(
  key: pendingVisitsTitleKey,
  value: title,
  type: 'string',
);

Future<String> getDraftMenuTitle() async =>
    await getData(key: draftMenuTitleKey, type: 'string') ?? "Drafts";
updateDraftMenuTitle(String title) async =>
    await setDataToPrefs(key: draftMenuTitleKey, value: title, type: 'string');

Future<String> getDraftLeadTitle() async =>
    await getData(key: draftLeadTitleKey, type: 'string') ?? "Setups";
updateDraftLeadTitle(String title) async =>
    await setDataToPrefs(key: draftLeadTitleKey, value: title, type: 'string');

Future<String> getDraftInteractionTitle() async =>
    await getData(key: draftInteractionTitleKey, type: 'string') ?? "Visits";
updateDraftInteractionTitle(String title) async => await setDataToPrefs(
  key: draftInteractionTitleKey,
  value: title,
  type: 'string',
);

String userNameKey = 'user_name';

Future<String> getUserName() async {
  return await getData(key: userNameKey, type: 'string') ?? '';
}

updateUserName(String name) async {
  await setDataToPrefs(key: userNameKey, value: name, type: 'string');
}

// lead status
String overDueKey = 'overdue';
String dueTodayKey = 'due_today';
String completedKey = 'completed';

Future<bool> handleLocationAccess() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return false;
  }

  LocationPermission permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied) {
      return false;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return false;
  }

  return true; // Access granted
}
