import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

import 'package:appex_lead/component/custom_button.dart';
import 'package:appex_lead/main.dart';
import 'package:appex_lead/utils/helpers.dart';
import 'package:appex_lead/view/auth/login.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
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

void deleteAccountPopup(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: colorManager.bgDark,
      title: Text(
        "Delete Account",
        style: primaryTextStyle.copyWith(
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        "Are you sure you want to delete your account? This action cannot be undone.",
        style: primaryTextStyle,
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text("Cancel", style: primaryTextStyle),
        ),
        TextButton(
          onPressed: () async {
            Get.back(); // close dialog
            final response = await api.deleteAccount();
            if (response != null && response['status'] == 200) {
              await logoutUser(toastMessage: 'Account deleted.');
              Get.offAll(() => const LoginScreen());
            }
          },
          child: Text(
            "Delete",
            style: primaryTextStyle.copyWith(color: Colors.red),
          ),
        ),
      ],
    ),
  );
}

// enum Resolution { low, medium, high }

// handleResolutionDynamicaaly(String resolution) {
//   switch (resolution) {
//     case "low":
//       return ResolutionPreset.low;
//     case "medium":
//       return ResolutionPreset.medium;
//     case "high":
//       return ResolutionPreset.high;
//     default:
//       return ResolutionPreset.low;
//   }
// }

Future<File?> compressTo1MB(File file) async {
  const int targetSize = 1024 * 1024; // 1MB

  int quality = 70;
  int minWidth = 1920;
  int minHeight = 1080;

  // If it's a PNG file (like our processed image), use the robust Dart image package 
  // to avoid native platform limitations in FlutterImageCompress.
  if (file.path.toLowerCase().endsWith('.png')) {
    final bytes = await file.readAsBytes();
    img.Image? decodedImage = img.decodeImage(bytes);
    if (decodedImage == null) return null;

    int currentQuality = 80;
    List<int> jpgBytes = img.encodeJpg(decodedImage, quality: currentQuality);

    // Loop until we reach <1MB
    while (jpgBytes.length > targetSize && currentQuality > 10) {
      currentQuality -= 10;
      
      // If quality is getting too low, downscale the resolution
      if (currentQuality < 40) {
        currentQuality = 80;
        final newWidth = (decodedImage!.width * 0.8).toInt();
        decodedImage = img.copyResize(decodedImage, width: newWidth);
      }
      
      jpgBytes = img.encodeJpg(decodedImage!, quality: currentQuality);
    }

    final compressedFile = File('${file.path}_compressed.jpg');
    await compressedFile.writeAsBytes(jpgBytes);
    return compressedFile;
  }

  // If it's a regular camera JPG, use FlutterImageCompress for speed.
  Uint8List? result;
  do {
    result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      quality: quality,
      minWidth: minWidth,
      minHeight: minHeight,
      format: CompressFormat.jpeg,
    );

    if (result == null) return null;

    if (result.lengthInBytes <= targetSize) break;

    // Reduce quality first
    quality -= 10;

    // If quality too low, reduce resolution
    if (quality < 40) {
      quality = 80;
      minWidth = (minWidth * 0.8).toInt();
      minHeight = (minHeight * 0.8).toInt();
    }
  } while (result.lengthInBytes > targetSize);

  final compressedFile = File('${file.path}_compressed.jpg');
  await compressedFile.writeAsBytes(result);

  return compressedFile;
}
