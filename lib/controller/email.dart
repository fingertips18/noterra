import 'dart:convert' show base64, utf8;

import 'package:flutter/material.dart' show ValueNotifier, debugPrint;
import 'package:google_sign_in/google_sign_in.dart' show GoogleSignInAccount;
import 'package:googleapis/gmail/v1.dart' as gmail show GmailApi, MessagePart;
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
      final gmailAPI = gmail.GmailApi(authClient);

      // List messages with SENT label using typed method
      final messagesResponse = await gmailAPI.users.messages.list('me', labelIds: ['SENT'], maxResults: maxResults, pageToken: pageToken);

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
          final fullMessage = await gmailAPI.users.messages.get('me', message.id!, format: 'metadata', metadataHeaders: ['Subject', 'To']);

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
    if (stateNotifier.value is LoadingState || stateNotifier.value is RefreshState || stateNotifier.value is MoreState) {
      return;
    }

    // Show refreshing state with current emails visible
    stateNotifier.value = RefreshState(emails: _emails, hasMore: _hasMore);

    final previousEmails = _emails;
    final previousHasMore = _hasMore;
    final previousNextPageToken = _nextPageToken;

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
      _hasMore = previousHasMore;
      _nextPageToken = previousNextPageToken;
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

  // Helper method to decode base64url encoded data
  String _decodeBase64(String data) {
    try {
      // Gmail uses base64url encoding (RFC 4648)
      // Replace URL-safe characters and add padding if necessary
      String normalized = data.replaceAll('-', '+').replaceAll('_', '/');

      // Add padding if needed
      while (normalized.length % 4 != 0) {
        normalized += '=';
      }

      final bytes = base64.decode(normalized);
      return utf8.decode(bytes, allowMalformed: true);
    } catch (e) {
      debugPrint('Error decoding base64: $e');
      return '';
    }
  }

  // Helper method to extract plain text from message payload
  String _extractTextFromPayload(gmail.MessagePart payload) {
    if (payload.mimeType == 'text/plain' && payload.body?.data != null) {
      return _decodeBase64(payload.body!.data!);
    }

    // Check parts for multipart messages
    if (payload.parts != null) {
      for (final part in payload.parts!) {
        if (part.mimeType == 'text/plain' && part.body?.data != null) {
          return _decodeBase64(part.body!.data!);
        } else if (part.parts != null) {
          // Recursive search in nested parts
          final result = _extractTextFromPayload(part);
          if (result.isNotEmpty) {
            return result;
          }
        }
      }
    }

    return '';
  }

  // Helper method to extract HTML from message payload
  String _extractHTMLFromPayload(gmail.MessagePart payload) {
    if (payload.mimeType == 'text/html' && payload.body?.data != null) {
      return _decodeBase64(payload.body!.data!);
    }

    // Check parts for multipart messages
    if (payload.parts != null) {
      for (final part in payload.parts!) {
        if (part.mimeType == 'text/html' && part.body?.data != null) {
          return _decodeBase64(part.body!.data!);
        } else if (part.parts != null) {
          // Recursive search in nested parts
          final result = _extractHTMLFromPayload(part);
          if (result.isNotEmpty) {
            return result;
          }
        }
      }
    }

    return '';
  }

  Future<String> fetchEmailBody(String messageId) async {
    // Get authorization from the account
    final authorization = await currentUser.authorizationClient.authorizeScopes(_scopes);

    // Use the extension to get authenticated client
    final authClient = authorization.authClient(scopes: _scopes);

    try {
      // Create typed Gmail API client
      final gmailAPI = gmail.GmailApi(authClient);

      // Fetch the full message with full format to get the body
      final fullMessage = await gmailAPI.users.messages.get('me', messageId, format: 'full');

      // Extract the body from the message payload
      String body = '';

      if (fullMessage.payload != null) {
        // Try to get plain text body first
        body = _extractTextFromPayload(fullMessage.payload!);

        if (body.isEmpty) {
          // Fallback to HTML body if plain text is not available
          body = _extractHTMLFromPayload(fullMessage.payload!);
        }
      }

      return body.isNotEmpty ? body : fullMessage.snippet ?? 'No content available';
    } catch (e) {
      debugPrint('Error fetching email body: $e');
      throw Exception('Failed to load email body: $e');
    } finally {
      // Always close the client
      authClient.close();
    }
  }

  void dispose() {
    stateNotifier.dispose();
  }
}
