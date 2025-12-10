import 'package:flutter/material.dart' show ValueNotifier, debugPrint;
import 'package:google_sign_in/google_sign_in.dart' show GoogleSignInAccount;
import 'package:googleapis/gmail/v1.dart' as gmail show GmailApi;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart' show GoogleApisGoogleSignInAuth;
import "/model/email.dart" show Email;

// Define the scopes needed (must match what was used during authentication)
const _scopes = ['https://www.googleapis.com/auth/gmail.readonly'];

class EmailController {
  final GoogleSignInAccount currentUser;

  EmailController({required this.currentUser});

  // All retrieved emails
  final ValueNotifier<List<Email>> emailsNotifier = ValueNotifier([]);

  // Loading states
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<bool> isRefreshing = ValueNotifier(false);

  // Load more
  String? _nextPageToken; // Track the next page token
  final ValueNotifier<bool> hasMore = ValueNotifier(true);
  final ValueNotifier<bool> isLoadingMore = ValueNotifier(false);

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
      hasMore.value = _nextPageToken != null;

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
        output = [...emailsNotifier.value, ...output];
      }

      // Sort by internalDate descending (newest first)
      output.sort((a, b) => b.internalDate.compareTo(a.internalDate));

      emailsNotifier.value = output;
    } finally {
      // Always close the client
      authClient.close();
    }
  }

  // Load latest SENT messages ("Sent Mail" label)
  Future<void> load() async {
    isLoading.value = true;
    emailsNotifier.value = [];

    // Reset pagination
    _nextPageToken = null;
    hasMore.value = true;

    try {
      await _listSentMessages(); // Start fresh without pageToken
    } catch (e, st) {
      debugPrint('Error loading sent messages: $e\n$st');
      emailsNotifier.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() async {
    isRefreshing.value = true;
    emailsNotifier.value = [];

    // Reset pagination
    _nextPageToken = null;
    hasMore.value = true;

    try {
      await _listSentMessages();
    } catch (e, st) {
      debugPrint('Error refreshing sent messages: $e\n$st');
      emailsNotifier.value = [];
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<void> more() async {
    if (_nextPageToken == null || isLoadingMore.value || isLoading.value || isRefreshing.value) {
      return;
    }

    isLoadingMore.value = true;

    try {
      await _listSentMessages(pageToken: _nextPageToken);
    } catch (e, st) {
      debugPrint('Error loading more messages: $e\n$st');
    } finally {
      isLoadingMore.value = false;
    }
  }
}
