import 'package:flutter/material.dart'
    show
        AlwaysScrollableScrollPhysics,
        AppBar,
        BorderRadius,
        BuildContext,
        ButtonStyle,
        Card,
        Center,
        CircularProgressIndicator,
        Clip,
        Colors,
        Column,
        EdgeInsets,
        ElevatedButton,
        FontWeight,
        Icon,
        Icons,
        IgnorePointer,
        ListTile,
        ListView,
        MainAxisSize,
        Navigator,
        Opacity,
        Padding,
        RefreshIndicator,
        RoundedRectangleBorder,
        Scaffold,
        SizedBox,
        State,
        StatefulWidget,
        Text,
        TextOverflow,
        TextStyle,
        ValueListenableBuilder,
        Widget,
        WidgetsBinding;
import 'package:flutter/widgets.dart';
import '/constants/status.dart' show Status;
import '/widgets/toast.dart' show toast;
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

    if (currentUser == null) {
      // Navigate back and show toast error - user shouldn't reach this screen without auth
      WidgetsBinding.instance.addPostFrameCallback((_) {
        toast(message: "Unauthorized", status: Status.error);
        Navigator.of(context).pop();
      });
      return;
    }
    _emailController = EmailController(currentUser: currentUser);
    _emailController.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        title: const Text('Emails', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        onRefresh: _emailController.refresh,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: ValueListenableBuilder<bool>(
            valueListenable: _emailController.isRefreshing,
            builder: (context, isRefreshing, child) {
              return Opacity(
                opacity: isRefreshing ? 0.5 : 1.0,
                child: IgnorePointer(ignoring: isRefreshing, child: child!),
              );
            },
            child: ValueListenableBuilder<bool>(
              valueListenable: _emailController.isLoading,
              builder: (context, isLoading, child) {
                if (isLoading) return const Center(child: CircularProgressIndicator());

                return child!;
              },
              child: ValueListenableBuilder<List<Email>>(
                valueListenable: _emailController.emailsNotifier,
                builder: (context, emails, _) {
                  if (emails.isEmpty) {
                    return ListView(physics: const AlwaysScrollableScrollPhysics(), children: [_emptyEmails()]);
                  }

                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: emails.length + 1, // +1 for load more button
                    itemBuilder: (context, index) {
                      // Show load more button at the end
                      if (index == emails.length) {
                        return ValueListenableBuilder<bool>(
                          valueListenable: _emailController.hasMore,
                          builder: (context, hasMore, _) {
                            if (!hasMore) return const SizedBox.shrink();

                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: ValueListenableBuilder<bool>(
                                valueListenable: _emailController.isLoadingMore,
                                builder: (context, isLoadingMore, _) {
                                  if (isLoadingMore) {
                                    return const Center(child: CircularProgressIndicator());
                                  }

                                  return ElevatedButton(
                                    onPressed: () {
                                      _emailController.more();
                                    },
                                    style: ButtonStyle(
                                      backgroundColor: WidgetStateProperty.all(Colors.blueAccent),
                                      foregroundColor: WidgetStateProperty.all(Colors.white),
                                    ),
                                    child: const Text('Load More', style: TextStyle(fontSize: 14)),
                                  );
                                },
                              ),
                            );
                          },
                        );
                      }

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
          ),
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
