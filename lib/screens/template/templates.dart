import 'package:flutter/material.dart';
import 'package:noterra/controller/template.dart';
import 'package:noterra/screens/template/add_template.dart';
import 'package:noterra/screens/template/edit_template.dart';
import 'package:noterra/screens/template/view_template.dart';

class TemplatesPage extends StatefulWidget {
  const TemplatesPage({super.key});

  @override
  State<TemplatesPage> createState() => _TemplatesPageState();
}

class _TemplatesPageState extends State<TemplatesPage> {
  late TemplateController _templateController;

  @override
  void initState() {
    super.initState();
    _templateController = TemplateController(context: context);
  }

  @override
  Widget build(BuildContext context) {
    final templates = _templateController.listTemplates();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        title: const Text('Templates Page', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.clear_all))],
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
                itemCount: templates.length,
                itemBuilder: (context, index) {
                  final template = templates[index];

                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    clipBehavior: Clip.antiAlias,
                    margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                    child: ListTile(
                      leading: const Icon(Icons.insert_drive_file),
                      title: Text(template["title"]),
                      subtitle: Text(template["body"], style: const TextStyle(color: Colors.black54)),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddTemplatePage(controller: _templateController)));
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
