import 'dart:developer';

import 'package:ts_fieldforce/controller/theme/theme_controller.dart';
import 'package:ts_fieldforce/service/firebase_service.dart';
import 'package:ts_fieldforce/utils/custom_toast_messages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ts_fieldforce/component/custom_appbar.dart';
import 'package:ts_fieldforce/component/custom_button.dart';
import 'package:ts_fieldforce/component/custom_drawer.dart';
import 'package:ts_fieldforce/component/custom_input_field.dart';
import 'package:ts_fieldforce/controller/auth_controller.dart';
import 'package:ts_fieldforce/main.dart';
import 'package:ts_fieldforce/service/api_service.dart';
import 'package:ts_fieldforce/utils/auth_service.dart';
import 'package:ts_fieldforce/utils/constants.dart';
import 'package:ts_fieldforce/utils/helpers.dart';
import 'package:ts_fieldforce/view/dashboard.dart';
import 'package:ts_fieldforce/view/auth/register_screen.dart';

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
          appBar: CustomAppBar(
            canNavigate: false,
            bgColor: colorManager.bgDark,
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
                              email: 'demo@fieldforce.com',
                              password: 'pass1234',
                            );
                          },
                        );
                      }),
                    const SizedBox(height: 12),
                    FirebaseHelper.RegisterManager(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account?",
                            style: primaryTextStyle.copyWith(fontSize: 14),
                          ),
                          TextButton(
                            onPressed: () {
                              Get.to(() => const RegisterScreen());
                            },
                            child: Text(
                              "Register",
                              style: primaryTextStyle.copyWith(
                                fontSize: 14,
                                color: colorManager.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
