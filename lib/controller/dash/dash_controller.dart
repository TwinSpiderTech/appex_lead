import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:field_force/controller/lead/lead_controller.dart';
import 'package:field_force/main.dart';
import 'package:field_force/utils/auth_service.dart';
import 'package:field_force/utils/helpers.dart';
import 'package:field_force/utils/urls.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<Map<String, dynamic>> upcomingLeads = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> pendingLeads = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> drafts = <Map<String, dynamic>>[].obs;

  final TextEditingController searchCont = TextEditingController();
  Timer? _searchTimer;

  @override
  void onInit() {
    super.onInit();
    // Ensure LeadController is initialized as it's needed for navigation and data mapping
    Get.put(LeadController());
    loadStoredTitles();
  }

  RxString leadFormTitle = "Lead".obs;
  RxString interactionFormTitle = "Interaction".obs;

  Future<void> loadStoredTitles() async {
    leadFormTitle.value = await getleadFormTitle();
    interactionFormTitle.value = await getinteractionFormTitle();

    headerTitle.value = await getHeaderTitle();
    headerSubTitle.value = await getHeaderSubTitle();
    leadTicketTitle.value = await getLeadTicketTitle();
    interactionTicketTitle.value = await getInteractionTicketTitle();
    upcomingInteractionTitle.value = await getUpcomingInteractionTitle();

    mainMenuTitle.value = await getMainMenuTitle();
    leadsTitle.value = await getLeadsTitle();
    interactionsTitle.value = await getInteractionsTitle();
    draftMenuTitle.value = await getDraftMenuTitle();
    draftLeadTitle.value = await getDraftLeadTitle();
    draftInteractionTitle.value = await getDraftInteractionTitle();
  }

  Future<void> refreshDashboard() async {
    isLoading.value = true;
    update();

    try {
      await Future.wait([
        // fetchPendingLeads(),
        fetchUpcomingLeads(),
        loadDashboard(),
        // fetchDrafts(),
      ]);
      await loadStoredTitles();
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

  // ask for location permission
  Future<void> askForLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
  }

  // ////////////////

  // Titles

  RxString leadTicketTitle = "Add Setup".obs;
  RxString interactionTicketTitle = "Add Visit".obs;
  RxString upcomingInteractionTitle = "Upcoming Follow-ups".obs;
  RxString upcomingInteractionSubTitle = "".obs;
  RxString headerTitle = "Welcome back!".obs;
  RxString headerSubTitle = "Here's the latest update on your leads.".obs;

  // Sidebar Titles

  RxString mainMenuTitle = "Main Menu".obs;
  RxString leadsTitle = "My Setups".obs;
  RxString interactionsTitle = "My Visits".obs;
  RxString pendingVisitsTitle = "Pending Visit".obs;
  RxString draftMenuTitle = "Drafts".obs;
  RxString draftLeadTitle = "Setups".obs;
  RxString draftInteractionTitle = "Visits".obs;

  RxMap<String, dynamic> tickets = <String, dynamic>{}.obs;

  // load dashboard
  Future<void> loadDashboard() async {
    String token = await AuthService.getSessionToken() ?? '';
    try {
      final response = await api.getData(token, Urls.loadDashboardUrl);
      if (response != null && response['response_status'] == 'success') {
        final data = response['data'] ?? {};
        prettyPrint(data);
        // Home Screen Data
        final home = data['homescreen'] ?? {};
        final welcome = home['welcome'] ?? {};
        final _tickets = home['tickets'] ?? {};
        final listItems = home['list_items'] ?? {};

        if (welcome['title'] != null) {
          headerTitle.value = welcome['title'];
          updateHeaderTitle(headerTitle.value);
        }

        if (welcome['subtitle'] != null) {
          headerSubTitle.value = welcome['subtitle'];
          updateHeaderSubTitle(headerSubTitle.value);
        }
        tickets.value = _tickets;
        // Inject local tracking module
        tickets['route_tracking'] = {
          'title': 'Route Tracking',
          'subtitle': 'Track movement',
        };
        await setDataToPrefsEncoded(
          key: 'dashboard_tickets',
          value: tickets.value,
        );
        print(tickets.value);

        if (listItems['upcoming_interactions'] != null) {
          upcomingInteractionTitle.value = dig(listItems, [
            'upcoming_interactions',
            'title',
          ]);
          updateUpcomingInteractionTitle(upcomingInteractionTitle.value);

          upcomingInteractionSubTitle.value = dig(listItems, [
            'upcoming_interactions',
            'subtitle',
          ]);
          updateUpcomingInteractionSubTitle(upcomingInteractionSubTitle.value);
        }

        // // Sidebar data
        final sidebar = data['sidebar'] ?? {};
        final mainMenu = sidebar['main_menu'] ?? {};
        final draftsData = sidebar['draft_menu'] ?? {};

        if (mainMenu['title'] != null) {
          mainMenuTitle.value = mainMenu['title'];
          updateMainMenuTitle(mainMenuTitle.value);
        }

        final mainItems = mainMenu['items'] ?? {};
        if (mainItems['my_leads'] != null) {
          leadsTitle.value = mainItems['my_leads'];
          updateLeadsTitle(leadsTitle.value);
        }

        if (mainItems['my_interactions'] != null) {
          interactionsTitle.value = mainItems['my_interactions'];
          updateInteractionsTitle(interactionsTitle.value);
        }
        if (mainItems['pending_visits'] != null) {
          pendingVisitsTitle.value = mainItems['pending_visits'];
          updatePendingVisitsTitle(pendingVisitsTitle.value);
        }

        if (draftsData['title'] != null) {
          draftMenuTitle.value = draftsData['title'];
          updateDraftMenuTitle(draftMenuTitle.value);
        }

        final draftItems = draftsData['items'] ?? {};
        if (draftItems['draft_leads'] != null) {
          draftLeadTitle.value = draftItems['draft_leads'];
          updateDraftLeadTitle(draftLeadTitle.value);
        }

        if (draftItems['draft_interactions'] != null) {
          draftInteractionTitle.value = draftItems['draft_interactions'];
          updateDraftInteractionTitle(draftInteractionTitle.value);
        }
      } else {
        await _loadTicketsFromLocal();
      }
      update();
    } catch (e) {
      log("Error loading dashboard: $e");
      await _loadTicketsFromLocal();
    }
  }

  Future<void> _loadTicketsFromLocal() async {
    final localTickets = await getDataFromPrefsDecoded(
      key: "dashboard_tickets",
    );
    if (localTickets != null && localTickets is Map) {
      tickets.value = Map<String, dynamic>.from(localTickets);
    }
  }
}
