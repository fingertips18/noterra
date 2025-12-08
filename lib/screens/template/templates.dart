import 'package:flutter/material.dart';
import 'package:noterra/controller/template.dart';
import 'package:noterra/model/template.dart';
import 'package:noterra/screens/template/add_template.dart';
import 'package:noterra/screens/template/view_template.dart';
import 'package:noterra/utils/format.dart';
import 'package:noterra/widgets/confirmation.dart';

class TemplatesScreen extends StatefulWidget {
  const TemplatesScreen({super.key});

  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
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
        title: const Text('Templates', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            onPressed: () async {
              await confirmation(
                context: context,
                title: "Delete all templates?",
                content: "This will permanently remove all saved templates. You won't be able to recover them.",
                action: () async {
                  await _templateController.clearTemplates();
                },
              );
            },
            icon: const Icon(Icons.clear_all),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsetsGeometry.all(10),
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
                      final template = Template.fromMap(templates[index]);

                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        clipBehavior: Clip.antiAlias,
                        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                        child: ListTile(
                          contentPadding: const EdgeInsets.only(left: 10, right: 4),
                          leading: const Icon(Icons.insert_drive_file),
                          title: Text(
                            template.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                template.body,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.black54),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Updated: ${formatRelativeDate(template.updatedAt)}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            onPressed: () async {
                              await confirmation(
                                context: context,
                                title: "Are you sure you want to delete this template?",
                                content: "This action cannot be undone.",
                                action: () async {
                                  await _templateController.deleteTemplate(templateKey: template.key);
                                },
                              );
                            },
                            icon: const Icon(Icons.delete_forever),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewTemplateScreen(controller: _templateController, template: template),
                              ),
                            );
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
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddTemplateScreen(controller: _templateController)));
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
