import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:appex_lead/main.dart';

showErrorMessage({required String message}) {
  EasyLoading.instance.backgroundColor = Colors.red;
  EasyLoading.instance.textColor = Colors.white;
  EasyLoading.showError(message);
}

showSuccessMessage({required String message}) {
  EasyLoading.instance.backgroundColor = Colors.green;
  EasyLoading.instance.textColor = Colors.white;
  EasyLoading.showSuccess(message);
}

showToast({required String message}) {
  EasyLoading.instance.backgroundColor = colorManager.secondaryColor;
  EasyLoading.instance.textColor = colorManager.bgDark;
  EasyLoading.showToast(message);
}

////need to fix
// showMessageDialog({required String message}) {
//   await showCustomPopup
// }

showLoading({required String message}) {
  EasyLoading.instance.backgroundColor = colorManager.secondaryColor;
  EasyLoading.instance.textColor = colorManager.bgDark;
  EasyLoading.showToast(message);
}
