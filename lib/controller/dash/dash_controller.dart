import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:appex_lead/controller/lead/lead_controller.dart';
import 'package:appex_lead/main.dart';
import 'package:appex_lead/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<Map<String, dynamic>> upcomingLeads = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> pendingLeads = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> drafts = <Map<String, dynamic>>[].obs;

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

  RxString leadFormTitle = "Lead".obs;
  RxString interactionFormTitle = "Interaction".obs;

  Future<void> refreshDashboard() async {
    isLoading.value = true;
    update();

    try {
      await Future.wait([
        fetchPendingLeads(),
        fetchUpcomingLeads(),
        fetchDrafts(),
      ]);
      leadFormTitle.value = await getleadFormTitle() ?? 'Lead';
      interactionFormTitle.value =
          await getinteractionFormTitle() ?? 'Interaction';
    } catch (e) {
      log("Error refreshing dashboard: $e");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> fetchDrafts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      List<Map<String, dynamic>> loaded = [];
      for (var key in keys) {
        if (key.startsWith('form_draft_')) {
          final jsonStr = prefs.getString(key);
          if (jsonStr != null) {
            try {
              final decoded = jsonDecode(jsonStr);
              if (decoded is Map<String, dynamic>) {
                loaded.add(decoded);
              }
            } catch (_) {}
          }
        }
      }
      loaded.sort((a, b) {
        String ta = a['updated_at']?.toString() ?? '';
        String tb = b['updated_at']?.toString() ?? '';
        return tb.compareTo(ta);
      });
      drafts.value = loaded;
    } catch (e) {
      log('Error fetching drafts: $e');
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
      if (value.length >= 3 || value.isEmpty) {
        refreshDashboard();
      }
    });
  }

  String getLeadDetailUrl(Map<String, dynamic> lead) {
    return "/api/v1/business/leads/${lead['id']}";
  }
}
