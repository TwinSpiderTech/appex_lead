import 'package:appex_lead/component/custom_drawer.dart';
import 'package:appex_lead/controller/dash/dash_controller.dart';
import 'package:appex_lead/controller/lead/lead_controller.dart';
import 'package:appex_lead/main.dart';
import 'package:appex_lead/utils/app_routes.dart';
import 'package:appex_lead/utils/constants.dart';
import 'package:appex_lead/utils/helpers.dart';
import 'package:appex_lead/view/camera/camera_screen.dart';
import 'package:appex_lead/view/interaction/interaction_form.dart';
import 'package:appex_lead/view/leads/lead_details_layout2.dart';
import 'package:appex_lead/view/leads/lead_screen.dart';
import 'package:appex_lead/view/form/form_details.dart';
import 'package:appex_lead/view/form/drafts_screen.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isFabExpanded = false;

  void _toggleFab() {
    setState(() {
      _isFabExpanded = !_isFabExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashController>(
      init: DashController(),
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
                        _buildSearchBar(controller),
                        const SizedBox(height: 24),
                        _buildSectionHeader("Upcoming Follow-ups", () {
                          Get.find<LeadController>().tabController.index = 0;
                          Get.to(() => const LeadScreen());
                        }),
                        const SizedBox(height: 12),
                        _buildUpcomingList(controller),
                        const SizedBox(height: 24),
                        _buildSectionHeader("Drafts", () {
                          Get.to(() => const DraftsScreen());
                        }),
                        const SizedBox(height: 12),
                        _buildDraftsList(controller),
                        _buildSectionHeader("Pending Leads", () {
                          Get.find<LeadController>().tabController.index = 1;
                          Get.to(() => const LeadScreen());
                        }),
                        _buildPendingList(controller),
                        // const SizedBox(height: 12),
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
                  label: "Add Lead",
                  onTap: () {
                    _toggleFab();
                    Get.to(
                      () => const FormDetails(
                        url: "/api/v1/business/leads/get_form_template",
                        title: "Add New Lead",
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildFabOption(
                  icon: HugeIcons.strokeRoundedPlusSignSquare,
                  label: "Add Interaction",
                  onTap: () {
                    _toggleFab();
                    Get.to(() => const InteractionForm());
                  },
                ),
                const SizedBox(height: 12),
              ],
              FloatingActionButton(
                backgroundColor: colorManager.primaryColor,
                onPressed: _toggleFab,
                child: Icon(
                  _isFabExpanded ? Icons.close : Icons.add,
                  color: Colors.white,
                ),
              ),
            ],
          ),
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
      expandedHeight: 150,
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
          padding: const EdgeInsets.only(top: 110.0, bottom: 20),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 18.0),
                  child: Obx(() {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          controller.isLoading.value
                              ? "******"
                              : controller.headerTitle,
                          style: primaryTextStyle.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: colorManager.primaryColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          controller.isLoading.value
                              ? "******"
                              : controller.headerSubTitle,
                          style: primaryTextStyle.copyWith(
                            fontSize: 12,
                            color: colorManager.whiteColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    );
                  }),
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
      child: TextField(
        controller: controller.searchCont,
        onChanged: controller.onSearchChanged,
        decoration: InputDecoration(
          hintText: "Search your leads...",
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: primaryTextStyle.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorManager.primaryColor,
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(
            "View All",
            style: TextStyle(color: colorManager.primaryColor),
          ),
        ),
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
        return _buildEmptyState("No upcoming leads");
      }
      return SizedBox(
        height: 160,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.upcomingLeads.length,
          itemBuilder: (context, index) {
            final lead = controller.upcomingLeads[index];
            return _buildUpcomingCard(controller, lead);
          },
        ),
      );
    });
  }

  Widget _buildUpcomingCard(
    DashController controller,
    Map<String, dynamic> lead,
  ) {
    return GestureDetector(
      onTap: () => Get.to(
        () => LeadDetailsLayout2(
          url: controller.getLeadDetailUrl(lead),
          cont: Get.find<LeadController>(),
        ),
      ),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 12),
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
        subtitle: Text(lead['lead_status'] ?? 'Pending'),
        trailing: Icon(Icons.arrow_forward_ios, size: 14),
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
}
