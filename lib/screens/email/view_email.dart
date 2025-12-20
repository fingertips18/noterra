import 'package:flutter/material.dart'
    show
        AppBar,
        BuildContext,
        Center,
        CircularProgressIndicator,
        Colors,
        Column,
        CrossAxisAlignment,
        Divider,
        EdgeInsets,
        Expanded,
        FontStyle,
        FontWeight,
        Padding,
        Scaffold,
        SingleChildScrollView,
        SizedBox,
        State,
        StatefulWidget,
        Text,
        TextOverflow,
        TextSpan,
        TextStyle,
        Widget;
import '/controller/email.dart' show EmailController;
import '/model/email.dart' show Email;

class ViewEmailScreen extends StatefulWidget {
  final EmailController emailController;
  final Email email;

  const ViewEmailScreen({super.key, required this.emailController, required this.email});

  @override
  State<ViewEmailScreen> createState() => _ViewEmailScreenState();
}

class _ViewEmailScreenState extends State<ViewEmailScreen> {
  bool _isLoading = true;
  String _emailBody = "";
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEmailBody();
  }

  Future<void> _loadEmailBody() async {
    try {
      final body = await widget.emailController.fetchEmailBody(widget.email.id);
      setState(() {
        _emailBody = body;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _emailBody = widget.email.snippet; // Fallback to snippet
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        title: const Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 5,
          children: [
            Text(widget.email.subject, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: "To: ",
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: widget.email.to,
                    style: const TextStyle(color: Colors.black87, fontSize: 14),
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Divider(color: Colors.black54, thickness: 0.1),
            const SizedBox(height: 5),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 8.0,
                        children: [
                          if (_error != null)
                            Text(
                              "Could not load full message. Showing snippet instead.",
                              style: TextStyle(color: Colors.orange[700], fontSize: 12, fontStyle: FontStyle.italic),
                            ),
                          Text(_emailBody, style: const TextStyle(fontSize: 16, color: Colors.black54)),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
