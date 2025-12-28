import 'package:flutter/material.dart' show BuildContext, Navigator, ValueNotifier, VoidCallback;
import 'package:hive_flutter/hive_flutter.dart' show Hive;
import '/constants/status.dart' show Status;
import '/constants/string.dart' show StringConstants;
import '/model/template.dart' show Template;
import '/widgets/toast.dart' show toast;

class TemplateController {
  final VoidCallback? action;

  TemplateController({this.action});

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

  Future<void> createTemplate(BuildContext context, {required Template template}) async {
    try {
      await templateBox.add(template.toMap());
      if (!context.mounted) return;
      _afterAction(context, keyword: "saved");
    } catch (e) {
      toast(message: "Failed to create template", status: Status.error);
    }
  }

  Future<void> editTemplate(BuildContext context, {required Template template}) async {
    try {
      await templateBox.put(template.key, template.toMap());
      if (!context.mounted) return;
      _afterAction(context, keyword: "edited");
    } catch (e) {
      toast(message: "Failed to edit template", status: Status.error);
    }
  }

  Future<void> deleteTemplate(BuildContext context, {required dynamic templateKey}) async {
    try {
      await templateBox.delete(templateKey);
      if (!context.mounted) return;
      _afterAction(context, keyword: "deleted");
    } catch (e) {
      toast(message: "Failed to delete template", status: Status.error);
    }
  }

  Future<void> clearTemplates(BuildContext context) async {
    try {
      await templateBox.clear();
      if (!context.mounted) return;
      _afterAction(context, keyword: "cleared");
    } catch (e) {
      toast(message: "Failed to clear templates", status: Status.error);
    }
  }

  void _afterAction(BuildContext context, {required String keyword}) {
    toast(message: 'Template $keyword successfully', status: Status.success);
    listTemplates();
    action?.call(); // Refresh UI
    Navigator.of(context).pop(); // Close modals
  }

  void dispose() {
    templatesNotifier.dispose();
  }
}
