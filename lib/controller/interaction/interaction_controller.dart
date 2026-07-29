import 'dart:async';
import 'dart:developer';

import 'package:ts_fieldforce/main.dart';
import 'package:ts_fieldforce/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InteractionController extends GetxController {
  RxList<Map<String, dynamic>> interactions = <Map<String, dynamic>>[].obs;
  RxBool isLoading = false.obs;
  RxBool isPageLoading = false.obs;

  int currentPage = 1;
  bool hasNextPage = false;

  final TextEditingController searchCont = TextEditingController();
  Timer? _searchTimer;
  String currentUrl = "";

  Rx<DateTime?> startDate = Rx<DateTime?>(null);
  Rx<DateTime?> endDate = Rx<DateTime?>(null);

  void onSearchChanged(String value) {
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      if (value.length >= 3 || value.isEmpty) {
        fetchInteractions(currentUrl, reset: true);
      }
    });
  }

  Future<void> fetchInteractions(String url, {bool reset = false}) async {
    if (url.isEmpty) return;
    currentUrl = url;

    if (reset) {
      currentPage = 1;
      interactions.clear();
      isLoading.value = true;
    } else {
      isPageLoading.value = true;
    }

    try {
      final response = await api.getInteractions(
        url,
        pageNo: currentPage,
        search: searchCont.text,
        startDate: startDate.value != null
            ? formatDateToString(startDate.value!)
            : null,
        endDate: endDate.value != null
            ? formatDateToString(endDate.value!)
            : null,
      );

      if (response != null &&
          (response['status'] == 200 ||
              response['response_status'] == 'success')) {
        final data = response['data'] ?? [];

        // print(data);
        final List<Map<String, dynamic>> fetchedData =
            List<Map<String, dynamic>>.from(
              dig(data, ['table_record'])?.map((e) => e).toList() ?? [],
            );

        if (reset) {
          interactions.assignAll(fetchedData);
        } else {
          interactions.addAll(fetchedData);
        }

        hasNextPage = dig(response, ['meta', 'next_page']) ?? false;
      }
    } catch (e) {
      log("Error fetching interactions: $e");
    } finally {
      isLoading.value = false;
      isPageLoading.value = false;
    }
  }

  void loadMore() {
    if (hasNextPage && !isPageLoading.value) {
      currentPage++;
      fetchInteractions(currentUrl);
    }
  }
}
