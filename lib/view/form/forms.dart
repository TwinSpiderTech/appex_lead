import 'package:appex_lead/component/custom_appbar.dart';
import 'package:appex_lead/main.dart';
import 'package:appex_lead/utils/helpers.dart';
import 'package:appex_lead/view/form/form_details.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AvailableForms extends StatelessWidget {
  const AvailableForms({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Available Forms"),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            _formCard(
              "Leads Forms",
              "/api/v1/business/leads/get_form_template",
            ),
            _formCard(
              "Interaction Forms",
              "/api/v1/business/interaction/get_form_template",
            ),
          ],
        ),
      ),
    );
  }

  Widget _formCard(String title, String url, {String? description}) {
    return InkWell(
      onTap: () {
        Get.to(() => FormDetails(url: url, title: title));
      },
      child: Card(
        color: colorManager.primaryColor,
        child: ListTile(
          leading: Icon(
            Icons.description_outlined,
            color: colorManager.whiteColor,
          ),
          title: Text(
            title,
            style: primaryTextStyle.copyWith(
              fontSize: 16,
              color: colorManager.whiteColor,
            ),
          ),

          subtitle: (description != null)
              ? Text(
                  description,
                  style: primaryTextStyle.copyWith(
                    fontSize: 12,
                    color: colorManager.whiteColor,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                )
              : null,
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: colorManager.whiteColor,
          ),
        ),
      ),
    );
  }
}
