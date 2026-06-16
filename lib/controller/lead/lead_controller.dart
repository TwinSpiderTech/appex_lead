import 'dart:async';
import 'dart:developer';

import 'package:field_force/main.dart';
import 'package:field_force/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LeadController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final GlobalKey<FormState> complaintformKey = GlobalKey<FormState>();
  RxBool loading = false.obs;
  bool pageLoading = false;

  final TextEditingController subjectCont = TextEditingController(),
      complaintCont = TextEditingController(),
      phoneCont = TextEditingController();
  final TextEditingController pendingSearchCont = TextEditingController(),
      ongoingSearchCont = TextEditingController(),
      closedSearchCont = TextEditingController();
  Map<String, dynamic>? selectedCategory;
  RxString leadEndPoint = "".obs;
  late TabController tabController;
  // Tab-based states
  List<Map<String, dynamic>>? pendingLeads,
      ongoingLeads,
      closedLeads,
      physicalVerificationPendingLeads;
  int pendingPage = 1, ongoingPage = 1, closedPage = 1, pvpPage = 1;
  bool pendingHasNext = false,
      ongoingHasNext = false,
      closedHasNext = false,
      pvpHasNext = false;
  RxBool pendingLoading = false.obs,
      ongoingLoading = false.obs,
      closedLoading = false.obs,
      physicalVerificationPendingLoading = false.obs;

  bool isLoaded = false;
  String complaintNO = '';
  Timer? _searchTimer;

  @override
  void onInit() async {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        update();
      }
    });
  }

  clearForm() {
    selectedCategory = null;
    subjectCont.clear();
    phoneCont.clear();
    complaintCont.clear();
    loading.value = false;
    pageLoading = false;
    isLoaded = false;
    complaintNO = '';
    pendingSearchCont.clear();
    ongoingSearchCont.clear();
    closedSearchCont.clear();
    update();
  }

  setLoading(bool value) {
    loading.value = value;
  }

  Future<Map<String, dynamic>?> loadLeadDetails(String url) async {
    try {
      isLoaded = true;
      var res = await api.getLeadDetails(url);
      log("Lead Details Response: $res");
      if (res != null &&
          (res['status'] == 200 || res['response_status'] == 'success')) {
        var data = res['data'] ?? {};
        return Map<String, dynamic>.from(data);
      }
      update();
      return null;
    } catch (e) {
      log("Error in loadLeadDetails: $e");
      return null;
    }
  }

  Future<void> getLeads({
    bool reset = false,
    String? status,
    Map<String, dynamic>? extraParams,
  }) async {
    int currentPage;
    String? searchQuery;
    if (status == overDueKey) {
      if (reset) pendingPage = 1;
      currentPage = pendingPage;
      searchQuery = pendingSearchCont.text;
      pendingLoading.value = true;
    } else if (status == dueTodayKey) {
      if (reset) ongoingPage = 1;
      currentPage = ongoingPage;
      searchQuery = ongoingSearchCont.text;
      ongoingLoading.value = true;
    } else if (status == completedKey) {
      if (reset) closedPage = 1;
      currentPage = closedPage;
      searchQuery = closedSearchCont.text;
      closedLoading.value = true;
    } else if (extraParams != null &&
        extraParams['ownership_status'] == 'physical_verification_pending') {
      if (reset) pvpPage = 1;
      currentPage = pvpPage;
      searchQuery = pendingSearchCont.text;
      physicalVerificationPendingLoading.value = true;
    } else {
      loading.value = true;
      return;
    }

    update();

    log(
      "Fetching Leads for status: $status, page: $currentPage, search: $searchQuery, extraParams: $extraParams",
    );
    final response = await api.getLeads(
      currentPage,
      status: status,
      search: searchQuery,
      extraParams: extraParams,
    );
    log("Leads Response for $status: $response");

    if (response != null && response['response_status'] == 'success') {
      var data = response['data'] ?? [];
      leadEndPoint.value = dig(data, ['detail_endpoint']) ?? '';
      bool hasNext = dig(response, ['meta', 'next_page']) ?? true;

      prettyPrint(data);

      List<Map<String, dynamic>> fetchedHistory =
          List<Map<String, dynamic>>.from(
            dig(data, ['table_record'])?.map((e) => e).toList() ?? [],
          );

      if (status == overDueKey) {
        pendingLeads = fetchedHistory;
        pendingHasNext = hasNext;
      } else if (status == dueTodayKey) {
        ongoingLeads = fetchedHistory;
        ongoingHasNext = hasNext;
      } else if (status == completedKey) {
        closedLeads = fetchedHistory;
        closedHasNext = hasNext;
      } else if (extraParams != null &&
          extraParams['ownership_status'] == 'physical_verification_pending') {
        physicalVerificationPendingLeads = fetchedHistory;
        pvpHasNext = hasNext;
      }
    } else {
      if (status == overDueKey) {
        pendingLeads = [];
        pendingHasNext = false;
      } else if (status == dueTodayKey) {
        ongoingLeads = [];
        ongoingHasNext = false;
      } else if (status == completedKey) {
        closedLeads = [];
        closedHasNext = false;
      }
    }

    loading.value = false;
    pendingLoading.value = false;
    ongoingLoading.value = false;
    closedLoading.value = false;
    physicalVerificationPendingLoading.value = false;
    update();
  }

  void nextPage() async {
    String? status;
    if (tabController.index == 0) {
      if (!ongoingHasNext) return;
      ongoingPage++;
      status = dueTodayKey;
    } else if (tabController.index == 1) {
      if (!pendingHasNext) return;
      pendingPage++;
      status = overDueKey;
    } else if (tabController.index == 2) {
      if (!closedHasNext) return;
      closedPage++;
      status = completedKey;
    }

    if (status != null) await getLeads(status: status);
  }

  void previousPage() async {
    String? status;
    if (tabController.index == 0) {
      if (ongoingPage <= 1) return;
      ongoingPage--;
      status = dueTodayKey;
    } else if (tabController.index == 1) {
      if (pendingPage <= 1) return;
      pendingPage--;
      status = overDueKey;
    } else if (tabController.index == 2) {
      if (closedPage <= 1) return;
      closedPage--;
      status = completedKey;
    }

    if (status != null) await getLeads(status: status);
  }

  List<Map<String, dynamic>> complaintsCategories = [];

  void onSearchChanged(
    String value,
    String? status, {
    Map<String, dynamic>? extraParams,
  }) {
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      if (value.length >= 3 || value.isEmpty) {
        getLeads(reset: true, status: status, extraParams: extraParams);
      }
    });
  }
}
