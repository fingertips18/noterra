import 'package:flutter/material.dart';

class EditTemplatePage extends StatefulWidget {
  const EditTemplatePage({super.key});

  @override
  State<EditTemplatePage> createState() => _EditTemplatePageState();
}

class _EditTemplatePageState extends State<EditTemplatePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        title: const Text('Edit Template', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsetsGeometry.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10,
          children: [
            const TextField(
              decoration: InputDecoration(
                label: Text("Title"),
                hintText: "Enter a concise title for your report",
                floatingLabelBehavior: FloatingLabelBehavior.always,
                border: OutlineInputBorder(),
              ),
            ),
            const Expanded(
              child: TextField(
                expands: true,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                minLines: null,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  labelText: 'Body',
                  hintText: "Write the full report details here",
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            TextButton(
              onPressed: () {},
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.blueAccent),
                foregroundColor: WidgetStateProperty.all(Colors.white),
                fixedSize: WidgetStateProperty.all(const Size.fromHeight(50)),
              ),
              child: const Text("Save", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
