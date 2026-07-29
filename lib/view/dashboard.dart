import 'package:appex_lead/component/custom_drawer.dart';
import 'package:appex_lead/component/summary_card.dart';
import 'package:appex_lead/controller/dash/dash_controller.dart';
import 'package:appex_lead/controller/lead/lead_controller.dart';
import 'package:appex_lead/main.dart';
import 'package:appex_lead/utils/app_routes.dart';
import 'package:appex_lead/utils/device_id_helper.dart';
import 'package:appex_lead/utils/helpers.dart';
import 'package:appex_lead/view/app_settings.dart';
import 'package:appex_lead/view/form/drafts_screen.dart';
import 'package:appex_lead/view/interaction/inteaction_screen.dart';
import 'package:appex_lead/view/interaction/interaction_drafts_screen.dart';
import 'package:appex_lead/view/interaction/interaction_form.dart';

import 'package:appex_lead/view/leads/lead_details_layout2.dart';
import 'package:appex_lead/view/leads/lead_screen.dart';
import 'package:appex_lead/view/form/form_details.dart';
import 'package:appex_lead/view/tracking/route_history.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hugeicons/hugeicons.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isFabExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<DashController>().refreshDashboard();
    });
  }

  void _toggleFab() {
    setState(() {
      _isFabExpanded = !_isFabExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: handleLocationAccess(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final hasLocationAccess = snapshot.data!;
        if (!hasLocationAccess) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.0),
                    child: Text(
                      "Location is required to continue",
                      style: primaryTextStyle.copyWith(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      await Geolocator.openAppSettings();
                    },
                    child: const Text("Grant Permission"),
                  ),
                ],
              ),
            ),
          );
        }
        // GPS enabled, show normal dashboard
        return GetBuilder<DashController>(
          builder: (controller) {
            return Scaffold(
              key: _scaffoldKey,
              backgroundColor: colorManager.whiteColor,
              drawer: CustomDrawer(),
              body: RefreshIndicator(
                color: colorManager.primaryColor,
                onRefresh: () => controller.refreshDashboard(),
                child: CustomScrollView(
                  slivers: [
                    _buildAppBar(controller),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            _buildTickcetGrid(controller),
                            const SizedBox(height: 24),
                            _buildSectionHeader(
                              controller.upcomingInteractionTitle.value,
                              controller.upcomingInteractionSubTitle.value,
                              onTap: () {
                                Get.find<LeadController>().tabController.index =
                                    0;
                                Get.to(() => const LeadScreen());
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildUpcomingList(controller),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              floatingActionButton: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isFabExpanded) ...[
                    _buildFabOption(
                      icon: HugeIcons.strokeRoundedUserAdd01,
                      label: controller.leadTicketTitle.value,
                      onTap: () {
                        _toggleFab();
                        Get.to(
                          () => FormDetails(
                            url: "/api/v1/business/leads/get_form_template",
                            title: controller.leadTicketTitle.value,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAppBar(DashController controller) {
    return SliverAppBar(
      backgroundColor: colorManager.accentColor,
      pinned: true,
      snap: true,
      floating: true,
      expandedHeight: 140,
      toolbarHeight: 80,
      collapsedHeight: 80,
      leadingWidth: 0,
      leading: const SizedBox(width: 0),
      title: Row(
        children: [
          GestureDetector(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            child: Icon(Icons.menu, color: colorManager.primaryColor, size: 32),
          ),
          const SizedBox(width: 12),
          Text(
            "Dashboard",
            style: primaryTextStyle.copyWith(
              fontSize: 22,
              color: colorManager.whiteColor,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Get.toNamed(AppPages.notificationScreen),
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedNotification01,
              color: colorManager.primaryColor,
            ),
          ),
        ],
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.only(top: 80, bottom: 0),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 18.0, right: 18.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        controller.headerTitle.value,
                        style: primaryTextStyle.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: colorManager.primaryColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Obx(
                        () => Text(
                          controller.isLoading.value
                              ? "******"
                              : controller.headerSubTitle.value,
                          style: primaryTextStyle.copyWith(
                            fontSize: 14,
                            color: colorManager.whiteColor,
                          ),
                          maxLines: 2,

                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(DashController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Obx(
        () => TextField(
          controller: controller.searchCont,
          onChanged: controller.onSearchChanged,
          decoration: InputDecoration(
            hintText:
                "Search ${controller.leadFormTitle.value.toLowerCase()}s...",
            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    String subtitle, {
    VoidCallback? onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        () {
          final dash = Get.find<DashController>();
          if (title == dash.upcomingInteractionTitle.value) {
            return Obx(
              () => Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dash.upcomingInteractionTitle.value,
                    style: primaryTextStyle.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorManager.primaryColor,
                    ),
                  ),
                  Text(
                    dash.upcomingInteractionSubTitle.value,
                    style: primaryTextStyle.copyWith(
                      fontSize: 14,
                      color: colorManager.textColor,
                    ),
                  ),
                ],
              ),
            );
          }
          return Text(
            title,
            style: primaryTextStyle.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorManager.primaryColor,
            ),
          );
        }(),

        onTap != null
            ? TextButton(
                onPressed: onTap,
                child: Text(
                  "View All",
                  style: TextStyle(color: colorManager.primaryColor),
                ),
              )
            : const SizedBox(),
      ],
    );
  }

  Widget _buildUpcomingList(DashController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const SizedBox(
          height: 160,
          child: Center(child: CircularProgressIndicator()),
        );
      }
      if (controller.upcomingLeads.isEmpty) {
        return _buildEmptyState(
          "No upcoming ${controller.leadFormTitle.value.toLowerCase()}s",
        );
      }
      return ListView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.upcomingLeads.length,
        itemBuilder: (context, index) {
          final lead = controller.upcomingLeads[index];
          return _buildUpcomingFollowUpCard(controller, lead);
        },
      );
    });
  }

  Widget _buildUpcomingCard(
    DashController controller,
    Map<String, dynamic> lead, {
    bool isGrid = false,
  }) {
    return GestureDetector(
      onTap: () => Get.to(
        () => LeadDetailsLayout2(
          url: controller.getLeadDetailUrl(lead),
          cont: Get.find<LeadController>(),
        ),
      ),
      child: Container(
        width: isGrid ? null : 200,
        margin: isGrid ? EdgeInsets.zero : const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorManager.primaryColor.withOpacity(0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorManager.primaryColor.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedUser,
                color: colorManager.primaryColor,
                size: 20,
              ),
            ),
            const Spacer(),
            Text(
              lead['business_name'] ?? 'Undefined',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: primaryTextStyle.copyWith(
                fontWeight: FontWeight.bold,

                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              lead['person_name'] ?? 'Contact person',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: primaryTextStyle.copyWith(
                color: colorManager.textColor,
                fontSize: 13,
              ),
            ),
            if (lead['next_followup'] != null &&
                lead['next_followup'].toString().isNotEmpty)
              const SizedBox(height: 2),
            Text(
              lead['next_followup'] ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: primaryTextStyle.copyWith(
                color: colorManager.textColor,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingList(DashController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(child: CircularProgressIndicator()),
        );
      }
      if (controller.pendingLeads.isEmpty) {
        return _buildEmptyState("No pending leads found");
      }
      return ListView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.pendingLeads.length,
        itemBuilder: (context, index) {
          final lead = controller.pendingLeads[index];
          return _buildPendingCard(controller, lead);
        },
      );
    });
  }

  Widget _buildPendingCard(
    DashController controller,
    Map<String, dynamic> lead,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: colorManager.accentColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        onTap: () => Get.to(
          () => LeadDetailsLayout2(
            url: controller.getLeadDetailUrl(lead),
            cont: Get.find<LeadController>(),
          ),
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorManager.accentColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: HugeIcon(
            icon: HugeIcons.strokeRoundedClock01,
            color: colorManager.accentColor,
            size: 20,
          ),
        ),
        title: Text(
          lead['business_name'] ?? 'Undefined Business',
          style: primaryTextStyle.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        subtitle: lead['person_name'] != null && lead['person_name'].isNotEmpty
            ? Text(lead['person_name'] ?? '')
            : null,
        trailing: Icon(Icons.arrow_forward_ios, size: 14),
      ),
    );
  }

  Widget _buildUpcomingFollowUpCard(
    DashController controller,
    Map<String, dynamic> lead,
  ) {
    return SummaryCard(
      title: lead['business_name'] ?? 'Undefined Business',
      subtitle: toParameterize(lead['primary_next_action'] ?? ''),
      nextFollowup: lead['next_followup'] ?? '',
      icon: HugeIcons.strokeRoundedClock01,
      onTap: () => Get.to(
        () => LeadDetailsLayout2(
          url: controller.getLeadDetailUrl(lead),
          cont: Get.find<LeadController>(),
        ),
      ),
    );
  }

  Widget _buildDraftsList(DashController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Center(child: CircularProgressIndicator()),
        );
      }
      if (controller.drafts.isEmpty) {
        return _buildEmptyState("No saved drafts");
      }
      return ListView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.drafts.length > 3 ? 3 : controller.drafts.length,
        itemBuilder: (context, index) {
          final draft = controller.drafts[index];
          final String formattedDate = _formatDraftDate(draft['updated_at']);
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            elevation: 0,
            // color: colorManager.accentColor.withOpacity(0.08),
            color: colorManager.accentColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: ListTile(
              onTap: () async {
                final String url = draft['template_url'] ?? '';
                if (url.isNotEmpty) {
                  await Get.to(
                    () => FormDetails(
                      url: url,
                      draftData: draft,
                      title: draft['business_name'] ?? 'Untitled Draft',
                    ),
                  );
                  controller.fetchDrafts();
                }
              },
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorManager.whiteColor.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.description_outlined,
                  color: colorManager.whiteColor,
                  size: 20,
                ),
              ),
              title: Text(
                draft['title'] ?? 'Untitled Draft',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: primaryTextStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: colorManager.whiteColor,
                ),
              ),
              subtitle: Text(
                "Last updated: $formattedDate",
                style: primaryTextStyle.copyWith(
                  fontSize: 12,
                  color: colorManager.whiteColor.withOpacity(0.6),
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: colorManager.whiteColor,
              ),
            ),
          );
        },
      );
    });
  }

  String _formatDraftDate(String? updatedAt) {
    try {
      if (updatedAt == null) return '';
      final dt = DateTime.parse(updatedAt);
      return previewableDateTimeFormat(dt);
    } catch (_) {
      return updatedAt ?? '';
    }
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text(message, style: TextStyle(color: Colors.grey.shade500)),
      ),
    );
  }

  DashController get dashController => Get.find<DashController>();

  Widget _buildFabOption({
    required dynamic icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(width: 12),
        FloatingActionButton.small(
          heroTag: label,
          backgroundColor: colorManager.primaryColor,
          elevation: 4,
          onPressed: onTap,
          child: HugeIcon(icon: icon, color: Colors.white, size: 20),
        ),
      ],
    );
  }

  _buildTickcetGrid(DashController controller) {
    return Obx(() {
      final Map<String, dynamic> gridItems = {
        'add_lead': {
          "title": controller.leadTicketTitle.value,
          "subtitle": "",

          "icon": HugeIcons.strokeRoundedHospital02,
          "screen": FormDetails(
            url: "/api/v1/business/leads/get_form_template",
            title: controller.leadTicketTitle.value,
          ),
        },
        'add_interaction': {
          "title": controller.interactionTicketTitle.value,
          "subtitle": "",
          "icon": HugeIcons.strokeRoundedMessage01,
          "screen": InteractionForm(
            url: "/api/v1/business/interactions/get_form_template",
            title: controller.interactionTicketTitle.value,
          ),
        },
        'my_leads': {
          "title": "${controller.leadFormTitle.value}",
          "subtitle": "",
          "icon": HugeIcons.strokeRoundedHospital02,
          "screen": LeadScreen(),
        },
        'my_interactions': {
          "title": "${controller.interactionFormTitle.value}s",
          "subtitle": "",
          "icon": HugeIcons.strokeRoundedMessage01,
          "screen": InteractionScreen(),
        },
        'draft_leads': {
          "title": "Draft ${controller.leadFormTitle.value}s",
          "subtitle": "",
          "icon": HugeIcons.strokeRoundedFile01,
          "screen": DraftsScreen(),
        },
        'draft_interactions': {
          "title": "Draft ${controller.interactionFormTitle.value}s",
          "subtitle": "",
          "icon": HugeIcons.strokeRoundedFile02,
          "screen": InteractionDraftsScreen(),
        },
        'route_tracking': {
          "title": "Route Tracking",
          "subtitle": "Track your movement",
          "icon": HugeIcons.strokeRoundedLocation01,
          "screen": const RouteHistoryScreen(),
        },
      };
      final ticketKeys = controller.tickets.keys.toList();
      final tickets = controller.tickets;

      return GridView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,

        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
        ),
        itemCount: tickets.length,
        itemBuilder: (context, index) {
          String key = ticketKeys[index];
          final item = gridItems[key];
          final value = item;
          bool isTicketAvailable = controller.tickets[key] != null;
          return isTicketAvailable
              ? GestureDetector(
                  onTap: () {
                    // print(key);
                    // print(controller.tickets[key]);
                    Get.to(value["screen"]);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorManager.primaryColor.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorManager.primaryColor.withOpacity(0.5),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white,
                          child: HugeIcon(
                            icon: value["icon"],
                            color: colorManager.primaryColor,
                            size: 20,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          dig(tickets, [key, 'title']) ?? "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: primaryTextStyle.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dig(tickets, [key, 'subtitle']) ?? "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: primaryTextStyle.copyWith(
                            color: colorManager.textColor,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SizedBox();
        },
      );
    });
  }
}
