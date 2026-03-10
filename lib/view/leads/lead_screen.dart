import 'dart:developer';

import 'package:appex_lead/component/custom_appbar.dart';
import 'package:appex_lead/component/custom_button.dart';
import 'package:appex_lead/component/custom_input_field.dart';
import 'package:appex_lead/controller/lead/lead_controller.dart';
import 'package:appex_lead/main.dart';
import 'package:appex_lead/utils/helpers.dart';
import 'package:appex_lead/view/leads/lead_details_layout2.dart';
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
      cont.getLeads(reset: true, status: 'pending');
      cont.getLeads(reset: true, status: 'ongoing');
      cont.getLeads(reset: true, status: 'closed');
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LeadController>(
      init: LeadController(),
      builder: (cont) {
        return Scaffold(
          appBar: CustomAppBar(
            onNavigateBack: () {
              cont.clearForm();
              Get.back();
            },
            title: 'Leads',
            bottom: TabBar(
              controller: cont.tabController,
              indicatorColor: colorManager.primaryColor,
              labelColor: colorManager.primaryColor,
              unselectedLabelColor: colorManager.textColor,
              tabs: [
                Tab(
                  child: Text(
                    "Ongoing",
                    style: primaryTextStyle.copyWith(
                      color: colorManager.whiteColor,
                      fontSize: 16,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    "Pending",
                    style: primaryTextStyle.copyWith(
                      color: colorManager.whiteColor,
                      fontSize: 16,
                    ),
                  ),
                ),

                Tab(
                  child: Text(
                    "Closed",
                    style: primaryTextStyle.copyWith(
                      color: colorManager.whiteColor,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
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
                status: 'ongoing',
              ),
              HistoryTab(
                cont: cont,
                history: cont.pendingLeads,
                isLoading: cont.pendingLoading,
                status: 'pending',
              ),
              HistoryTab(
                cont: cont,
                history: cont.closedLeads,
                isLoading: cont.closedLoading,
                status: 'closed',
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
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
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
            hint: "Search Leads...",
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
                                'No lead found!',
                                style: primaryTextStyle.copyWith(
                                  color: colorManager.textColor,
                                ),
                              ),
                            ),
                          )
                        else if (history != null)
                          ...history!.map((l) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: InkWell(
                                onTap: () {
                                  String url =
                                      cont.leadEndPoint.value +
                                      l['id'].toString();
                                  log("${l}");
                                  Get.to(
                                    () => LeadDetailsLayout2(
                                      url: url,
                                      cont: cont,
                                    ),
                                  );
                                },
                                child: Card(
                                  color: colorManager.accentColor.withValues(),
                                  child: ListTile(
                                    leading: HugeIcon(
                                      icon: HugeIcons.strokeRoundedFolder01,
                                      color: colorManager.whiteColor,
                                    ),
                                    title: Text(
                                      l['business_name'] ?? '',
                                      style: primaryTextStyle.copyWith(
                                        color: colorManager.whiteColor,
                                      ),
                                    ),
                                    subtitle: Text(
                                      l['person_name'] ?? '',
                                      style: primaryTextStyle.copyWith(
                                        color: colorManager.whiteColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                    trailing: HugeIcon(
                                      icon: HugeIcons.strokeRoundedArrowRight01,
                                      color: colorManager.whiteColor,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                              // child: Container(
                              //   onTap: () {
                              //     cont.loadComplaintDetails(h);
                              //   },
                              //   status: h.status,
                              //   title: h.subject,
                              //   subtitle: h.complaintCategory,
                              // ),
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
