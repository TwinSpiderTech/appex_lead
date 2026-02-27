// import 'dart:developer';

// import 'package:appex_lead/main.dart';
// import 'package:appex_lead/model/form_model.dart';
// import 'package:appex_lead/utils/auth_service.dart';
// import 'package:get/get.dart';

// class FormController extends GetxController {
//   FormModel? form;
//   fetchFormFields(String url) async {
//     String token = await AuthService.getSessionToken() ?? '';
//     try {
//       var response = await api.getData(token, url);
//       if (response != null && response['status'] == 200) {
//         form = FormModel.fromJson(response);
//       }
//     } catch (e) {
//       log(e.toString());
//     }
//     update();
//   }

//   loadFormDetails() {
//     // get form from local storage

//     // get formfields from share prefs

//     // map field values over form fields
//   }

//   saveFormDataToLocalStorage(FormModel form) {}
//   saveFormFieldsToSharePrefs(List<FormFileds> formFields) {}
// }
