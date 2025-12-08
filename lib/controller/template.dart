import 'package:flutter/material.dart' show BuildContext, Navigator, ValueNotifier, VoidCallback;
import 'package:hive_flutter/hive_flutter.dart' show Hive;
import '/constants/status.dart' show Status;
import '/constants/string.dart' show StringConstants;
import '/model/template.dart' show Template;
import '/widgets/toast.dart' show toast;

class TemplateController {
  final BuildContext context;
  final VoidCallback? action;

  TemplateController({required this.context, this.action});

  final templateBox = Hive.box(StringConstants.templateBox);

  // Reactive list of templates
  final ValueNotifier<List<Map<String, dynamic>>> templatesNotifier = ValueNotifier([]);

  // Fetch all items from Hive
  void listTemplates() {
    final templates = templateBox.keys
        .map((key) {
          final item = templateBox.get(key);
          return {"key": key, "title": item["title"], "body": item["body"], "created_at": item["created_at"], "updated_at": item["updated_at"]};
        })
        .toList()
        .reversed
        .toList();
    templatesNotifier.value = templates;
  }

  Future<void> createTemplate({required Template template}) async {
    try {
      await templateBox.add(template.toMap());
      _afterAction("saved");
    } catch (e) {
      toast(message: "Failed to create template", status: Status.error);
    }
  }

  Future<void> editTemplate({required Template template}) async {
    try {
      await templateBox.put(template.key, template.toMap());
      _afterAction("edited");
    } catch (e) {
      toast(message: "Failed to edit template", status: Status.error);
    }
  }

  Future<void> deleteTemplate({required dynamic templateKey}) async {
    try {
      await templateBox.delete(templateKey);
      _afterAction("deleted");
    } catch (e) {
      toast(message: "Failed to delete template", status: Status.error);
    }
  }

  Future<void> clearTemplates() async {
    try {
      await templateBox.clear();
      _afterAction("cleared");
    } catch (e) {
      toast(message: "Failed to clear templates", status: Status.error);
    }
  }

  void _afterAction(String keyword) {
    toast(message: 'Template $keyword successfully', status: Status.success);
    listTemplates();
    action?.call(); // Refresh UI
    Navigator.of(context).pop(); // Close modals
  }
}
