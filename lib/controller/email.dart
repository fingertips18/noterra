import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

const baseURL = "https://gmail.googleapis.com/gmail/v1/users/me/messages";

class EmailController {
  final GoogleSignInAccount currentUser;

  EmailController({required this.currentUser});

  static const List<String> _scopes = ['https://www.googleapis.com/auth/gmail.readonly'];

  // All retrieved emails
  final ValueNotifier<List<Map<String, dynamic>>> emailsNotifier = ValueNotifier([]);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  /// Load latest SENT messages ("Sent Mail" label)
  Future<void> loadSentMessages({int maxResults = 50}) async {
    isLoading.value = true;
    emailsNotifier.value = [];
    try {
      final authClient = currentUser.authorizationClient;

      // Get authorization headers (map with 'Authorization': 'Bearer ...')
      final headers = await authClient.authorizationHeaders(_scopes, promptIfNecessary: true);
      if (headers == null || !headers.containsKey("Authorization")) {
        debugPrint('Failed to obtain authorization headers: $headers');
        emailsNotifier.value = [];
        return;
      }

      // List messages with labelIds=SENT
      final listUri = Uri.parse('$baseURL?labelIds=SENT&maxResults=$maxResults');

      final listRes = await http.get(listUri, headers: headers);
      if (listRes.statusCode != 200) {
        debugPrint('List call failed: ${listRes.statusCode} ${listRes.body}');
        emailsNotifier.value = [];
        return;
      }

      final listJson = jsonDecode(listRes.body) as Map<String, dynamic>;
      final List msgs = listJson['messages'] ?? [];

      final List<Map<String, dynamic>> output = [];

      // Fetch metadata for each message
      for (final m in msgs) {
        final id = m["id"] as String?;
        if (id == null) continue;

        final msgUri = Uri.parse('$baseURL/$id?format=metadata&metadataHeaders=Subject&metadataHeaders=To');
        final msgRes = await http.get(msgUri, headers: headers);
        if (msgRes.statusCode != 200) continue;

        final msgJson = jsonDecode(msgRes.body) as Map<String, dynamic>;

        final payload = msgJson["payload"] as Map<String, dynamic>?;
        final headersList = payload?["headers"] as List<dynamic>? ?? [];

        String subject = "(No subject)";
        String to = "(No recipient)";

        for (final h in headersList) {
          if (h is Map<String, dynamic>) {
            final name = h["name"] as String? ?? "";
            final value = h["value"] as String? ?? "";
            if (name.toLowerCase() == "subject") subject = value;
            if (name.toLowerCase() == "to") to = value;
          }
        }

        final internalDateRaw = msgJson["internalDate"];
        int internalDate;
        if (internalDateRaw is int) {
          internalDate = internalDateRaw;
        } else if (internalDateRaw is String) {
          internalDate = int.tryParse(internalDateRaw) ?? 0;
        } else {
          internalDate = 0;
        }

        output.add({"id": id, "snippet": msgJson["snippet"], "subject": subject, "to": to, "internalDate": internalDate});
      }

      // Sort by internalDate descending (newest first)
      output.sort((a, b) => (b["internalDate"] as int).compareTo(a["internalDate"] as int));

      emailsNotifier.value = output;
    } catch (e, st) {
      debugPrint('Error loading sent messages: $e\n$st');
      emailsNotifier.value = [];
    } finally {
      isLoading.value = false;
    }
  }
}
