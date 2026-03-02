import 'dart:developer';

import 'package:appex_lead/main.dart';
import 'package:appex_lead/utils/auth_service.dart';
import 'package:appex_lead/utils/custom_toast_messages.dart';
import 'package:appex_lead/utils/helpers.dart';
import 'package:appex_lead/utils/urls.dart';
import 'package:get/get.dart';

class DashController extends GetxController {
  RxBool isLoading = false.obs;
  // Map<String, dynamic> dashboardData = <String, dynamic>{};
  List<Map<String, dynamic>> leads = [];
  Map<String, dynamic> chartData = {};
  Map<String, dynamic> tables = {};
  String headerTitle = "Welcome to Appex Leads";
  String headerSubTitle = "Here's what's happening with your leads.";

  RxBool hasNextPage = false.obs;
  int currentPage = 1;

  @override
  void onInit() {
    super.onInit();
  }
}
