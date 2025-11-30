import 'package:flutter/material.dart';
import 'package:noterra/controller/template.dart';
import 'package:noterra/screens/template/add_template.dart';
import 'package:noterra/screens/template/edit_template.dart';
import 'package:noterra/screens/template/view_template.dart';
import 'package:noterra/widgets/confirmation.dart';

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
    _templateController.listTemplates();
  }

  @override
  Widget build(BuildContext context) {
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
                  "Manage your report templates on this device. Tap a template to view, edit, or delete it, or use the + button to create a new template.",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ],
            ),
            Expanded(
              child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                valueListenable: _templateController.templatesNotifier,
                builder: (context, templates, _) {
                  if (templates.isEmpty) return _emptyTemplates();

                  return ListView.builder(
                    itemCount: templates.length,
                    itemBuilder: (context, index) {
                      final template = templates[index];

                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        clipBehavior: Clip.antiAlias,
                        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                        child: ListTile(
                          contentPadding: const EdgeInsets.only(left: 10, right: 4),
                          leading: const Icon(Icons.insert_drive_file),
                          title: Text(template["title"]),
                          subtitle: Text(template["body"], style: const TextStyle(color: Colors.black54)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const EditTemplatePage()));
                                },
                                icon: const Icon(Icons.edit),
                              ),
                              IconButton(
                                onPressed: () async {
                                  await confirmation(
                                    context: context,
                                    title: "Are you sure you want to delete this template?",
                                    content: "This action cannot be undone.",
                                    action: () async {
                                      await _templateController.deleteTemplate(templateKey: template["key"]);
                                    },
                                  );
                                },
                                icon: const Icon(Icons.delete_forever),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const ViewTemplate()));
                          },
                        ),
                      );
                    },
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

  Widget _emptyTemplates() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: [
          Icon(Icons.sticky_note_2_outlined, size: 48, color: Colors.grey),
          Text("No templates yet", style: TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }
}
