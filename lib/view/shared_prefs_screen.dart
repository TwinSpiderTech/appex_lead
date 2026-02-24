import 'package:appex_lead/component/custom_button.dart';
import 'package:appex_lead/component/custom_input_field.dart';
import 'package:appex_lead/utils/constants.dart';
import 'package:appex_lead/utils/custom_toast_messages.dart';
import 'package:appex_lead/utils/helpers.dart';
import 'package:appex_lead/view/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:appex_lead/component/custom_appbar.dart';
import 'package:appex_lead/main.dart';
import 'package:get/get.dart';

import 'package:shared_preferences/shared_preferences.dart';

class SharePrefScreen extends StatefulWidget {
  const SharePrefScreen({super.key});

  @override
  State<SharePrefScreen> createState() => _SharePrefScreenState();
}

class _SharePrefScreenState extends State<SharePrefScreen> {
  final TextEditingController _valueController = TextEditingController();
  Future<Map<String, dynamic>> _getAllSharedPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Set<String> keys = prefs.getKeys();
    final Map<String, dynamic> allPrefs = {};
    // deviceId = await helper.getDeviceInfo();
    // print("Keys => ${keys}");
    for (String key in keys) {
      allPrefs[key] = prefs.get(key);
    }

    return allPrefs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorManager.bgDark,
      appBar: CustomAppBar(canNavigate: true, title: "SharePreferences"),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _getAllSharedPreferences(),
          builder:
              (
                BuildContext context,
                AsyncSnapshot<Map<String, dynamic>> snapshot,
              ) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'No data found.',
                      style: TextStyle(color: colorManager.textColor),
                    ),
                  );
                } else {
                  final Map<String, dynamic> prefsData = snapshot.data!;
                  return Column(
                    children: [
                      Row(
                        spacing: 12,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: CustomInputField(
                              controller: _valueController,
                              hint: 'Enter base URL',
                            ),
                          ),
                          SizedBox(
                            width: 100,
                            child: CustomButton(
                              label: 'Update',
                              onTap: () async {
                                await setDataToPrefs(
                                  key: baseURLKey,
                                  value: _valueController.text,
                                  type: 'string',
                                );
                                setState(() {
                                  _valueController.clear();
                                  showToast(
                                    message: "Base URL updated successfully",
                                  );
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: prefsData.length,
                          itemBuilder: (BuildContext context, int index) {
                            String key = prefsData.keys.elementAt(index);
                            dynamic value = prefsData[key];
                            return _reuseableRow(key, value);
                            // trailing: ,
                          },
                        ),
                      ),
                      CustomButton(
                        label: "Restart App",
                        onTap: () async {
                          Get.offAll(() => const SplashScreen());
                        },
                      ),
                    ],
                  );
                }
              },
        ),
      ),
    );
  }
}

Widget _reuseableRow(key, value) {
  return Container(
    padding: EdgeInsets.only(bottom: 4, top: 4),
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: colorManager.borderColor)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$key:", style: TextStyle(color: colorManager.textColor)),
        Container(
          constraints: BoxConstraints(maxWidth: 200),
          child: Text(
            "$value",
            style: TextStyle(color: colorManager.textColor),
            textAlign: TextAlign.end,
            overflow: TextOverflow.visible,
          ),
        ),
      ],
    ),
  );
}
