import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:appex_lead/component/custom_appbar.dart';
import 'package:appex_lead/main.dart';
import 'package:appex_lead/view/shared_prefs_screen.dart';

class AppSettings extends StatelessWidget {
  const AppSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorManager.bgDark,
      appBar: CustomAppBar(canNavigate: true, title: 'Settings'),
      body: SingleChildScrollView(child: Column(children: [
           
          ],
        )),
    );
  }
}
