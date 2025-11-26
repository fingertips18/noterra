import 'package:flutter/material.dart';
import 'package:noterra/pages/template/add_template.dart';
import 'package:noterra/pages/template/edit_template.dart';
import 'package:noterra/pages/template/view_template.dart';

class TemplatesPage extends StatefulWidget {
  const TemplatesPage({super.key});

  @override
  State<TemplatesPage> createState() => _TemplatesPageState();
}

class _TemplatesPageState extends State<TemplatesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        title: const Text('Templates Page', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AddTemplatePage()));
            },
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsetsGeometry.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 2,
              children: [
                Text("Saved Templates", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text(
                  "Browse and manage all your report templates stored on this device. Tap any template to view, edit, or share it.",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 5, // temporary number of items
                itemBuilder: (context, index) {
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    clipBehavior: Clip.antiAlias,
                    margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                    child: ListTile(
                      leading: const Icon(Icons.insert_drive_file),
                      title: Text("Template ${index + 1}"),
                      subtitle: const Text("Last edited: 2025-11-26", style: TextStyle(color: Colors.black54)),
                      trailing: IconButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const EditTemplatePage()));
                        },
                        icon: const Icon(Icons.edit),
                      ),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const ViewTemplate()));
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
