import 'package:appex_lead/component/custom_switch.dart';
import 'package:appex_lead/service/app_infor_service.dart';
import 'package:appex_lead/service/firebase_service.dart';
import 'package:appex_lead/utils/app_routes.dart';
import 'package:appex_lead/utils/constants.dart';
import 'package:appex_lead/utils/helpers.dart';
import 'package:appex_lead/view/form/drafts_screen.dart';
import 'package:appex_lead/view/interaction/inteaction_screen.dart';
import 'package:appex_lead/view/interaction/interaction_drafts_screen.dart';
import 'package:appex_lead/view/form/forms.dart';
import 'package:appex_lead/view/leads/lead_screen.dart';
import 'package:appex_lead/view/leads/pending_visits_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:appex_lead/main.dart';
import 'package:appex_lead/utils/auth_service.dart';
import 'package:appex_lead/view/app_settings.dart';
import 'package:appex_lead/view/shared_prefs_screen.dart';
import 'package:appex_lead/controller/dash/dash_controller.dart';
import 'package:appex_lead/service/api_service.dart';
import 'package:appex_lead/view/auth/login.dart';
import 'package:hugeicons/hugeicons.dart';

class CustomDrawer extends StatefulWidget {
  CustomDrawer({Key? key}) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String token = '', email = '';

  _init() async {
    if (mounted) {
      token = await AuthService.getSessionToken() ?? '';
      // subdomain = await AuthService.getSubdomain() ?? '';
      email = await AuthService.getUserEmail() ?? '';
      setState(() {});
    }
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      backgroundColor: colorManager.bgDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // 1. Elegant Header Section
          _buildHeader(context),

          // 2. Menu Items
          Expanded(
            child: Obx(() {
              final dash = Get.find<DashController>();
              return ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildSectionHeader(dash.mainMenuTitle.value),
                  DrawerItem(
                    title: dash.leadsTitle.value,
                    icon: HugeIcons.strokeRoundedFolder01,
                    onTap: () {
                      Get.back();
                      Get.to(() => const LeadScreen());
                    },
                  ),
                  DrawerItem(
                    title: dash.interactionsTitle.value,
                    icon: HugeIcons.strokeRoundedMessage01,
                    onTap: () {
                      Get.back();
                      Get.to(() => const InteractionScreen());
                    },
                  ),
                  DrawerItem(
                    title: dash.pendingVisitsTitle.value,
                    icon: HugeIcons.strokeRoundedCalendar01,
                    onTap: () {
                      Get.back();
                      Get.to(() => const PendingVisitsScreen());
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildSectionHeader(dash.draftMenuTitle.value),
                  DrawerItem(
                    title: dash.draftLeadTitle.value,
                    icon: HugeIcons.strokeRoundedDocumentCode,
                    onTap: () {
                      Get.back();
                      Get.to(() => const DraftsScreen());
                    },
                  ),
                  DrawerItem(
                    title: dash.draftInteractionTitle.value,
                    icon: HugeIcons.strokeRoundedMessageQuestion,
                    onTap: () {
                      Get.back();
                      Get.to(() => const InteractionDraftsScreen());
                    },
                  ),
                  const SizedBox(height: 16),
                  if (kDebugMode) ...[
                    _buildSectionHeader("SYSTEM"),
                    DrawerItem(
                      title: "Shared Prefs",
                      icon: HugeIcons.strokeRoundedDatabase01,
                      onTap: () => Get.to(() => const SharePrefScreen()),
                    ),
                    DrawerItem(
                      title: "Settings",
                      icon: HugeIcons.strokeRoundedSettings03,
                      onTap: () => Get.to(() => const AppSettings()),
                    ),

                    if (token.isNotEmpty)
                      DrawerItem(
                        title: "Form Templates",
                        icon: HugeIcons.strokeRoundedNote01,
                        onTap: () {
                          Get.back();
                          Get.toNamed(AppPages.formsList);
                        },
                      ),
                  ],
                ],
              );
            }),
          ),

          // 3. Footer Section (Logout & Version)
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 32,
        bottom: 32,
        left: 24,
        right: 24,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorManager.accentColor,
            colorManager.accentColor,
            // colorManager.accentColor.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Image.asset(colorManager.appLogo, width: 40, height: 40),
          ),
          const SizedBox(height: 20),
          FutureBuilder(
            future: getUserName(),
            builder: (context, snapshot) {
              return Text(
                snapshot.data ?? "Field Force",
                style: primaryTextStyle.copyWith(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              );
            },
          ),
          if (email.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              email,
              style: primaryTextStyle.copyWith(
                color: colorManager.primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 16, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: colorManager.textColor.withOpacity(0.3),
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: Column(
        children: [
          if (token.isNotEmpty) ...[
            FirebaseHelper.DeleteManager(
              child: DrawerItem(
                title: "Delete Account",
                icon: HugeIcons.strokeRoundedDelete02,
                isDestructive: true,
                onTap: () {
                  Get.back();
                  deleteAccountPopup(context);
                },
              ),
            ),
            DrawerItem(
              title: "Logout",
              icon: HugeIcons.strokeRoundedLogout01,
              isDestructive: true,
              onTap: () {
                Get.back();
                AuthService.logout();
              },
            ),
          ],
          const SizedBox(height: 16),
          tsWatermark(),
          const SizedBox(height: 8),
          Text(
            "VERSION ${AppInfo().version}",
            style: TextStyle(
              color: colorManager.textColor.withOpacity(0.3),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class DrawerItem extends StatelessWidget {
  final String title;
  final dynamic icon;
  final VoidCallback onTap;
  final bool isDestructive;

  const DrawerItem({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        leading: HugeIcon(
          icon: icon,
          color: isDestructive ? Colors.redAccent : colorManager.primaryColor,
          size: 22,
        ),
        title: Text(
          title,
          style: primaryTextStyle.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDestructive
                ? Colors.redAccent
                : colorManager.textColor.withOpacity(0.8),
          ),
        ),
      ),
    );
  }
}
