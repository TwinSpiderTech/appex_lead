import 'package:ts_fieldforce/component/custom_appbar.dart';
import 'package:ts_fieldforce/component/custom_button.dart';
import 'package:ts_fieldforce/controller/dash/dash_controller.dart';
import 'package:ts_fieldforce/controller/lead/lead_controller.dart';
import 'package:ts_fieldforce/main.dart';
import 'package:ts_fieldforce/utils/helpers.dart';
import 'package:ts_fieldforce/view/leads/lead_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LeadHistory extends StatefulWidget {
  const LeadHistory({super.key});

  @override
  State<LeadHistory> createState() => _LeadHistoryState();
}

class _LeadHistoryState extends State<LeadHistory> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cont = Get.find<LeadController>();
      cont.getLeads(reset: true, status: completedKey);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    return GetBuilder<LeadController>(
      init: LeadController(),
      builder: (cont) {
        return Scaffold(
          backgroundColor: colorManager.bgDark,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight + 48),
            child: Obx(
              () => CustomAppBar(
                onNavigateBack: () {
                  cont.clearForm();
                  Get.back();
                },
                title:
                    Get.find<DashController>().complatedLeadsTitle.value + 's',
              ),
            ),
          ),

          body: HistoryTab(
            cont: cont,
            history: cont.closedLeads,
            isLoading: cont.closedLoading,
            status: completedKey,
          ),

          floatingActionButtonLocation:
              FloatingActionButtonLocation.miniCenterDocked,
          floatingActionButton: keyboardVisible
              ? null
              : Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 32,
                  ),
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

                            currentPage = c.closedPage;
                            hasNext = c.closedHasNext;
                            isLoading = c.closedLoading.value;

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 100,
                                  child: isLoading
                                      ? const SizedBox()
                                      : (kDebugMode || currentPage > 1)
                                      ? CustomButton(
                                          disabled: currentPage <= 1,
                                          label: "Previous",
                                          onTap: () => {
                                            currentPage > 1
                                                ? c.previousPage()
                                                : null,
                                          },
                                        )
                                      : null,
                                ),
                                if (kDebugMode || currentPage.toString() != '1')
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
                                      : (kDebugMode || hasNext)
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
