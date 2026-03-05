import 'package:appex_lead/component/custom_appbar.dart';
import 'package:appex_lead/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controller/form/generic_form_controller.dart';
import '../../main.dart';
import 'form_details.dart';

class DraftsScreen extends StatefulWidget {
  const DraftsScreen({super.key});

  @override
  State<DraftsScreen> createState() => _DraftsScreenState();
}

class _DraftsScreenState extends State<DraftsScreen> {
  final GenericFormController controller = Get.put(GenericFormController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorManager.bgDark,
      appBar: CustomAppBar(title: 'Saved Drafts'),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: controller.getSavedDrafts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error loading drafts",
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          final drafts = snapshot.data ?? [];

          if (drafts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.drafts_outlined,
                    size: 64,
                    color: colorManager.iconColor.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No drafts found",
                    style: TextStyle(
                      color: colorManager.textColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: drafts.length,
            itemBuilder: (context, index) {
              final draft = drafts[index];
              final DateTime updatedAt = DateTime.parse(
                draft['updated_at'] ?? DateTime.now().toIso8601String(),
              );
              final String formattedDate = previewableDateTimeFormat(updatedAt);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Icon(
                    Icons.description_outlined,
                    color: colorManager.primaryColor,
                  ),
                  title: Text(
                    draft['title'] ?? 'Untitled Draft',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorManager.textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    "Last updated: $formattedDate",
                    style: TextStyle(
                      color: colorManager.textColor.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                        onPressed: () =>
                            _confirmDelete(context, controller, draft),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: colorManager.iconColor,
                        size: 16,
                      ),
                    ],
                  ),
                  onTap: () async {
                    final String url = draft['template_url'] ?? "";
                    if (url.isNotEmpty) {
                      await Get.to(
                        () => FormDetails(
                          url: url,
                          draftData: draft,
                          title: draft['title'] ?? 'Untitled Draft',
                        ),
                      );
                      setState(() {}); // Refresh list when coming back
                    } else {
                      Get.snackbar(
                        "Error",
                        "Template URL not found for this draft.",
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    GenericFormController controller,
    Map<String, dynamic> draft,
  ) {
    Get.dialog(
      AlertDialog(
        backgroundColor: colorManager.bgDark,
        title: Text(
          "Delete Draft?",
          style: TextStyle(color: colorManager.textColor),
        ),
        content: Text(
          "Are you sure you want to delete '${draft['title'] ?? 'this draft'}'?",
          style: TextStyle(color: colorManager.textColor.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              "Cancel",
              style: TextStyle(color: colorManager.textColor),
            ),
          ),
          TextButton(
            onPressed: () async {
              controller.currentDraftId.value = draft['id'] ?? "";
              await controller.deleteProgress();
              Get.back(); // Pop the dialog
              setState(() {}); // Refresh the list
            },
            child: Text("Delete", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
