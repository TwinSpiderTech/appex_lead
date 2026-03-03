import 'dart:async';
import 'dart:developer';

import 'package:appex_lead/main.dart';
import 'package:appex_lead/model/lead_model.dart';
import 'package:appex_lead/utils/custom_toast_messages.dart';
import 'package:appex_lead/utils/helpers.dart';
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
  List<Map<String, dynamic>>? pendingLeads, ongoingLeads, closedLeads;
  int pendingPage = 1, ongoingPage = 1, closedPage = 1;
  bool pendingHasNext = false, ongoingHasNext = false, closedHasNext = false;
  RxBool pendingLoading = false.obs,
      ongoingLoading = false.obs,
      closedLoading = false.obs;

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

    // Initial fetch for all tabs
    await getLeads(reset: true, status: 'pending');
    await getLeads(reset: true, status: 'ongoing');
    await getLeads(reset: true, status: 'closed');
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
    update();
  }

  setLoading(bool value) {
    loading.value = value;
  }

  Future<LeadModel?> loadLeadDetails(String url) async {
    try {
      isLoaded = true;
      var res = await api.getLeadDetails(url);
      log("Lead Details Response: $res");
      if (res != null &&
          (res['status'] == 200 || res['response_status'] == 'success')) {
        var data = res['data'] ?? {};
        return LeadModel.fromJson(data);
      }
      update();
      return null;
    } catch (e) {
      log("Error in loadLeadDetails: $e");
      return null;
    }
  }

  // createNewComplaint() async {
  //   try {
  //     setLoading(true);
  //     showLoading(message: "Creating...");
  //     LeadModel complaint = LeadModel(
  //         subject: subjectCont.text,
  //         description: complaintCont.text,
  //         mobileNo: phoneCont.text,
  //         complaintID: selectedCategory!['id']);

  //     await api.createNewComplaint(complaint.toJSON());

  //     setLoading(false);
  //     showSuccessMessage(message: 'Complaint created successfully!');
  //     Get.back();
  //     await getComplaintHistory(reset: true, status: 'pending');
  //   } catch (e) {
  //     setLoading(false);
  //     log(e.toString());
  //   }
  // }

  Future<void> getLeads({bool reset = false, String? status}) async {
    int currentPage;
    String? searchQuery;
    if (status == 'pending') {
      if (reset) pendingPage = 1;
      currentPage = pendingPage;
      searchQuery = pendingSearchCont.text;
      pendingLoading.value = true;
    } else if (status == 'ongoing') {
      if (reset) ongoingPage = 1;
      currentPage = ongoingPage;
      searchQuery = ongoingSearchCont.text;
      ongoingLoading.value = true;
    } else if (status == 'closed') {
      if (reset) closedPage = 1;
      currentPage = closedPage;
      searchQuery = closedSearchCont.text;
      closedLoading.value = true;
    } else {
      loading.value = true;
      return;
    }

    update();

    log(
      "Fetching Leads for status: $status, page: $currentPage, search: $searchQuery",
    );
    final response = await api.getLeads(
      currentPage,
      status: status,
      search: searchQuery,
    );
    log("Leads Response for $status: $response");

    if (response != null && response['response_status'] == 'success') {
      var data = response['data'] ?? [];
      leadEndPoint.value = dig(data, ['detail_endpoint']) ?? '';
      bool hasNext = dig(response, ['meta', 'next_page']) ?? true;

      prettyPrint(data);

      List<Map<String, dynamic>> fetchedHistory =
          List<Map<String, dynamic>>.from(
            dig(data, ['table_record'])?.map((e) => e).toList(),
          );

      if (status == 'pending') {
        pendingLeads = fetchedHistory;
        pendingHasNext = hasNext;
      } else if (status == 'ongoing') {
        ongoingLeads = fetchedHistory;
        ongoingHasNext = hasNext;
      } else if (status == 'closed') {
        closedLeads = fetchedHistory;
        closedHasNext = hasNext;
      }
    } else {
      if (status == 'pending') {
        pendingLeads = [];
        pendingHasNext = false;
      } else if (status == 'ongoing') {
        ongoingLeads = [];
        ongoingHasNext = false;
      } else if (status == 'closed') {
        closedLeads = [];
        closedHasNext = false;
      }
    }

    loading.value = false;
    pendingLoading.value = false;
    ongoingLoading.value = false;
    closedLoading.value = false;
    update();
  }

  void nextPage() async {
    String? status;
    if (tabController.index == 0) {
      if (!pendingHasNext) return;
      pendingPage++;
      status = 'pending';
    } else if (tabController.index == 1) {
      if (!ongoingHasNext) return;
      ongoingPage++;
      status = 'ongoing';
    } else if (tabController.index == 2) {
      if (!closedHasNext) return;
      closedPage++;
      status = 'closed';
    }

    if (status != null) await getLeads(status: status);
  }

  void previousPage() async {
    String? status;
    if (tabController.index == 0) {
      if (pendingPage <= 1) return;
      pendingPage--;
      status = 'pending';
    } else if (tabController.index == 1) {
      if (ongoingPage <= 1) return;
      ongoingPage--;
      status = 'ongoing';
    } else if (tabController.index == 2) {
      if (closedPage <= 1) return;
      closedPage--;
      status = 'closed';
    }

    if (status != null) await getLeads(status: status);
  }

  List<Map<String, dynamic>> complaintsCategories = [];

  void onSearchChanged(String value, String status) {
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      if (value.length >= 3 || value.isEmpty) {
        getLeads(reset: true, status: status);
      }
    });
  }
}
