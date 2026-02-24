import 'dart:io';
import 'package:appex_lead/component/custom_appbar.dart';
import 'package:appex_lead/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/camera/camera_controller.dart';

class CameraPreviewScreen extends StatelessWidget {
  CameraPreviewScreen({Key? key}) : super(key: key);

  final CustomCameraController controller = Get.find<CustomCameraController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: CustomAppBar(title: "Preview"),

      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Obx(() {
                if (controller.capturedImagePath.value.isEmpty) {
                  return const Text(
                    "No image captured",
                    style: TextStyle(color: Colors.white),
                  );
                }
                return Image.file(
                  File(controller.capturedImagePath.value),
                  fit: BoxFit.contain,
                );
              }),
            ),
          ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.refresh),
                  label: const Text("Retake"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    Get.dialog(
                      const Center(child: CircularProgressIndicator()),
                      barrierDismissible: false,
                    );

                    bool saved = await controller.saveToGallery();

                    if (Get.isDialogOpen ?? false) Get.back();

                    if (saved) {
                      Get.snackbar(
                        "Success",
                        "Saved to Gallery!",
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                      );
                    } else {
                      Get.snackbar(
                        "Error",
                        "Failed to save to Gallery",
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                    }
                  },
                  icon: Icon(Icons.photo_library),
                  label: Text("Save"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorManager.accentColor,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Get.back(result: controller.capturedImagePath.value);
                  },
                  icon: Icon(Icons.check),
                  label: Text("Use Photo"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorManager.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
