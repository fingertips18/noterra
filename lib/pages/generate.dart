import 'package:flutter/material.dart';

class GeneratePage extends StatefulWidget {
  const GeneratePage({super.key});

  @override
  State<GeneratePage> createState() => _GeneratePageState();
}

class _GeneratePageState extends State<GeneratePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        title: const Text('Generate Daily Report', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Center(child: Text('Generate Report Page Content Here')),
    );
  }
}
