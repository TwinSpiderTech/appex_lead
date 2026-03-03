import 'dart:developer';

import 'package:appex_lead/main.dart';
import 'package:appex_lead/model/lead_model.dart';
import 'package:appex_lead/utils/auth_service.dart';
import 'package:appex_lead/utils/custom_toast_messages.dart';
import 'package:appex_lead/utils/helpers.dart';
import 'package:appex_lead/utils/urls.dart';
import 'package:appex_lead/view/form/lead_details_screen.dart';
import 'package:get/get.dart';

class DashController extends GetxController {
  RxBool isLoading = false.obs;
  // Map<String, dynamic> dashboardData = <String, dynamic>{};
  List<Map<String, dynamic>> leads = [];
  Map<String, dynamic> chartData = {};
  Map<String, dynamic> tables = {};
  String headerTitle = "Welcome to Appex Leads";
  String headerSubTitle = "Here's what's happening with your leads.";

  RxBool hasNextPage = false.obs;
  int currentPage = 1;

  var response = {
    "response_status": "success",
    "messages": [],
    "meta": {},
    "data": {
      "fields_record": {
        "visit_proof_image":
            "http://localhost:3000/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBb0FDIiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--f6c498e1fdea51b7e43ab984209519c4349c8454/logo.png",
        "business_name": "asdfasds Cehckasdfssaaa",
        "mobile_no": "03001234567",
        "area_id": 1,
        "setup_status": "grey_structure",
        "gps_points":
            "{latitutde: 1212.23, longitude: 121.32, location: \"HTi sis agujr\"}",
        "person_name": "Testing Doctor Name",
        "person_designation": "director",
        "phone_no": null,
        "email_address": null,
        "address": null,
        "expected_closing_timeline": "six_twelve",
        "lead_status": "new_lead",
      },
      "followup": [
        {
          "title":
              "Title 3. Title 3. Title 3. Title 3. Title 3. Title 3. Title 3. Title 3. Title 3. Title 3. Title 3. ",
          "description":
              "Description goes here. Description goes here. Description goes here. Description goes here. Description goes here. Description goes here. Description goes here. Description goes here. Description goes here. Description goes here. Description goes here. Description goes here. Description goes here. ",
          "time": "Nov 22 10:00 AM",
        },
        {
          "title":
              "Title 3. Title 3. Title 3. Title 3. Title 3. Title 3. Title 3. Title 3. Title 3. Title 3. Title 3. ",
          "description":
              "Description goes here. Description goes here. Description goes here. Description goes here. Description goes here. Description goes here. Description goes here. Description goes here. Description goes here. Description goes here. Description goes here. Description goes here. Description goes here. ",
          "time": "Aug 14 10:00 AM",
        },
        {
          "title":
              "Title 3. Title 3. Title 3. Title 3. Title 3. Title 3. Title 3. Title 3. Title 3. Title 3. Title 3. ",
          "description":
              "Description goes here. Description goes here. Description goes here. Description goes here. Description goes here. Description goes here. Description goes here. Description goes here. Description goes here. Description goes here. Description goes here. Description goes here. Description goes here. ",
          "time": "Jul 25 10:00 AM",
        },
      ],
    },
    "status": 200,
  };
  LeadModel? lead;
  getLeadDetails() {
    try {
      lead = LeadModel.fromJson(dig(response, ['data']) ?? {});
      if (lead != null) {
        // leadUrl.value = lead!.url ?? '';
        // Get.to(() => LeadDetailsScreen(url: leadUrl.value));
      }
    } catch (e) {}
  }

  @override
  void onInit() {
    super.onInit();
  }
}
