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

class PendingVisitsScreen extends StatefulWidget {
  const PendingVisitsScreen({super.key});

  @override
  State<PendingVisitsScreen> createState() => _PendingVisitsScreenState();
}

class _PendingVisitsScreenState extends State<PendingVisitsScreen> {
  final Map<String, dynamic> extraParams = {
    'ownership_status': 'physical_verification_pending',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cont = Get.find<LeadController>();
      cont.getLeads(reset: true, extraParams: extraParams);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LeadController>(
      init: LeadController(),
      builder: (cont) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: Obx(
              () => CustomAppBar(
                onNavigateBack: () {
                  cont.clearForm();
                  Get.back();
                },
                title: Get.find<DashController>().pendingVisitsTitle.value,
              ),
            ),
          ),
          backgroundColor: colorManager.bgDark,
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: CustomInputField(
                  isRequired: false,
                  hint: "Search Pending Visits...",
                  prefixIcon: Icon(Icons.search, color: colorManager.dynamicColor),
                  controller: cont.pendingSearchCont,
                  onChanged: (val) {
                    cont.onSearchChanged(val, null, extraParams: extraParams);
                  },
                ),
              ),
              Expanded(
                child: Obx(
                  () => cont.physicalVerificationPendingLoading.value
                      ? Center(
                          child: CircularProgressIndicator(
                            color: colorManager.dynamicColor,
                          ),
                        )
                      : RefreshIndicator(
                          color: colorManager.dynamicColor,
                          onRefresh: () async {
                            await cont.getLeads(reset: true, extraParams: extraParams);
                          },
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            children: [
                              if (cont.physicalVerificationPendingLeads != null &&
                                  cont.physicalVerificationPendingLeads!.isEmpty)
                                SizedBox(
                                  height: 500,
                                  child: Center(
                                    child: Text(
                                      'No pending visits found!',
                                      style: primaryTextStyle.copyWith(
                                        color: colorManager.textColor,
                                      ),
                                    ),
                                  ),
                                )
                              else if (cont.physicalVerificationPendingLeads != null)
                                ...cont.physicalVerificationPendingLeads!.map((l) {
                                  return SummaryCard(
                                    title: l['business_name'] ?? '',
                                    subtitle: toParameterize(
                                      l['primary_next_action'] ?? '',
                                    ),
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
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
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
                      int currentPage = c.pvpPage;
                      bool hasNext = c.pvpHasNext;
                      bool isLoading = c.physicalVerificationPendingLoading.value;

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
                                      if (currentPage > 1) {
                                         c.pvpPage--,
                                         c.getLeads(extraParams: extraParams)
                                      }
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
                                      if (hasNext) {
                                         c.pvpPage++,
                                         c.getLeads(extraParams: extraParams)
                                      }
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
