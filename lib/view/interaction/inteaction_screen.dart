import 'package:appex_lead/controller/dash/dash_controller.dart';
import 'package:appex_lead/controller/interaction/interaction_controller.dart';
import 'package:appex_lead/main.dart';
import 'package:appex_lead/utils/helpers.dart';
import 'package:appex_lead/view/interaction/interaction_details_layout.dart';
import 'package:appex_lead/component/summary_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

class InteractionScreen extends StatefulWidget {
  final String url;
  const InteractionScreen({
    super.key,
    this.url = "/api/v1/business/interactions",
  });

  @override
  State<InteractionScreen> createState() => _InteractionScreenState();
}

class _InteractionScreenState extends State<InteractionScreen> {
  final controller = Get.put(InteractionController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchInteractions(widget.url, reset: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorManager.whiteColor,
      appBar: AppBar(
        title: Obx(
          () => Text(
            "My ${Get.find<DashController>().interactionFormTitle.value}s",
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: colorManager.accentColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final List<DateTime>? picked = await showCustomDateRangePicker(
                context: context,
                initialDateRange:
                    controller.startDate.value != null &&
                        controller.endDate.value != null
                    ? DateTimeRange(
                        start: controller.startDate.value!,
                        end: controller.endDate.value!,
                      )
                    : null,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );

              if (picked != null && picked.length == 2) {
                controller.startDate.value = picked[0];
                controller.endDate.value = picked[1];
                controller.fetchInteractions(
                  controller.currentUrl,
                  reset: true,
                );
              }
            },
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedCalendarUser,
              color: colorManager.whiteColor,
            ),
          ),
          SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          _buildActiveFilters(),
          _buildSearchBar(),
          Expanded(child: _buildInteractionList()),
        ],
      ),
    );
  }

  Widget _buildActiveFilters() {
    return Obx(() {
      if (controller.startDate.value == null ||
          controller.endDate.value == null) {
        return const SizedBox.shrink();
      }

      final String start =
          "${controller.startDate.value!.day}/${controller.startDate.value!.month}/${controller.startDate.value!.year}";
      final String end =
          "${controller.endDate.value!.day}/${controller.endDate.value!.month}/${controller.endDate.value!.year}";

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: colorManager.accentColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorManager.accentColor.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              HugeIcon(
                icon: HugeIcons.strokeRoundedCalendarUser,
                size: 18,
                color: colorManager.accentColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Date Range Filter",
                      style: TextStyle(
                        color: colorManager.primaryColor.withOpacity(0.6),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      "$start - $end",
                      style: TextStyle(
                        color: colorManager.primaryColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  controller.startDate.value = null;
                  controller.endDate.value = null;
                  controller.fetchInteractions(
                    controller.currentUrl,
                    reset: true,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colorManager.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: colorManager.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: controller.searchCont,
          onChanged: controller.onSearchChanged,
          decoration: InputDecoration(
            hintText: "Search...",
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey.shade500),
            icon: Icon(Icons.search, color: Colors.grey.shade400),
          ),
        ),
      ),
    );
  }

  Widget _buildInteractionList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.interactions.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 64,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                "No interactions found",
                style: TextStyle(color: Colors.grey.shade500),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        color: colorManager.primaryColor,
        onRefresh: () => controller.fetchInteractions(widget.url, reset: true),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount:
              controller.interactions.length + (controller.hasNextPage ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == controller.interactions.length) {
              controller.loadMore();
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final interaction = controller.interactions[index];
            return _buildInteractionCard(interaction);
          },
        ),
      );
    });
  }

  Widget _buildInteractionCard(Map<String, dynamic> interaction) {
    final title =
        interaction['business_name'] ?? interaction['title'] ?? 'Interaction';
    final type = toParameterize(interaction['interaction_type'] ?? '');
    final status = toParameterize(interaction['setup_status'] ?? '');
    final phone = interaction['mobile_no'] ?? '';
    final notes = interaction['notes'] ?? '';
    final location = dig(interaction, ['gps_points', 'position']) ?? '';
    final date =
        interaction['visit_date'] ??
        interaction['interaction_date'] ??
        interaction['updated_at'] ??
        interaction['created_at'] ??
        '';

    return SummaryCard(
      title: title.toString(),
      type: type,
      nextFollowup: interaction['next_followup']?.toString(),
      icon: HugeIcons.strokeRoundedMessage01,
      onTap: () {
        Get.to(() => InteractionDetailsLayout(interactionData: interaction));
      },
    );
  }

  Widget _buildInfoRow(dynamic icon, String text, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HugeIcon(icon: icon, color: Colors.grey.shade400, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
