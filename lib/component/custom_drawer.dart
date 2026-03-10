import 'package:appex_lead/component/custom_switch.dart';
import 'package:appex_lead/service/app_infor_service.dart';
import 'package:appex_lead/utils/app_routes.dart';
import 'package:appex_lead/utils/constants.dart';
import 'package:appex_lead/utils/helpers.dart';
import 'package:appex_lead/view/form/drafts_screen.dart';
import 'package:appex_lead/view/interaction/interaction_drafts_screen.dart';
import 'package:appex_lead/view/form/forms.dart';
import 'package:appex_lead/view/leads/lead_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:appex_lead/main.dart';
import 'package:appex_lead/utils/auth_service.dart';
import 'package:appex_lead/view/app_settings.dart';
import 'package:appex_lead/view/shared_prefs_screen.dart';
import 'package:appex_lead/controller/dash/dash_controller.dart';
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
      width: MediaQuery.of(context).size.width * 0.6,
      child: Container(
        height: 400,
        decoration: BoxDecoration(color: colorManager.bgDark),
        child: SafeArea(
          child: Padding(
            // padding: const EdgeInsets.all(8.0),
            padding: EdgeInsets.only(left: 4, right: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 0,
                  color: colorManager.isDark
                      ? colorManager.accentColor
                      : colorManager.secondaryColor.withValues(alpha: .1),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    leading: Image.asset(
                      colorManager.appLogo,
                      width: MediaQuery.of(context).size.width * 0.1,
                    ),
                    title: Text(
                      "Field Force",
                      style: primaryTextStyle.copyWith(
                        fontSize: 18,
                        color: colorManager.textColor,
                      ),
                    ),
                    subtitle: token.isNotEmpty
                        ? Text(
                            email,
                            style: TextStyle(
                              fontSize: 11,
                              color: colorManager.textColor,
                            ),
                          )
                        : null,
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      DrawerListTile(
                        title: "All Leads",
                        icon: Icons.list_alt_outlined,
                        press: () {
                          Get.back();
                          Get.to(() => LeadScreen());
                        },
                      ),
                      ExpansionTile(
                        childrenPadding: EdgeInsets.only(bottom: 4),
                        tilePadding: EdgeInsets.only(right: 12),
                        title: DrawerListTile(title: "Draft", icon: Icons.save),
                        children: [
                          DrawerListTile(
                            title:
                                Get.find<DashController>().leadFormTitle.value,
                            icon: Icons.list_alt_outlined,
                            press: () {
                              Get.back();
                              Get.to(() => DraftsScreen());
                            },
                          ),
                          DrawerListTile(
                            title: Get.find<DashController>()
                                .interactionFormTitle
                                .value,
                            icon: Icons.chat_bubble,
                            press: () {
                              Get.back();
                              Get.to(() => InteractionDraftsScreen());
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Spacer(),
                Divider(color: Colors.grey.withValues(alpha: .3)),

                // Padding(
                //   padding: const EdgeInsets.only(left: 24.0),
                //   child: Text(
                //     'Preferences',
                //     style: TextStyle(color: colorManager.textColor),
                //   ),
                // ),
                // Divider(color: Colors.grey.withValues(alpha: .3)),
                if (kDebugMode)
                  DrawerListTile(
                    title: "Shared Prefs",
                    icon: Icons.storage,
                    press: () {
                      Get.to(() => SharePrefScreen());
                    },
                  ),
                if (kDebugMode && token.isNotEmpty)
                  DrawerListTile(
                    title: "Settings",
                    icon: Icons.settings,
                    press: () {
                      Get.to(() => AppSettings());
                    },
                  ),
                if (token.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 0.0),
                    child: DrawerListTile(
                      title: "Logout",
                      icon: Icons.logout,

                      press: () {
                        Get.back();
                        AuthService.logout();
                      },
                    ),
                  ),
                // Padding(
                //   padding: const EdgeInsets.only(bottom: 0.0),
                //   child: DrawerListTile(
                //     title: "Drafts",
                //     icon: Icons.drafts_outlined,
                //     press: () {
                //       Get.back();
                //       Get.to(() => DraftsScreen());
                //     },
                //   ),
                // ),
                if (kDebugMode && token.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 0.0),
                    child: DrawerListTile(
                      title: "Form",
                      icon: Icons.list_alt_outlined,

                      press: () {
                        Get.back();
                        Get.toNamed(AppPages.formsList);
                      },
                    ),
                  ),
                if (kDebugMode && token.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 0.0),
                    child: DrawerListTile(
                      title: "Drafts",
                      icon: Icons.drafts_outlined,
                      press: () {
                        Get.back();
                        Get.toNamed(AppPages.drafts);
                      },
                    ),
                  ),
                if (false && kDebugMode)
                  Card(
                    elevation: 0,
                    color: colorManager.secondaryColor.withValues(alpha: .1),
                    child: ListTile(
                      leading: Icon(
                        Icons.dark_mode,
                        color: colorManager.iconColor,
                      ),
                      title: Text(
                        "Dark Mode",
                        style: primaryTextStyle.copyWith(
                          fontSize: 14,
                          color: colorManager.textColor,
                        ),
                      ),
                      trailing: CustomSwitch(
                        width: 40,
                        height: 25,
                        value: colorManager.isDark,
                        onChanged: (newValue) {
                          colorManager.toggleTheme();
                        },
                        inactiveIcon: Icon(
                          Icons.dark_mode_outlined,
                          color: colorManager.primaryColor,
                          size: 14,
                        ),
                        activeIcon: Icon(
                          Icons.light_mode_outlined,
                          color: colorManager.primaryColor,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
                SizedBox(height: 10),
                Center(child: tsWatermark()),
                Center(
                  child: Text(
                    "Version ${AppInfo().version}",
                    style: primaryTextStyle.copyWith(
                      color: colorManager.textColor,
                      fontSize: 10,
                    ),
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key? key,
    // For selecting those three line once press "Command+D"
    required this.title,
    this.press,
    this.icon,
  }) : super(key: key);
  final IconData? icon;
  final String title;
  final VoidCallback? press;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minVerticalPadding: 0,
      dense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      onTap: press,

      leading: Icon(icon, color: colorManager.iconColor),
      title: Text(
        title,

        style: primaryTextStyle.copyWith(
          fontSize: 14,
          color: colorManager.textColor,
        ),
      ),
    );
  }
}
