import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:field_force/utils/constants.dart';
import 'package:field_force/utils/helpers.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gal/gal.dart';
import 'package:intl/intl.dart';

class CustomCameraController extends GetxController {
  // cameraController provides access to the physical camera hardware (preview, flash, taking pictures).
  CameraController? cameraController;

  // A list to store the available cameras on the device (usually back and front).
  List<CameraDescription> cameras = [];

  // isInitialized tracks if the camera is ready to display a preview.
  var isInitialized = false.obs;

  // isCapturing prevents the user from taking multiple pictures at the exact same time.
  var isCapturing = false.obs;

  var capturedImagePath = "".obs;

  var latitude = 0.0.obs;
  var longitude = 0.0.obs;
  var readableAddress = "".obs;

  // captureTime holds the exact DateTime when the photo was taken. Rx<DateTime?> makes it nullable observable.
  var captureTime = Rx<DateTime?>(null);

  // Background processing flags
  bool usedOnForm = false;
  Function(String)? onProcessed;

  // onInit is a lifecycle method provided by GetX that runs as soon as this controller is created.
  @override
  void onInit() {
    super.onInit();
    // We immediately start initializing the camera and checking permissions when this controller loads.
    _initCameraAndLocation();
  }

  // This private method handles the setup phases: Requesting permissions -> Finding cameras -> Starting camera.
  Future<void> _initCameraAndLocation() async {
    // 1. Request OS permissions for camera and location from the user.
    await requestPermissions();

    try {
      // 2. Fetch the list of physical cameras available on the device.
      cameras = await availableCameras();

      // If the device has at least one camera...
      if (cameras.isNotEmpty) {
        // 3. Initialize the camera controller using the first camera (usually the back camera).
        cameraController = CameraController(
          cameras[0],

          // ResolutionPreset.high gives us a good quality image without taking up too much memory.
          // handleResolutionDynamicaaly
          ResolutionPreset.medium,
          // We disable audio because we are only taking pictures, not recording video.
          enableAudio: false,
        );

        // 4. Actually start the hardware connection to the camera.
        await cameraController!.initialize();

        // 5. Tell the UI that the camera is ready to be shown to the user.
        isInitialized.value = true;
      }
    } catch (e) {
      // Log any errors that happen during initialization.
      debugPrint("Camera initiation error: $e");
    }
  }

  // Helper method to request multiple permissions at once using the `permission_handler` plugin.
  Future<void> requestPermissions() async {
    await [Permission.camera, Permission.location].request();
  }

  Future<String?> captureImage() async {
    // Safety check: Don't do anything if the camera isn't ready.
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return null;
    }

    // Safety check: Don't do anything if we are already in the middle of taking a picture.
    if (isCapturing.value) return null;

    // Lock the capture mechanism so we don't trigger it twice.
    isCapturing.value = true;

    try {
      // 1. Instruct the camera hardware to snap a picture. It returns an XFile object.
      final XFile image = await cameraController!.takePicture();

      // 2. Temporarily save the raw, unmodified image's path.
      capturedImagePath.value = image.path;

      if (usedOnForm) {
        // If used on form, we don't call Get.back() here.
        // The UI (CameraScreen) will handle the navigation.

        // Start background processing
        _processInBackground(image.path);
        return image.path;
      }

      // 3. Show a loading spinner dialog because processing the image and getting GPS can take a few seconds.
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible:
            false, // Prevent the user from closing the loading dialog manually.
      );

      // 4. Fetch the user's current GPS location and street address.
      await getLocationDetails();

      // 5. Record the exact time the capture process reached this point.
      captureTime.value = DateTime.now();

      // 6. Draw the location and time onto the image itself.
      final processedPath = await _generateProcessedImage();

      // If drawing was successful, update the path to point to our newly modified image instead of the raw one.
      if (processedPath != null) {
        // Compress the final processed image to 1MB
        final finalCompressedFile = await compressTo1MB(File(processedPath));
        capturedImagePath.value = finalCompressedFile?.path ?? processedPath;
      }

      // Close the loading dialog if it is still open.
      if (Get.isDialogOpen ?? false) Get.back();
      return capturedImagePath.value;
    } catch (e) {
      // If anything fails, make sure we still close the loading dialog so the app doesn't freeze.
      if (Get.isDialogOpen ?? false) Get.back();
      debugPrint("Error capturing image: $e");
      return null;
    } finally {
      // Unlock the capture mechanism so the user can take another picture later.
      if (!usedOnForm) {
        isCapturing.value = false;
      }
    }
  }

  Future<void> _processInBackground(String rawPath) async {
    try {
      // 1. Fetch the user's current GPS location and street address.
      await getLocationDetails();

      // 2. Record the exact time.
      captureTime.value = DateTime.now();

      // 3. Draw the location and time onto the image itself.
      final processedPath = await _generateProcessedImage();

      if (processedPath != null) {
        // Compress the final processed image to 1MB
        final finalCompressedFile = await compressTo1MB(File(processedPath));
        final finalPath = finalCompressedFile?.path ?? processedPath;

        capturedImagePath.value = finalPath;
        if (onProcessed != null) {
          onProcessed!(finalPath);
        }
      }
    } catch (e) {
      debugPrint("Background processing error: $e");
    } finally {
      isCapturing.value = false;
    }
  }

  // Fetches GPS coordinates and converts them into a human-readable street address.
  Future<String> getLocationDetails() async {
    try {
      // Check if the phone's overarching location services (GPS hardware) are turned on.
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        readableAddress.value = "Location services disabled";
        return "";
      }

      // Check our specific app's permission status.
      LocationPermission permission = await Geolocator.checkPermission();

      // If we don't have permission, request it from the user.
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          readableAddress.value = "Location permission denied";
          return "";
        }
      }

      // Some users permanently deny permission, so we can't even ask anymore.
      if (permission == LocationPermission.deniedForever) {
        readableAddress.value = "Location permissions permanently denied";
        return "";
      }

      // Fetch the highly-accurate current GPS coordinates (lat, lng).
      // We add a 5-second timeout to prevent it from hanging indefinitely on iOS if GPS signal is weak.
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 5),
          ),
        );
      } catch (e) {
        debugPrint(
          "Current position fetch failed or timed out: $e. Falling back to last known position.",
        );
        // If current position fails, try to get the last known location for a faster response.
        position = await Geolocator.getLastKnownPosition();
      }

      if (position == null) {
        readableAddress.value = "Location unavailable";
        return "";
      }

      // Save coordinates to our observables
      latitude.value = position.latitude;
      longitude.value = position.longitude;

      // Reverse-geocode: Ask the OS to turn these coordinates into a real-world address (street, city, etc).
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        // Take the most confident guess (the first item in the list).
        Placemark place = placemarks[0];
        String address = "";

        // Piece together the address string step by step.
        if (place.street != null && place.street!.isNotEmpty) {
          address += "${place.street}, ";
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          address += "${place.subLocality}, ";
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          address += "${place.locality}, ";
        }
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          address += "${place.administrativeArea}";
        }

        // Clean up any extra trailing commas or spaces at the end of the text.
        address = address.trim();
        if (address.endsWith(',')) {
          address = address.substring(0, address.length - 1);
        }

        readableAddress.value = address;
      } else {
        readableAddress.value = "Unknown address";
      }
    } catch (e) {
      debugPrint("Error getting location: $e");
      readableAddress.value = "Error getting location";
    }
    return readableAddress.value;
  }

  // This method uses Flutter's native Canvas API to "paint" the text onto the raw image memory.
  Future<String?> _generateProcessedImage() async {
    try {
      // 1. Read the raw image file from the disk into memory as bytes.
      final File file = File(capturedImagePath.value);
      final Uint8List bytes = await file.readAsBytes();

      // 2. Decode those bytes into a `ui.Image` object that Flutter's Canvas can understand.
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frame = await codec.getNextFrame();
      final ui.Image image = frame.image;

      // 3. Define dimensions. We limit the max resolution to 4000 pixels on whatever side is largest
      // to prevent the final image from being too massive in file size when uploading.
      double targetWidth = image.width.toDouble();
      double targetHeight = image.height.toDouble();
      const double maxResolution = 1920.0;

      if (targetWidth > maxResolution) {
        targetHeight =
            targetHeight *
            (maxResolution / targetWidth); // scale height proportionally
        targetWidth = maxResolution;
      } else if (targetHeight > maxResolution) {
        targetWidth =
            targetWidth *
            (maxResolution / targetHeight); // scale width proportionally
        targetHeight = maxResolution;
      }

      // 4. Setup the canvas tools. PictureRecorder records everything we draw.
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final ui.Canvas canvas = ui.Canvas(recorder);

      // 5. Draw the raw captured photo onto the canvas first (acting as the background).
      canvas.drawImageRect(
        image,
        ui.Rect.fromLTWH(
          0,
          0,
          image.width.toDouble(),
          image.height.toDouble(),
        ), // Source rectangle (entire original image)
        ui.Rect.fromLTWH(
          0,
          0,
          targetWidth,
          targetHeight,
        ), // Destination rectangle (rescaled size)
        ui.Paint(), // Default painting rules
      );

      // 6. Calculate sizes for the dark transparent card we will draw at the bottom.
      final double cardHeight =
          targetHeight * 0.19; // Card takes up 19% of image height
      final double padding =
          targetHeight * 0.02; // Small padding from the edges

      // Define the rectangle shape for the card.
      final ui.Rect cardRect = ui.Rect.fromLTWH(
        padding,
        targetHeight - cardHeight - padding, // Position it at the bottom
        targetWidth - (padding * 2), // Make it almost full width
        cardHeight,
      );

      // Define the paint style for the card: Semi-transparent black.
      final ui.Paint cardPaint = ui.Paint()
        ..color = const ui.Color(0x99000000)
        ..style = ui.PaintingStyle.fill;

      // 7. Draw the semi-transparent card with rounded corners onto the canvas.
      canvas.drawRRect(
        ui.RRect.fromRectAndRadius(cardRect, ui.Radius.circular(padding)),
        cardPaint,
      );

      // Set the font size relative to the card size so it scales nicely on all phones.
      // Set the font size relative to the card size so it scales nicely on all phones.
      final double regularFontSize = cardHeight * 0.10;
      final double addressFontSize = cardHeight * 0.13;

      // TextPainter is used to measure and format text before drawing it.
      final textPainter = TextPainter(textDirection: ui.TextDirection.ltr);

      // 8. Draw the Street Address Text (First Line - Bigger)
      textPainter.text = TextSpan(
        text: readableAddress.value.isEmpty
            ? "Location unknown"
            : readableAddress.value,
        style: TextStyle(
          color: Colors.white,
          fontSize: addressFontSize,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout(maxWidth: cardRect.width - (padding * 2));
      textPainter.paint(
        canvas,
        Offset(cardRect.left + padding, cardRect.top + padding),
      );

      // Track vertical position
      double currentY =
          cardRect.top + padding + textPainter.height + (padding * 0.4);

      // 9. Draw the Latitude/Longitude (Second Line - Left) and Timestamp (Second Line - Right)

      // A. Lat/Long (Left)
      textPainter.text = TextSpan(
        text:
            "Lat: ${latitude.value.toStringAsFixed(3)}, Long: ${longitude.value.toStringAsFixed(3)}",
        style: TextStyle(
          color: Colors.white,
          fontSize: regularFontSize,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout(maxWidth: (cardRect.width - (padding * 2)) * 0.6);
      textPainter.paint(canvas, Offset(cardRect.left + padding, currentY));

      // B. Timestamp (Right)
      final timeStr = captureTime.value != null
          ? previewableDateTimeFormat(captureTime.value!)
          : "";
      final timestampPainter = TextPainter(
        text: TextSpan(
          text: timeStr,
          style: TextStyle(
            color: Colors.yellow,
            fontSize: regularFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout(maxWidth: (cardRect.width - (padding * 2)) * 0.4);

      timestampPainter.paint(
        canvas,
        Offset(cardRect.right - padding - timestampPainter.width, currentY),
      );

      // Move Y-axis down
      currentY += textPainter.height + (padding * 0.4);

      // 10. Draw Captured By Text (Third Line)
      final String name = await getUserName();
      textPainter.text = TextSpan(
        text: "Captured By: $name",
        style: TextStyle(
          color: Colors.white,
          fontSize: regularFontSize,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout(maxWidth: cardRect.width - (padding * 2));
      textPainter.paint(canvas, Offset(cardRect.left + padding, currentY));

      // 11. Stop recording drawing commands.
      final ui.Picture picture = recorder.endRecording();

      // Render the drawing commands into a final cohesive image in memory.
      final ui.Image processedImage = await picture.toImage(
        targetWidth.toInt(),
        targetHeight.toInt(),
      );

      // Convert that image into PNG format bytes.
      final ByteData? byteData = await processedImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) return null;

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      // 12. Save the new PNG bytes to a temporary local file on the device.
      final directory = await getApplicationDocumentsDirectory();
      final String newPath =
          '${directory.path}/processed_${DateTime.now().millisecondsSinceEpoch}.png';
      final File newFile = File(newPath);
      await newFile.writeAsBytes(pngBytes);

      // Return the file path so the rest of the app knows where to find the modified image.
      return newPath;
    } catch (e) {
      debugPrint("Error modifying image: $e");
      return null;
    }
  }

  // Uses the 'gal' plugin to save our generated file path directly to the phone's native Photos / Gallery app.
  Future<bool> saveToGallery() async {
    try {
      // Don't do anything if we don't have an image path.
      if (capturedImagePath.value.isEmpty) return false;

      // Request permission from OS to access the photo gallery.
      bool hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        hasAccess = await Gal.requestAccess();
      }

      // If the user granted permission...
      if (hasAccess) {
        // ...copy our local app image into the phone's public gallery.
        await Gal.putImage(capturedImagePath.value);
        return true; // Success!
      }
      return false; // Permission denied.
    } catch (e) {
      debugPrint("Error saving to gallery: $e");
      return false;
    }
  }

  // Lifecycle method called when this controller is destroyed (e.g., user leaves the camera screen).
  // It's critically important to turn off the hardware camera to save battery and avoid bugs.
  @override
  void onClose() {
    cameraController?.dispose();
    super.onClose();
  }
}
