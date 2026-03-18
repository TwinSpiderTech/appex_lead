import 'dart:io';
import 'package:appex_lead/utils/custom_toast_messages.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:get/get.dart';

class ImagePreviewScreen extends StatelessWidget {
  final String imagePath;
  final String title;

  const ImagePreviewScreen({
    Key? key,
    required this.imagePath,
    this.title = "Image Preview",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(title, style: const TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            onPressed: () => _downloadImage(context),
            icon: const Icon(Icons.download, color: Colors.white),
          ),
        ],
      ),
      body: Container(
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: Hero(
          tag: imagePath,
          child: PhotoView(
            imageProvider: imagePath.startsWith('http')
                ? NetworkImage(imagePath)
                : FileImage(File(imagePath)) as ImageProvider,
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2.5,
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            loadingBuilder: (context, event) =>
                const Center(child: CircularProgressIndicator()),
            errorBuilder: (context, error, stackTrace) => const Center(
              child: Text(
                "Could not load image",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _downloadImage(BuildContext context) async {
    try {
      // Check for gallery access permissions
      bool hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        hasAccess = await Gal.requestAccess();
      }

      if (!hasAccess) {
        showErrorMessage(message: "Gallery access denied");
        return;
      }

      EasyLoading.show(status: 'Downloading...');

      String? finalPath;

      if (imagePath.startsWith('http')) {
        // Handle network image
        final tempDir = await getTemporaryDirectory();
        final path =
            "${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";

        await Dio().download(imagePath, path);
        finalPath = path;
      } else {
        // Handle local image
        finalPath = imagePath;
      }

      // Save to gallery
      await Gal.putImage(finalPath);

      EasyLoading.dismiss();
      showSuccessMessage(message: "Image saved to gallery");
    } catch (e) {
      EasyLoading.dismiss();
      showErrorMessage(message: "Failed to download image: $e");
    }
  }
}
