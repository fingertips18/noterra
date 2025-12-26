import 'package:flutter/material.dart'
    show
        AlwaysScrollableScrollPhysics,
        AppBar,
        BorderRadius,
        BuildContext,
        ButtonStyle,
        Card,
        Center,
        Checkbox,
        CircularProgressIndicator,
        Clip,
        Colors,
        Column,
        CrossAxisAlignment,
        EdgeInsets,
        ElevatedButton,
        FontWeight,
        Icon,
        Icons,
        IgnorePointer,
        ListTile,
        ListView,
        MainAxisSize,
        MaterialPageRoute,
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
        TextAlign,
        TextOverflow,
        TextStyle,
        ValueListenableBuilder,
        Widget,
        WidgetStateProperty,
        WidgetsBinding;
import '/screens/email/view_email.dart' show ViewEmailScreen;
import '/utils/format.dart' show formatRelativeDate;
import '/presentation/states/email.dart' show DataState, EmailState, ErrorState, LoadingState, MoreState, RefreshState;
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
  final Set<Email> _selectedEmails = {};
  bool _hasAutoSelected = false; // Track if auto-selection has occurred

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
  void dispose() {
    final currentUser = widget.oAuthController.currentUser;
    if (currentUser != null) {
      _emailController.dispose();
    }
    super.dispose();
  }

  void _clearSelections() {
    if (_selectedEmails.isNotEmpty) {
      setState(() {
        _selectedEmails.clear();
      });
    }
  }

  // Auto-select today's emails
  void _autoSelectTodaysEmails(List<Email> emails) {
    final now = DateTime.now();
    final todaysEmails = emails.where((email) {
      final emailDate = email.date;
      return emailDate.year == now.year && emailDate.month == now.month && emailDate.day == now.day;
    }).toList();

    if (todaysEmails.isNotEmpty) {
      setState(() {
        _selectedEmails.addAll(todaysEmails);
      });
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
      body: RefreshIndicator(
        onRefresh: () async {
          _clearSelections();
          _hasAutoSelected = false;
          await _emailController.refresh();
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: ValueListenableBuilder<EmailState>(
            valueListenable: _emailController.stateNotifier,
            builder: (context, state, _) {
              // Auto-select today's emails when DataState is reached
              if (state is DataState && !_hasAutoSelected) {
                _hasAutoSelected = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final currentState = _emailController.stateNotifier.value;
                  if (currentState is DataState) {
                    _autoSelectTodaysEmails(currentState.emails);
                  }
                });
              }

              return switch (state) {
                LoadingState() => const Center(child: CircularProgressIndicator()),

                RefreshState(:final emails, :final hasMore) => Opacity(
                  opacity: 0.5,
                  child: IgnorePointer(ignoring: true, child: _listEmails(emails, hasMore, isLoadingMore: false)),
                ),

                MoreState(:final emails) => _listEmails(emails, true, isLoadingMore: true),

                DataState(:final emails, :final hasMore) => _listEmails(emails, hasMore, isLoadingMore: false),

                ErrorState(:final message, :final emails) => emails.isEmpty ? _errorView(message) : _listEmails(emails, false, isLoadingMore: false),
              };
            },
          ),
        ),
      ),
    );
  }

  Widget _listEmails(List<Email> emails, bool hasMore, {required bool isLoadingMore}) {
    if (emails.isEmpty) {
      return ListView(physics: const AlwaysScrollableScrollPhysics(), children: [_emptyEmails()]);
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: emails.length + (hasMore ? 1 : 0), // +1 for load more button
      itemBuilder: (context, index) {
        if (index == emails.length && hasMore) {
          return _loadMoreButton(hasMore, isLoadingMore);
        }

        final email = emails[index];
        return _emailCard(email);
      },
    );
  }

  Widget _loadMoreButton(bool hasMore, bool isLoadingMore) {
    if (!hasMore) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: isLoadingMore
          ? const Center(child: CircularProgressIndicator())
          : ElevatedButton(
              onPressed: () async {
                await _emailController.more();
              },
              style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.blueAccent), foregroundColor: WidgetStateProperty.all(Colors.white)),
              child: const Text('Load More', style: TextStyle(fontSize: 14)),
            ),
    );
  }

  Widget _emailCard(Email email) {
    final isSelected = _selectedEmails.contains(email);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: ListTile(
        leading: Checkbox(
          value: isSelected,
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                _selectedEmails.add(email);
              } else {
                _selectedEmails.remove(email);
              }
            });
          },
        ),
        title: Text(
          email.subject,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            Text(
              email.snippet,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "Updated: ${formatRelativeDate(email.date)}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewEmailScreen(emailController: _emailController, email: email),
            ),
          );
        },
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

  Widget _errorView(String message) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 10,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              Text(
                "Error: $message",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
              ElevatedButton(onPressed: _emailController.load, child: const Text('Retry')),
            ],
          ),
        ),
      ],
    );
  }
}
