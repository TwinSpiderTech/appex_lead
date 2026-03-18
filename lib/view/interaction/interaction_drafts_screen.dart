import 'package:appex_lead/component/custom_appbar.dart';
import 'package:appex_lead/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/interaction/interaction_form_controller.dart';
import '../../main.dart';
import 'interaction_form.dart';

class InteractionDraftsScreen extends StatefulWidget {
  const InteractionDraftsScreen({super.key});

  @override
  State<InteractionDraftsScreen> createState() =>
      _InteractionDraftsScreenState();
}

class _InteractionDraftsScreenState extends State<InteractionDraftsScreen> {
  final InteractionFormController controller = Get.put(
    InteractionFormController(),
  );

  // Cached resolved display names per draft id
  final Map<String, String> _resolvedNames = {};
  List<Map<String, dynamic>> _drafts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDrafts();
  }

  Future<void> _loadDrafts() async {
    setState(() => _isLoading = true);
    final drafts = await controller.getSavedDrafts();

    // Pre-resolve lead names for all drafts in parallel
    final futures = drafts.map((draft) async {
      final id = draft['id']?.toString() ?? '';
      if (id.isEmpty) return;
      // Try to get lead name from template options first
      final leadName = await controller.getLeadNameForDraft(draft);
      final displayName = leadName ?? _getDraftDisplayName(draft);
      _resolvedNames[id] = displayName;
    });
    await Future.wait(futures);

    if (mounted) {
      setState(() {
        _drafts = drafts;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorManager.bgDark,
      appBar: CustomAppBar(title: 'Interaction Drafts'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _drafts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: colorManager.iconColor.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No interaction drafts found",
                    style: TextStyle(
                      color: colorManager.textColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _drafts.length,
              itemBuilder: (context, index) {
                final draft = _drafts[index];
                final id = draft['id']?.toString() ?? '';
                final DateTime updatedAt = DateTime.parse(
                  draft['updated_at'] ?? DateTime.now().toIso8601String(),
                );
                final String formattedDate = previewableDateTimeFormat(
                  updatedAt,
                );
                final String displayName =
                    _resolvedNames[id] ?? _getDraftDisplayName(draft);
                final String formTitle = draft['title'] ?? 'Interaction';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Icon(
                      Icons.history_outlined,
                      color: colorManager.primaryColor,
                    ),
                    title: Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colorManager.textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "$formTitle · $formattedDate",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colorManager.textColor.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                            size: 20,
                          ),
                          onPressed: () => _confirmDelete(
                            context,
                            controller,
                            draft,
                            displayName,
                          ),
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
                          () => InteractionForm(
                            url: url,
                            draftData: draft,
                            title: draft['title'] ?? 'Untitled Interaction',
                          ),
                        );
                        _loadDrafts(); // Refresh list when coming back
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
            ),
    );
  }

  /// Extracts the best display name from a draft's saved values.
  /// Used as a fallback when the business_lead_id cannot be resolved.
  String _getDraftDisplayName(Map<String, dynamic> draft) {
    final values = draft['values'] as Map<String, dynamic>? ?? {};

    // Priority order: business_name → person_name → any *name* field
    for (final key in [
      'business_name',
      'person_name',
      'name',
      'customer_name',
      'client_name',
    ]) {
      final val = values[key]?.toString();
      if (val != null && val.isNotEmpty) return val;
    }

    // Fallback: search any key containing 'name'
    for (final entry in values.entries) {
      if (entry.key.toLowerCase().contains('name') &&
          entry.value != null &&
          entry.value.toString().isNotEmpty) {
        return entry.value.toString();
      }
    }

    return draft['title'] ?? 'Untitled Interaction';
  }

  void _confirmDelete(
    BuildContext context,
    InteractionFormController controller,
    Map<String, dynamic> draft,
    String displayName,
  ) {
    Get.dialog(
      AlertDialog(
        backgroundColor: colorManager.bgDark,
        title: Text(
          "Delete Draft?",
          style: TextStyle(color: colorManager.textColor),
        ),
        content: Text(
          "Are you sure you want to delete '$displayName'?",
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
              _loadDrafts(); // Refresh the list
            },
            child: Text(
              "Delete",
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
