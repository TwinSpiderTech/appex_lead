import 'package:appex_lead/component/custom_appbar.dart';
import 'package:appex_lead/controller/theme/theme_controller.dart';
import 'package:appex_lead/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import '../../controller/camera/camera_controller.dart';
import 'camera_preview_screen.dart';

class CameraScreen extends StatelessWidget {
  final bool usedOnForm;
  final Function(String)? onProcessed;

  CameraScreen({Key? key, this.usedOnForm = false, this.onProcessed})
    : super(key: key);

  final CustomCameraController controller = Get.put(CustomCameraController());

  @override
  Widget build(BuildContext context) {
    controller.usedOnForm = usedOnForm;
    controller.onProcessed = onProcessed;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: CustomAppBar(title: "Capture Image"),
      body: Obx(() {
        if (!controller.isInitialized.value ||
            controller.cameraController == null) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        return Stack(
          children: [
            Positioned.fill(child: CameraPreview(controller.cameraController!)),

            // Capture Button
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () async {
                    final path = await controller.captureImage();
                    if (path != null && path.isNotEmpty) {
                      if (usedOnForm) {
                        Get.back(result: path);
                      } else {
                        final result = await Get.to(
                          () => CameraPreviewScreen(),
                        );
                        if (result != null) {
                          Get.back(result: result);
                        }
                      }
                    }
                  },
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorManager.primaryColor,
                        width: 4,
                      ),
                      color: Colors.transparent,
                    ),
                    child: Center(
                      child: Container(
                        height: 65,
                        width: 65,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorManager.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
