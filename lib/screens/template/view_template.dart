import 'package:flutter/material.dart';
import 'package:noterra/screens/template/edit_template.dart';

class ViewTemplate extends StatelessWidget {
  const ViewTemplate({super.key});

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
              Navigator.push(context, MaterialPageRoute(builder: (context) => const EditTemplatePage()));
            },
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: const Center(child: Text('Template Content Here')),
    );
  }
}
