import 'dart:async';
import 'dart:developer';

import 'package:appex_lead/controller/lead/lead_controller.dart';
import 'package:appex_lead/main.dart';
import 'package:appex_lead/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<Map<String, dynamic>> upcomingLeads = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> pendingLeads = <Map<String, dynamic>>[].obs;

  String headerTitle = "Welcome back!";
  String headerSubTitle = "Here's the latest update on your leads.";

  final TextEditingController searchCont = TextEditingController();
  Timer? _searchTimer;

  @override
  void onInit() {
    super.onInit();
    // Ensure LeadController is initialized as it's needed for navigation and data mapping
    Get.put(LeadController());
    refreshDashboard();
  }

  Future<void> refreshDashboard() async {
    isLoading.value = true;
    update();

    try {
      await Future.wait([fetchPendingLeads(), fetchUpcomingLeads()]);
    } catch (e) {
      log("Error refreshing dashboard: $e");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> fetchPendingLeads() async {
    final response = await api.getLeads(
      1,
      status: 'pending',
      search: searchCont.text,
    );
    if (response != null && response['response_status'] == 'success') {
      final data = response['data'] ?? [];
      final tableRecord = List<Map<String, dynamic>>.from(
        dig(data, ['table_record'])?.map((e) => e).toList() ?? [],
      );

      pendingLeads.value = tableRecord;
    }
  }

  Future<void> fetchUpcomingLeads() async {
    final response = await api.getUpcomingLeads(1, search: searchCont.text);
    if (response != null && response['response_status'] == 'success') {
      final data = response['data'] ?? [];
      final tableRecord = List<Map<String, dynamic>>.from(
        dig(data, ['table_record'])?.map((e) => e).toList() ?? [],
      );

      upcomingLeads.value = tableRecord;
    }
  }

  void onSearchChanged(String value) {
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      refreshDashboard();
    });
  }

  String getLeadDetailUrl(Map<String, dynamic> lead) {
    // Assuming detail_endpoint follows a pattern or is provided in the response
    // Based on LeadController, it's often a base path + id
    return "/api/v1/business/leads/${lead['id']}";
  }
}
