import 'package:flutter/material.dart'
    show
        AppBar,
        BuildContext,
        Colors,
        Column,
        CrossAxisAlignment,
        Divider,
        EdgeInsetsGeometry,
        FontWeight,
        Padding,
        Scaffold,
        SizedBox,
        StatelessWidget,
        Text,
        TextOverflow,
        TextStyle,
        Widget;
import '/model/email.dart' show Email;

class ViewEmailScreen extends StatelessWidget {
  final Email email;

  const ViewEmailScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        title: const Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsetsGeometry.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 5,
          children: [
            Text(email.subject, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(
              "To: ${email.to}",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
            const Divider(color: Colors.black54, thickness: 0.1),
            const SizedBox(height: 5),
            Text(email.snippet, style: const TextStyle(fontSize: 16, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
