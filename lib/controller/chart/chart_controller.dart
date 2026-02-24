import 'package:get/get.dart';

class ChartController extends GetxController {
  RxString filter = "Month".obs;
  RxList<Map<String, dynamic>> chartData = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    updateFilter("Month");
  }

  void updateFilter(String newFilter) {
    filter.value = newFilter;
    if (newFilter == "Month") {
      chartData.value = [
        {
          "label": "Jan",
          "percentage": 20.0,
          "tooltip": {"title": "January", "percentage": "20%"},
        },
        {
          "label": "Feb",
          "percentage": 45.0,
          "tooltip": {"title": "February", "percentage": "45%"},
        },
        {
          "label": "Mar",
          "percentage": 30.0,
          "tooltip": {"title": "March", "percentage": "30%"},
        },
        {
          "label": "Apr",
          "percentage": 80.0,
          "tooltip": {"title": "April", "percentage": "80%"},
        },
        {
          "label": "May",
          "percentage": 60.0,
          "tooltip": {"title": "May", "percentage": "60%"},
        },
        {
          "label": "Jun",
          "percentage": 90.0,
          "tooltip": {"title": "June", "percentage": "90%"},
        },
      ];
    } else {
      chartData.value = [
        {
          "label": "Mon",
          "percentage": 15.0,
          "tooltip": {"title": "Monday", "percentage": "15%"},
        },
        {
          "label": "Tue",
          "percentage": 35.0,
          "tooltip": {"title": "Tuesday", "percentage": "35%"},
        },
        {
          "label": "Wed",
          "percentage": 50.0,
          "tooltip": {"title": "Wednesday", "percentage": "50%"},
        },
        {
          "label": "Thu",
          "percentage": 25.0,
          "tooltip": {"title": "Thursday", "percentage": "25%"},
        },
        {
          "label": "Fri",
          "percentage": 65.0,
          "tooltip": {"title": "Friday", "percentage": "65%"},
        },
        {
          "label": "Sat",
          "percentage": 85.0,
          "tooltip": {"title": "Saturday", "percentage": "85%"},
        },
        {
          "label": "Sun",
          "percentage": 40.0,
          "tooltip": {"title": "Sunday", "percentage": "40%"},
        },
      ];
    }
  }
}
