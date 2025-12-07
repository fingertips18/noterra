import 'package:flutter/material.dart'
    show
        AppBar,
        BorderRadius,
        BuildContext,
        Card,
        Center,
        CircularProgressIndicator,
        Clip,
        Colors,
        Column,
        EdgeInsets,
        FontWeight,
        Icon,
        Icons,
        ListTile,
        ListView,
        MainAxisSize,
        RoundedRectangleBorder,
        Scaffold,
        State,
        StatefulWidget,
        Text,
        TextOverflow,
        TextStyle,
        ValueListenableBuilder,
        Widget;
import '/model/email.dart' show Email;
import '/controller/email.dart' show EmailController;
import '/controller/oauth.dart' show OAuthController;

class EmailsScreen extends StatefulWidget {
  final OAuthController oAuthController;

  const EmailsScreen({super.key, required this.oAuthController});

  @override
  State<EmailsScreen> createState() => _EmailsScreenState();
}

class _EmailsScreenState extends State<EmailsScreen> {
  late final EmailController _emailController;

  @override
  void initState() {
    super.initState();

    final currentUser = widget.oAuthController.currentUser;

    if (currentUser != null) {
      _emailController = EmailController(currentUser: currentUser);
      _emailController.loadSentMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        title: const Text('Emails', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ValueListenableBuilder(
        valueListenable: _emailController.isLoading,
        builder: (context, isLoading, child) {
          if (isLoading) return const Center(child: CircularProgressIndicator());

          return child!;
        },
        child: ValueListenableBuilder<List<Email>>(
          valueListenable: _emailController.emailsNotifier,
          builder: (context, emails, _) {
            if (emails.isEmpty) return _emptyEmails();

            return ListView.builder(
              itemCount: emails.length,
              itemBuilder: (context, index) {
                final email = emails[index];
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  clipBehavior: Clip.antiAlias,
                  margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                  child: ListTile(
                    title: Text(
                      email.subject,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'To: ${email.to}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _emptyEmails() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: [
          Icon(Icons.mail_outline, size: 48, color: Colors.grey),
          Text("No sent emails yet.\nTry sending some messages to see them here.", style: TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }
}
