import 'package:flutter/material.dart';
import 'package:noterra/pages/add_template.dart';

class TemplatePage extends StatefulWidget {
  const TemplatePage({super.key});

  @override
  State<TemplatePage> createState() => _TemplatePageState();
}

class _TemplatePageState extends State<TemplatePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        title: const Text('Template Page', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AddTemplatePage()));
            },
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      body: const Padding(
        padding: EdgeInsetsGeometry.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 10, children: [

          ],
        ),
      ),
    );
  }
}
