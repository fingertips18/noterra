import 'package:flutter/material.dart';
import 'package:noterra/controller/template.dart';
import 'package:noterra/model/template.dart';
import 'package:noterra/screens/template/edit_template.dart';

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
      body: const Center(child: Text('Template Content Here')),
    );
  }
}
