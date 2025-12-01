import 'package:flutter/material.dart';
import 'package:noterra/controller/template.dart';
import 'package:noterra/model/template.dart';
import 'package:noterra/screens/template/edit_template.dart';
import 'package:noterra/utils/format.dart';

class ViewTemplate extends StatelessWidget {
  final TemplateController controller;
  final Template template;

  const ViewTemplate({super.key, required this.controller, required this.template});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        title: const Text('Template', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditTemplatePage(controller: controller, template: template),
                ),
              );
            },
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsetsGeometry.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 5,
              children: [
                Flexible(
                  child: Text(
                    "Created: ${formatRelativeDate(template.createdAt)}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 16, child: VerticalDivider(color: Colors.black54, thickness: 1, width: 10)),
                Flexible(
                  child: Text(
                    "Modified: ${formatRelativeDate(template.updatedAt)}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(template.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(template.body, style: const TextStyle(fontSize: 16, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
