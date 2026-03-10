import 'dart:developer';

import 'package:appex_lead/controller/theme/theme_controller.dart';
import 'package:appex_lead/utils/custom_toast_messages.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:appex_lead/component/custom_appbar.dart';
import 'package:appex_lead/component/custom_button.dart';
import 'package:appex_lead/component/custom_drawer.dart';
import 'package:appex_lead/component/custom_input_field.dart';
import 'package:appex_lead/controller/auth_controller.dart';
import 'package:appex_lead/main.dart';
import 'package:appex_lead/service/api_service.dart';
import 'package:appex_lead/utils/auth_service.dart';
import 'package:appex_lead/utils/constants.dart';
import 'package:appex_lead/utils/helpers.dart';
import 'package:appex_lead/view/dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: AuthController(),
      builder: (cont) {
        return Scaffold(
          key: cont.scaffoldKey,
          backgroundColor: colorManager.bgDark,
          drawer: CustomDrawer(),
          appBar: CustomAppBar(
            bgColor: colorManager.bgDark,
            // drawer button
            leading: Padding(
              padding: EdgeInsetsGeometry.only(left: 16, right: 10),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    toggleDrawer(cont.scaffoldKey);
                  });
                },
                child: Icon(
                  Icons.menu,
                  size: 32,
                  color: colorManager.iconColor,
                ),
              ),
            ),
            title: "Login",
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: cont.formKey,
                child: Column(
                  spacing: 12,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(colorManager.appLogo, height: 160),
                    Text(
                      'Enter your creadentials to login.',
                      style: primaryTextStyle.copyWith(fontSize: 16),
                    ),
                    CustomInputField(
                      controller: cont.emailCont,
                      prefixIcon: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18),
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedMail01,
                          color: colorManager.primaryColor,
                        ),
                      ),
                      label: "Email",
                    ),
                    Obx(() {
                      return CustomInputField(
                        obsecure: cont.obscure.value,
                        controller: cont.passCont,
                        suffixIcon: GestureDetector(
                          onTap: () {
                            cont.obscure.value = !cont.obscure.value;
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 18),
                            child: HugeIcon(
                              icon: cont.obscure.value
                                  ? HugeIcons.strokeRoundedViewOff
                                  : HugeIcons.strokeRoundedView,
                              color: colorManager.primaryColor,
                            ),
                          ),
                        ),
                        prefixIcon: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 18),
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedLock,
                            color: colorManager.primaryColor,
                          ),
                        ),
                        label: "Password",
                      );
                    }),
                    CustomButton(
                      backgroundColor: colorManager.primaryColor,
                      label: "Login",
                      onTap: () async {
                        showLoading(message: 'Logging in...');
                        FocusManager.instance.primaryFocus?.unfocus();
                        await cont.authenticate();
                      },
                    ),
                    if (kDebugMode)
                      Obx(() {
                        return CustomButton(
                          isLoading: cont.isLoading.value,
                          backgroundColor: colorManager.primaryColor,
                          label: "Dev Login",
                          onTap: () {
                            cont.authenticate(
                              email: 'ff@appex.com',
                              password: 'pass1234',
                            );
                          },
                        );
                      }),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
