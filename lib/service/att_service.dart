import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/material.dart';

class ATTService {
  static Future<void> requestATT(BuildContext context) async {
    try {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      
      if (status == TrackingStatus.notDetermined) {
        // Optional: Show a custom dialog explaining why you need tracking
        // This is highly recommended by Apple to improve "Allow" rates
        // and ensures the app is in a state ready to show the system prompt.
        
        // await _showExplanationDialog(context);
        
        // Wait a bit to ensure the UI is ready
        await Future.delayed(const Duration(milliseconds: 1500));
        
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
    } catch (e) {
      debugPrint("ATT Service Error: $e");
    }
  }

  // Example of a pre-permission dialog
  static Future<void> _showExplanationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Help us improve'),
          content: const Text(
            'We use identifiers to provide a more personalized experience and improve lead verification. '
            'On the next screen, please select "Allow" to help us maintain the quality of our service.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Continue'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
