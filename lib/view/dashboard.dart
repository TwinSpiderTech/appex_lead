import 'package:appex_lead/component/custom_dropdown.dart';
import 'package:appex_lead/component/custom_line_chart.dart';
import 'package:appex_lead/component/dynamic_table.dart';
import 'package:appex_lead/controller/dash/dash_controller.dart';
import 'package:appex_lead/utils/app_routes.dart';
import 'package:appex_lead/utils/constants.dart';
import 'package:appex_lead/view/camera/camera_screen.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:appex_lead/component/custom_drawer.dart';
import 'package:appex_lead/main.dart';
import 'package:appex_lead/utils/helpers.dart';
import 'package:appex_lead/utils/dummy_data.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String filterType = 'weekly';

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: DashController(),
      builder: (controller) {
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: colorManager.isDark
              ? colorManager.bgDark
              : Colors.grey.shade50,
          drawer: CustomDrawer(),
          body: RefreshIndicator(
            color: colorManager.primaryColor,
            onRefresh: () async {},
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: colorManager.accentColor,
                  pinned: true,
                  snap: true,
                  floating: true,
                  expandedHeight: 150,
                  toolbarHeight: 80,
                  collapsedHeight: 80,
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
                    centerTitle: true,
                  ),
                  leadingWidth: 0,
                  leading: SizedBox(width: 0),
                  title: Row(
                    spacing: 12,
                    children: [
                      Container(
                        child: GestureDetector(
                          onTap: () {
                            _scaffoldKey.currentState?.openDrawer();
                          },
                          child: Icon(
                            Icons.menu, // color: colorManager.iconColor,
                            color: colorManager.primaryColor,
                            size: 32,
                          ),
                        ),
                      ),

                      Text(
                        "Dashboard",
                        style: primaryTextStyle.copyWith(
                          fontSize: 22,
                          color: colorManager.whiteColor,
                        ),
                      ),
                      Spacer(),
                      IconButton(
                        onPressed: () {
                          Get.toNamed(AppPages.notificationScreen);
                        },
                        icon: HugeIcon(
                          icon: HugeIcons.strokeRoundedNotification01,
                          color: colorManager.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: Column(
                    // spacing: 12,
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [],
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: colorManager.primaryColor,
            onPressed: () {
              Get.to(() => CameraScreen());
            },
            child: Icon(Icons.camera, color: colorManager.whiteColor),
          ),
        );
      },
    );
  }

  Widget _buildReusableCard({
    required String title,
    required Function() onTap,
    required icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        // padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorManager.primaryColor,
          // color: colorManager.isDark
          //     ? colorManager.bgLight
          //     : colorManager.secondaryColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              HugeIcon(icon: icon, color: colorManager.whiteColor, size: 32),
              Text(
                title,
                style: primaryTextStyle.copyWith(
                  color: colorManager.whiteColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableCard({
    required String title,
    List<List<String>>? rows,
    List<Map<String, dynamic>>? data,
    required List<String> headers,
    String? groupBy,
    Function()? onTap,
    Color? groupRowColor,
  }) {
    return Column(
      spacing: defaultHorizontalPaddingVal,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                toParameterize(title),
                style: primaryTextStyle.copyWith(
                  fontSize: 18,
                  color: colorManager.secondaryColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            GestureDetector(
              onTap: () {
                onTap?.call();
              },
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedArrowRight01,
                color: colorManager.secondaryColor,
              ),
            ),
          ],
        ),
        DynamicTable(
          headerBgColor: colorManager.accentColor,
          isScrollable: true,

          // clipText: false,
          colSpans: headers.map((e) => 1).toList(),
          alignments: List.generate(
            headers.length,
            (index) => index == 0
                ? TextAlign.start
                : index == headers.length - 1
                ? TextAlign.end
                : TextAlign.start,
          ),
          onRowTap: (index, row) {
            print("Tapped row $index: $row");
          },
          headers: headers,

          headerStyle: primaryTextStyle.copyWith(
            color: colorManager.whiteColor,
          ),
          cellStyle: primaryTextStyle.copyWith(color: colorManager.textColor),
          showTotal: false,
          rows: rows,
          data: data,
          groupBy: groupBy,
          groupRowColor: groupRowColor,
        ),
        if ((rows != null && rows.isEmpty))
          Center(
            child: Text(
              'No Data Available',
              style: primaryTextStyle.copyWith(
                color: colorManager.textColor,
                // fontSize: 18,
              ),
            ),
          ),
      ],
    );
  }
}
