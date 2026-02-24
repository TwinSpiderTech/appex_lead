import 'package:appex_lead/component/custom_appbar.dart';
import 'package:flutter/material.dart';

class AllForms extends StatelessWidget {
  const AllForms({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Available Forms'),
      body: Column(children: []),
    );
  }
}
