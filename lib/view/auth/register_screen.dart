import 'package:ts_fieldforce/component/custom_appbar.dart';
import 'package:ts_fieldforce/component/custom_button.dart';
import 'package:ts_fieldforce/component/custom_input_field.dart';
import 'package:ts_fieldforce/controller/auth_controller.dart';
import 'package:ts_fieldforce/utils/custom_toast_messages.dart';
import 'package:ts_fieldforce/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ts_fieldforce/main.dart'; // Ensure error is avoided

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: AuthController(),
      builder: (cont) {
        return Scaffold(
          backgroundColor: colorManager.bgDark,
          appBar: CustomAppBar(
            canNavigate: true,
            bgColor: colorManager.bgDark,
            title: "Register",
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: cont.registerFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(colorManager.appLogo, height: 160),
                    const SizedBox(height: 12),
                    Text(
                      'Create a new account',
                      style: primaryTextStyle.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    CustomInputField(
                      controller: cont.nameCont,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Name is required";
                        }
                        return null;
                      },
                      prefixIcon: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedUser,
                          color: colorManager.primaryColor,
                        ),
                      ),
                      label: "Name",
                    ),
                    const SizedBox(height: 12),
                    CustomInputField(
                      controller: cont.emailCont,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Email is required";
                        }
                        if (!GetUtils.isEmail(value)) {
                          return "Enter a valid email address";
                        }
                        return null;
                      },
                      prefixIcon: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedMail01,
                          color: colorManager.primaryColor,
                        ),
                      ),
                      label: "Email",
                    ),
                    const SizedBox(height: 12),
                    Obx(() {
                      return CustomInputField(
                        obsecure: cont.obscure.value,
                        controller: cont.passCont,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Password is required";
                          }
                          if (value.length < 6) {
                            return "Password must be at least 6 characters";
                          }
                          return null;
                        },
                        suffixIcon: GestureDetector(
                          onTap: () {
                            cont.obscure.value = !cont.obscure.value;
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            child: HugeIcon(
                              icon: cont.obscure.value
                                  ? HugeIcons.strokeRoundedViewOff
                                  : HugeIcons.strokeRoundedView,
                              color: colorManager.primaryColor,
                            ),
                          ),
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedLock,
                            color: colorManager.primaryColor,
                          ),
                        ),
                        label: "Password",
                      );
                    }),
                    const SizedBox(height: 12),
                    Obx(() {
                      return CustomInputField(
                        obsecure: cont.confirmObscure.value,
                        controller: cont.confirmPassCont,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            showToast(message: "Confirm Password is required");
                            return "Confirm Password is required";
                          }
                          if (value != cont.passCont.text) {
                            showToast(message: "Passwords do not match");
                            return "Passwords do not match";
                          }
                          return null;
                        },
                        suffixIcon: GestureDetector(
                          onTap: () {
                            cont.confirmObscure.value =
                                !cont.confirmObscure.value;
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            child: HugeIcon(
                              icon: cont.confirmObscure.value
                                  ? HugeIcons.strokeRoundedViewOff
                                  : HugeIcons.strokeRoundedView,
                              color: colorManager.primaryColor,
                            ),
                          ),
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedLock,
                            color: colorManager.primaryColor,
                          ),
                        ),
                        label: "Confirm Password",
                      );
                    }),
                    const SizedBox(height: 24),
                    CustomButton(
                      backgroundColor: colorManager.primaryColor,
                      label: "Register",
                      onTap: () async {
                        FocusManager.instance.primaryFocus?.unfocus();
                        await cont.register(
                          email: cont.emailCont.text,
                          name: cont.nameCont.text,
                          password: cont.passCont.text,
                        );
                      },
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
