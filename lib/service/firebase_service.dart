import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class FirebaseHelper {
  static final appConfig = FirebaseFirestore.instance
      .collection('App')
      .doc('config');

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    if (value is num) return value == 1;
    return false;
  }

  static Future<bool> canRegister() async {
    try {
      var snap = await appConfig.get();
      return _parseBool(snap.data()?['can_register']);
    } catch (e) {
      debugPrint("FirebaseHelper canRegister error: $e");
      return false;
    }
  }

  static Future<bool> canDeleteUser() async {
    try {
      var snap = await appConfig.get();
      return _parseBool(snap.data()?['can_delete']);
    } catch (e) {
      debugPrint("FirebaseHelper canDeleteUser error: $e");
      return false;
    }
  }

  static Widget RegisterManager({required Widget child}) {
    return StreamBuilder(
      stream: appConfig.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint("Firebase RegisterManager Error: ${snapshot.error}");
        }
        if (snapshot.hasData) {
          final data = snapshot.data!.data();
          if (_parseBool(data?['can_register'])) {
            return child;
          }
           // Otherwise fall through to return SizedBox.shrink()
        }
        return const SizedBox.shrink();
      },
    );
  }

  static Widget DeleteManager({required Widget child}) {
    return StreamBuilder(
      stream: appConfig.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint("Firebase DeleteManager Error: ${snapshot.error}");
        }
        if (snapshot.hasData) {
            final data = snapshot.data!.data();
          if (_parseBool(data?['can_delete'])) {
            return child;
          }
          // Otherwise fall through to return SizedBox.shrink()
        }
        return const SizedBox.shrink();
      },
    );
  }
}
