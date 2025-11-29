import 'package:flutter/material.dart';

class AddTemplatePage extends StatefulWidget {
  const AddTemplatePage({super.key});

  @override
  State<AddTemplatePage> createState() => _AddTemplatePageState();
}

class _AddTemplatePageState extends State<AddTemplatePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        title: const Text('Add Template', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsetsGeometry.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 10,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  label: Text("Title"),
                  hintText: "Enter a concise title for your report",
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Title is required";
                  }

                  return null;
                },
              ),
              Expanded(
                child: TextFormField(
                  controller: _bodyController,
                  expands: true,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  minLines: null,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    labelText: 'Body',
                    hintText: "Write the full report details here",
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Body is required";
                    }

                    return null;
                  },
                ),
              ),
              TextButton(
                onPressed: () {
                  if (!_formKey.currentState!.validate()) return;

                  // All validations passed
                },
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
      ),
    );
  }
}
