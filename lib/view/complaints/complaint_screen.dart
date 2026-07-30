import 'package:ts_fieldforce/component/custom_appbar.dart';
import 'package:ts_fieldforce/main.dart';
import 'package:flutter/material.dart';

class ComplaintScreen extends StatelessWidget {
  const ComplaintScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorManager.bgDark,
      appBar: CustomAppBar(title: 'Complaints'),
    );
  }
}
