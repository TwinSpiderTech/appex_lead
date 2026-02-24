// import 'package:firebase_auth/firebase_auth.dart';
import 'package:appex_lead/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:appex_lead/utils/helpers.dart';
import 'package:pdf/pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ColorManager extends GetxController {
  final PdfColor primaryPdfColor = PdfColor.fromInt(0xFFEF8124);
  final PdfColor lightPrimaryPdfColor = PdfColor.fromInt(0x4DEF8124);

  Color primaryColor = const Color(0xFFef8124);
  Color secondaryColor = const Color(0xFF151a3d);
  Color accentColor = const Color(0xFF151a3d);
  Color textColor = const Color.fromRGBO(22, 22, 22, 1);

  Color whiteColor = Colors.white;
  Color darkBlue = const Color(0xff1F1D2B);

  Color greyText = Colors.grey.shade200;
  Color bgLight = const Color(0xFFF7F7F7);
  Color bgDark = const Color.fromARGB(255, 255, 255, 255);
  Color borderColor = const Color.fromARGB(255, 237, 237, 237);
  Color iconColor = const Color(0xff161616);

  String get appLogo => isDark ? "assets/logo-light.png" : "assets/logo.png";

  lightTheme() {
    textColor = const Color(0xff161616);
    greyText = Colors.grey.shade200;
    accentColor = const Color(0xFF151a3d);
    secondaryColor = const Color(0xFF151a3d);
    bgLight = const Color(0xFFF7F7F7);
    bgDark = const Color.fromARGB(255, 255, 255, 255);
    iconColor = const Color(0xff161616);
    Get.changeTheme(
      ThemeData.light().copyWith(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: bgDark,
        iconTheme: IconThemeData(color: iconColor),
        listTileTheme: ListTileThemeData(iconColor: iconColor),
        appBarTheme: AppBarTheme(backgroundColor: bgDark),
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          background: bgDark,
        ),
      ),
    );

    borderColor = const Color.fromARGB(255, 217, 217, 217);
    update();
  }

  darkTheme() {
    textColor = Colors.white;
    // greyText = primaryColor;
    accentColor = const Color(0xFF000000);
    secondaryColor = Colors.white;
    bgLight = const Color.fromARGB(255, 67, 67, 67);
    bgDark = const Color(0xFF131313);
    iconColor = Colors.white;
    Get.changeTheme(
      ThemeData.dark().copyWith(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: bgDark,
        iconTheme: IconThemeData(color: iconColor),
        listTileTheme: ListTileThemeData(iconColor: iconColor),
        appBarTheme: AppBarTheme(backgroundColor: bgDark),
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          background: bgDark,
          brightness: Brightness.dark,
        ),
      ),
    );
    borderColor = const Color.fromARGB(255, 217, 217, 217);
    update();
  }

  @override
  void onInit() {
    super.onInit();
    loadThemeFromPreferences();
    // getUserRole();
  }

  bool isDark = false;
  void toggleTheme() {
    isDark = !isDark;

    isDark ? darkTheme() : lightTheme();
    saveThemeToPreferences(isDark);
    Get.forceAppUpdate();
  }

  void loadThemeFromPreferences() async {
    await SharedPreferences.getInstance().then((v) {
      isDark = v.getBool('isDarkTheme') ?? false;
      isDark ? iconColor = Colors.white : iconColor = const Color(0xff161616);
      isDark ? darkTheme() : lightTheme();
      primaryColor = Color(
        int.parse(hexToColor(v.getString('color') ?? "#ef8124")),
      );
      update();
    });
  }

  void saveThemeToPreferences(bool isDarkTheme) async {
    await SharedPreferences.getInstance().then((v) {
      v.setBool('isDarkTheme', isDarkTheme);
      update();
    });
  }
}
