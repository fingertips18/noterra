import 'package:flutter/material.dart';
import 'package:noterra/controller/template.dart';
import 'package:noterra/model/template.dart';
import 'package:noterra/utils/validation.dart';

class AddTemplateScreen extends StatefulWidget {
  final TemplateController controller;

  const AddTemplateScreen({super.key, required this.controller});

  @override
  State<AddTemplateScreen> createState() => _AddTemplateScreenState();
}

class _AddTemplateScreenState extends State<AddTemplateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();

    super.dispose();
  }

  void onSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    Template template = Template(title: _titleController.text, body: _bodyController.text, createdAt: DateTime.now(), updatedAt: DateTime.now());

    await widget.controller.createTemplate(template: template);

    _titleController.clear();
    _bodyController.clear();

    setState(() => _isSaving = false);
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
                enabled: !_isSaving,
                decoration: const InputDecoration(
                  label: Text("Title"),
                  hintText: "Enter a concise title for your report",
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  border: OutlineInputBorder(),
                ),
                validator: (value) => onRequiredValidation("Title", value),
              ),
              Expanded(
                child: TextFormField(
                  controller: _bodyController,
                  enabled: !_isSaving,
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
                  validator: (value) => onRequiredValidation("Body", value),
                ),
              ),
              TextButton(
                onPressed: _isSaving ? null : onSave,
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.disabled)) {
                      return Colors.grey;
                    }

                    return Colors.blueAccent;
                  }),
                  foregroundColor: WidgetStateProperty.all(Colors.white),
                  fixedSize: WidgetStateProperty.all(const Size.fromHeight(50)),
                  overlayColor: _isSaving ? WidgetStateProperty.all(Colors.transparent) : null,
                ),
                child: _isSaving
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
