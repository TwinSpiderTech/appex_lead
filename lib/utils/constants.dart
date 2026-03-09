import 'package:appex_lead/component/custom_button.dart';
import 'package:appex_lead/main.dart';
import 'package:appex_lead/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

const double defaultHorizontalPaddingVal = 12.0;

const EdgeInsetsGeometry defaultPagePadding = EdgeInsets.symmetric(
  horizontal: defaultHorizontalPaddingVal,
);
const String baseURLKey = "base_url";
const String sessionToken = 'token';
const String userDetailsKey = 'user_details';
const String deviceToken = 'device_token';
const localNotificationsKey = 'notificaion_list';

customPopup({
  required BuildContext context,
  required String title,
  bool showConfrimBtn = true,
  bool showCancelBtn = true,
  double btnTxtSize = 14,
  double btnHeight = 40,
  double btnWidth = 14,
  String confirmBtnText = 'Confirm',
  String cancelBtnText = 'Cancel',
  Function? onConfirm,
  Function? onCancel,
  Color? confirmBtnColor,
  Widget? content,
  String? message,
  Color? backgroundColor,
}) async {
  await showDialog(
    context: context,
    builder: (_) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: backgroundColor ?? colorManager.bgDark,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Container(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 12,
                  top: 12,
                  bottom: 0,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: colorManager.secondaryColor.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: primaryTextStyle.copyWith(
                          color: colorManager.primaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: colorManager.whiteColor,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ),
              // Content Area
              Padding(
                padding: const EdgeInsets.only(
                  left: 24.0,
                  right: 24.0,
                  bottom: 32,
                ),
                child:
                    content ??
                    Text(
                      message ?? '',
                      style: primaryTextStyle.copyWith(
                        color: colorManager.textColor,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
              ),
              // Action Buttons
              if (showConfrimBtn || showCancelBtn)
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: 20,
                    top: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (showCancelBtn)
                        SizedBox(
                          height: btnHeight,
                          width: 80,
                          child: CustomButton(
                            padding: const EdgeInsets.all(4),
                            labelSize: btnTxtSize,
                            backgroundColor: Colors.transparent,
                            textColr: colorManager.textColor,
                            boderColor: colorManager.secondaryColor,
                            label: cancelBtnText,
                            onTap: () {
                              onCancel?.call();
                              Get.back();
                            },
                          ),
                        ),
                      if (showCancelBtn && showConfrimBtn)
                        const SizedBox(width: 12),
                      if (showConfrimBtn)
                        SizedBox(
                          height: btnHeight,
                          width: 80,
                          child: CustomButton(
                            padding: const EdgeInsets.all(4),
                            labelSize: btnTxtSize,
                            backgroundColor:
                                confirmBtnColor ?? colorManager.primaryColor,
                            textColr: colorManager.whiteColor,
                            label: confirmBtnText,
                            onTap: () {
                              onConfirm?.call();
                            },
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}

enum TemplateType { invoice, account, complaint, payment }

buildTableHeadersFromTableData(List<Map<String, dynamic>> data) {
  return List<String>.from(
    data.isEmpty
        ? []
        : List<String>.from(
            data.first.keys.map((k) => toParameterize(k)).toList(),
          ),
  );
}

List<TextAlign> buildTableCellAlignment(List<String> headers) {
  return List<TextAlign>.from(
    headers.isEmpty
        ? []
        : List.generate(headers.length, (index) {
            if (index == 0) return TextAlign.left; // first column
            if (index == headers.length - 1)
              return TextAlign.right; // last column
            return TextAlign.center; // all others
          }),
  );
}

launchCustomURL(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw 'Could not launch $url';
  }
}

const String darkTSLogo = 'assets/ts_logo_dark.png';
const String lightTSLogo = 'assets/ts_logo_light.png';
Widget tsWatermark() {
  return InkWell(
    onTap: () async {
      await launchCustomURL('https://www.twinspider.com/');
    },
    child: Image.asset(
      colorManager.isDark ? darkTSLogo : lightTSLogo,
      width: 160,
    ),
  );
}
