import 'package:flutter/material.dart';
import 'package:noterra/controller/template.dart';
import 'package:noterra/model/template.dart';

class AddTemplatePage extends StatefulWidget {
  final TemplateController controller;

  const AddTemplatePage({super.key, required this.controller});

  @override
  State<AddTemplatePage> createState() => _AddTemplatePageState();
}

class _AddTemplatePageState extends State<AddTemplatePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  bool _isSubmitting = false;

  String? onValidation(String keyword, String? value) {
    if (value == null || value.trim().isEmpty) {
      return "$keyword is required";
    }

    return null;
  }

  void onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    Template template = Template(title: _titleController.text, body: _bodyController.text);

    await widget.controller.createTemplate(template: template);

    _titleController.clear();
    _bodyController.clear();

    setState(() => _isSubmitting = false);
  }

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
                enabled: !_isSubmitting,
                decoration: const InputDecoration(
                  label: Text("Title"),
                  hintText: "Enter a concise title for your report",
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  border: OutlineInputBorder(),
                ),
                validator: (value) => onValidation("Title", value),
              ),
              Expanded(
                child: TextFormField(
                  controller: _bodyController,
                  enabled: !_isSubmitting,
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
                  validator: (value) => onValidation("Body", value),
                ),
              ),
              TextButton(
                onPressed: _isSubmitting ? null : onSubmit,
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.disabled)) {
                      return Colors.grey;
                    }

                    return Colors.blueAccent;
                  }),
                  foregroundColor: WidgetStateProperty.all(Colors.white),
                  fixedSize: WidgetStateProperty.all(const Size.fromHeight(50)),
                  overlayColor: _isSubmitting ? WidgetStateProperty.all(Colors.transparent) : null,
                ),
                child: _isSubmitting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Save", style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
