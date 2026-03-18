import 'dart:developer';

import 'package:appex_lead/component/custom_appbar.dart';
import 'package:appex_lead/component/custom_button.dart';
import 'package:appex_lead/component/custom_input_field.dart';
import 'package:appex_lead/controller/dash/dash_controller.dart';
import 'package:appex_lead/controller/lead/lead_controller.dart';
import 'package:appex_lead/main.dart';
import 'package:appex_lead/utils/helpers.dart';
import 'package:appex_lead/view/leads/lead_details_layout2.dart';
import 'package:appex_lead/component/summary_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

class LeadScreen extends StatefulWidget {
  const LeadScreen({super.key});

  @override
  State<LeadScreen> createState() => _LeadScreenState();
}

class _LeadScreenState extends State<LeadScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cont = Get.find<LeadController>();
      cont.getLeads(reset: true, status: 'overdue');
      cont.getLeads(reset: true, status: 'due_today');
      cont.getLeads(reset: true, status: 'completed');
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LeadController>(
      init: LeadController(),
      builder: (cont) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight + 48),
            child: Obx(
              () => CustomAppBar(
                onNavigateBack: () {
                  cont.clearForm();
                  Get.back();
                },
                title: Get.find<DashController>().leadFormTitle.value + 's',
                bottom: TabBar(
                  controller: cont.tabController,
                  indicatorColor: colorManager.primaryColor,
                  labelColor: colorManager.primaryColor,
                  unselectedLabelColor: colorManager.textColor,
                  tabs: [
                    Tab(
                      child: Text(
                        "Due Today",
                        style: primaryTextStyle.copyWith(
                          color: colorManager.whiteColor,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Tab(
                      child: Text(
                        "Overdue",
                        style: primaryTextStyle.copyWith(
                          color: colorManager.whiteColor,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Tab(
                      child: Text(
                        "Completed",
                        style: primaryTextStyle.copyWith(
                          color: colorManager.whiteColor,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          backgroundColor: colorManager.bgDark,
          body: TabBarView(
            controller: cont.tabController,
            children: [
              HistoryTab(
                cont: cont,
                history: cont.ongoingLeads,
                isLoading: cont.ongoingLoading,
                status: 'due_today',
              ),
              HistoryTab(
                cont: cont,
                history: cont.pendingLeads,
                isLoading: cont.pendingLoading,
                status: 'overdue',
              ),
              HistoryTab(
                cont: cont,
                history: cont.closedLeads,
                isLoading: cont.closedLoading,
                status: 'completed',
              ),
            ],
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 32),
            child: Column(
              spacing: 4,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: 50,
                  child: GetBuilder<LeadController>(
                    builder: (c) {
                      int currentPage = 1;
                      bool hasNext = false;
                      bool isLoading = false;

                      if (c.tabController.index == 0) {
                        currentPage = c.ongoingPage;
                        hasNext = c.ongoingHasNext;
                        isLoading = c.ongoingLoading.value;
                      } else if (c.tabController.index == 1) {
                        currentPage = c.pendingPage;
                        hasNext = c.pendingHasNext;
                        isLoading = c.pendingLoading.value;
                      } else if (c.tabController.index == 2) {
                        currentPage = c.closedPage;
                        hasNext = c.closedHasNext;
                        isLoading = c.closedLoading.value;
                      }

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 100,
                            child: isLoading
                                ? const SizedBox()
                                : currentPage > 1
                                ? CustomButton(
                                    disabled: currentPage <= 1,
                                    label: "Previous",
                                    onTap: () => {
                                      currentPage > 1 ? c.previousPage() : null,
                                    },
                                  )
                                : null,
                          ),
                          if (currentPage.toString() != '1')
                            Text(
                              "Page $currentPage",
                              style: primaryTextStyle.copyWith(
                                color: colorManager.textColor,
                              ),
                            ),
                          SizedBox(
                            width: 100,
                            child: isLoading
                                ? const SizedBox()
                                : hasNext
                                ? CustomButton(
                                    disabled: !hasNext,
                                    label: "Next",
                                    onTap: () => {
                                      hasNext ? c.nextPage() : null,
                                    },
                                  )
                                : null,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class HistoryTab extends StatelessWidget {
  final LeadController cont;
  final List<Map<String, dynamic>>? history;
  final RxBool isLoading;
  final String status;

  const HistoryTab({
    super.key,
    required this.cont,
    this.history,
    required this.isLoading,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: CustomInputField(
            isRequired: false,
            hint:
                "Search ${Get.find<DashController>().leadFormTitle.value}s...",
            prefixIcon: Icon(Icons.search, color: colorManager.dynamicColor),
            controller: status == 'pending'
                ? cont.pendingSearchCont
                : status == 'ongoing'
                ? cont.ongoingSearchCont
                : cont.closedSearchCont,
            onChanged: (val) {
              cont.onSearchChanged(val, status);
            },
          ),
        ),
        Expanded(
          child: Obx(
            () => isLoading.value
                ? Center(
                    child: CircularProgressIndicator(
                      color: colorManager.dynamicColor,
                    ),
                  )
                : RefreshIndicator(
                    color: colorManager.dynamicColor,
                    onRefresh: () async {
                      await cont.getLeads(reset: true, status: status);
                    },
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      children: [
                        if (history != null && history!.isEmpty)
                          SizedBox(
                            height: 500,
                            child: Center(
                              child: Text(
                                'No ${Get.find<DashController>().leadFormTitle.value.toLowerCase()} found!',
                                style: primaryTextStyle.copyWith(
                                  color: colorManager.textColor,
                                ),
                              ),
                            ),
                          )
                        else if (history != null)
                          ...history!.map((l) {
                            return SummaryCard(
                              title: l['business_name'] ?? '',
                              subtitle: l['person_name'] ?? '',
                              nextFollowup: l['next_followup'] ?? '',
                              icon: HugeIcons.strokeRoundedHospital02,
                              onTap: () {
                                String url =
                                    cont.leadEndPoint.value +
                                    l['id'].toString();
                                log("${l}");
                                Get.to(
                                  () =>
                                      LeadDetailsLayout2(url: url, cont: cont),
                                );
                              },
                            );
                          }),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
