import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:noterra/constants/string.dart';
import 'package:noterra/model/template.dart';

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
      // TODO: add toast in a separate PR
    }
  }

  Future<void> editTemplate({required Template template, required int templateKey}) async {
    try {
      await hiveBox.put(templateKey, template.toMap());
      _afterAction("edited");
    } catch (e) {
      // TODO: add toast in a separate PR
    }
  }

  Future<void> deleteTemplate({required int templateKey}) async {
    try {
      await hiveBox.delete(templateKey);
      _afterAction("deleted");
    } catch (e) {
      // TODO: add toast in a separate PR
    }
  }

  Future<void> clearTemplates() async {
    try {
      await hiveBox.clear();
      _afterAction("cleared");
    } catch (e) {
      // TODO: add toast in a separate PR
    }
  }

  void _afterAction(String keyword) {
    // TODO: add toast in a separate PR
    fetchDataFunction(); // Refresh UI
    Navigator.of(context).pop(); // Close modals
  }
}
