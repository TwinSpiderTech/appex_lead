import 'package:appex_lead/component/custom_appbar.dart';
import 'package:appex_lead/component/custom_searchable_dropdown2.dart';
import 'package:flutter/material.dart';

class InteractionForm extends StatelessWidget {
  final String? leadId;
  const InteractionForm({super.key, this.leadId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Add Interaction"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomSearchableDropdown2(
              selectedValue: leadId,
              items: {},
              onChange: (value) {},
              label: "Lead",
            ),
          ],
        ),
      ),
    );
  }
}
