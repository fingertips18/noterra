import 'package:flutter/material.dart' show ValueNotifier, debugPrint;
import 'package:google_sign_in/google_sign_in.dart' show GoogleSignInAccount;
import 'package:googleapis/gmail/v1.dart' as gmail show GmailApi;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart' show GoogleApisGoogleSignInAuth;
import '/widgets/toast.dart' show toast;
import '/presentation/states/email.dart' show DataState, EmailState, ErrorState, LoadingState, MoreState, RefreshState;
import "/model/email.dart" show Email;
import '/constants/status.dart' show Status;

// Define the scopes needed (must match what was used during authentication)
const _scopes = ['https://www.googleapis.com/auth/gmail.readonly'];

class EmailController {
  final GoogleSignInAccount currentUser;

  EmailController({required this.currentUser});

  final ValueNotifier<EmailState> stateNotifier = ValueNotifier(const LoadingState());

  List<Email> _emails = [];
  String? _nextPageToken;
  bool _hasMore = true;

  Future<void> _listSentMessages({int maxResults = 10, String? pageToken}) async {
    // Get authorization from the account
    final authorization = await currentUser.authorizationClient.authorizeScopes(_scopes);

    // Use the extension to get authenticated client
    final authClient = authorization.authClient(scopes: _scopes);

    try {
      // Create typed Gmail API client
      final gmailApi = gmail.GmailApi(authClient);

      // List messages with SENT label using typed method
      final messagesResponse = await gmailApi.users.messages.list('me', labelIds: ['SENT'], maxResults: maxResults, pageToken: pageToken);

      // Store the next page token
      _nextPageToken = messagesResponse.nextPageToken;
      _hasMore = _nextPageToken != null;

      final messages = messagesResponse.messages ?? [];
      List<Email> output = [];

      // Fetch metadata for each message
      for (final message in messages) {
        if (message.id == null) continue;

        try {
          // Get message details with metadata format
          final fullMessage = await gmailApi.users.messages.get('me', message.id!, format: 'metadata', metadataHeaders: ['Subject', 'To']);

          // Extract headers using typed models
          final headers = fullMessage.payload?.headers ?? [];
          String subject = '(No subject)';
          String to = '(No recipient)';

          for (final header in headers) {
            if (header.name?.toLowerCase() == 'subject') {
              subject = header.value ?? subject;
            }
            if (header.name?.toLowerCase() == 'to') {
              to = header.value ?? to;
            }
          }

          // Parse internal date (comes as string milliseconds since epoch)
          final internalDate = fullMessage.internalDate != null ? int.tryParse(fullMessage.internalDate!) ?? 0 : 0;

          output.add(Email(id: message.id!, snippet: fullMessage.snippet ?? '', subject: subject, to: to, internalDate: internalDate));
        } catch (e) {
          debugPrint('Error fetching message ${message.id}: $e');
          continue; // Skip problematic messages
        }
      }

      // If has more append to existing list
      if (pageToken != null) {
        output = [..._emails, ...output];
      }

      // Sort by internalDate descending (newest first)
      output.sort((a, b) => b.internalDate.compareTo(a.internalDate));

      _emails = output;
    } finally {
      // Always close the client
      authClient.close();
    }
  }

  // Load latest SENT messages ("Sent Mail" label)
  Future<void> load() async {
    stateNotifier.value = const LoadingState();

    // Reset
    _emails = [];
    _nextPageToken = null;
    _hasMore = true;

    try {
      await _listSentMessages(); // Start fresh without pageToken
      stateNotifier.value = DataState(emails: _emails, hasMore: _hasMore);
    } catch (e, st) {
      debugPrint('Error loading sent messages: $e\n$st');
      stateNotifier.value = ErrorState(message: e.toString());
      toast(message: "Failed to load messages", status: Status.error);
    }
  }

  Future<void> refresh() async {
    // Show refreshing state with current emails visible
    stateNotifier.value = RefreshState(emails: _emails, hasMore: _hasMore);

    final previousEmails = _emails;
    _emails = [];
    _nextPageToken = null;
    _hasMore = true;

    try {
      await _listSentMessages();
      stateNotifier.value = DataState(emails: _emails, hasMore: _hasMore);
    } catch (e, st) {
      debugPrint('Error refreshing sent messages: $e\n$st');
      // Restore previous state on error
      _emails = previousEmails;
      stateNotifier.value = DataState(emails: _emails, hasMore: _hasMore);
      toast(message: "Failed to refresh messages", status: Status.error);
    }
  }

  Future<void> more() async {
    // Guard checks
    if (_nextPageToken == null || !_hasMore) return;

    // Prevent concurrent loads
    if (stateNotifier.value is LoadingState || stateNotifier.value is RefreshState || stateNotifier.value is MoreState) {
      return;
    }

    stateNotifier.value = MoreState(emails: _emails);

    try {
      await _listSentMessages(pageToken: _nextPageToken);
      stateNotifier.value = DataState(emails: _emails, hasMore: _hasMore);
    } catch (e, st) {
      debugPrint('Error loading more messages: $e\n$st');
      // Return to previous state on error
      stateNotifier.value = DataState(emails: _emails, hasMore: _hasMore);
      toast(message: "Failed to load more messages", status: Status.error);
    }
  }

  void dispose() {
    stateNotifier.dispose();
  }
}
