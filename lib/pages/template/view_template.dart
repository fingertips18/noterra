import 'package:flutter/material.dart';

class ViewTemplate extends StatelessWidget {
  const ViewTemplate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        title: const Text('Template', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: const Center(child: Text('Template Content Here')),
    );
  }
}
