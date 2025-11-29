import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:noterra/constants/status.dart';
import 'package:noterra/constants/string.dart';
import 'package:noterra/model/template.dart';
import 'package:noterra/widgets/toast.dart';

class TemplateController {
  final BuildContext context;
  final Function fetchDataFunction;

  TemplateController({required this.context, required this.fetchDataFunction});

  final hiveBox = Hive.box(StringConstants.templateBox);

  // Fetch all items from Hive
  List<Map<String, dynamic>> fetchData() {
    return hiveBox.keys
        .map((key) {
          final item = hiveBox.get(key);
          return {"key": key, "title": item["title"], "body": item["body"]};
        })
        .toList()
        .reversed
        .toList();
  }

  Future<void> createTemplate({required Template template}) async {
    try {
      await hiveBox.add(template.toMap());
      _afterAction("saved");
    } catch (e) {
      toast(message: "Failed to create template", status: Status.error);
    }
  }

  Future<void> editTemplate({required Template template, required int templateKey}) async {
    try {
      await hiveBox.put(templateKey, template.toMap());
      _afterAction("edited");
    } catch (e) {
      toast(message: "Failed to edit template", status: Status.error);
    }
  }

  Future<void> deleteTemplate({required int templateKey}) async {
    try {
      await hiveBox.delete(templateKey);
      _afterAction("deleted");
    } catch (e) {
      toast(message: "Failed to delete template", status: Status.error);
    }
  }

  Future<void> clearTemplates() async {
    try {
      await hiveBox.clear();
      _afterAction("cleared");
    } catch (e) {
      toast(message: "Failed to clear templates", status: Status.error);
    }
  }

  void _afterAction(String keyword) {
    toast(message: 'Template $keyword successfully', status: Status.success);
    fetchDataFunction(); // Refresh UI
    Navigator.of(context).pop(); // Close modals
  }
}
