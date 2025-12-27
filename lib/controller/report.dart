import 'dart:async' show Future, TimeoutException;

import 'package:flutter/material.dart' show ValueNotifier;
import 'package:flutter_gemini/flutter_gemini.dart' show CandidateExtension, Gemini, Part;
import 'package:hive_flutter/hive_flutter.dart' show Hive;
import '/constants/string.dart' show StringConstants;
import '/model/report.dart' show Report;
import '/utils/format.dart' show formatRelativeDate;
import '/model/template.dart' show Template;
import '/model/email.dart' show Email;
import '/presentation/states/report.dart' show DataState, ErrorState, GeneratingState, ListState, LoadingState, ReportState;

class ReportController {
  final ValueNotifier<ReportState> stateNotifier = ValueNotifier(const LoadingState());
  late final Gemini _gemini;

  ReportController() {
    _gemini = Gemini.instance;
  }

  final reportBox = Hive.box(StringConstants.reportBox);

  Future<void> generateReport({required List<Email> emails, required List<Template> templates}) async {
    try {
      if (emails.isEmpty || templates.isEmpty) {
        stateNotifier.value = const ErrorState("Cannot generate report: emails and templates must not be empty");
        return;
      }

      stateNotifier.value = const GeneratingState();

      final parts = _buildPrompt(emails, templates);

      final response = await _gemini.prompt(parts: parts).timeout(Duration(seconds: emails.length * 10));

      if (response == null) {
        stateNotifier.value = const ErrorState("No response received from AI service");
        return;
      }

      final content = response.output ?? "";

      if (content.isEmpty) {
        stateNotifier.value = const ErrorState("Generated report is empty");
        return;
      }

      final report = Report(
        content: content,
        templateKeys: templates.map((t) => t.key).toList(),
        emailIDs: emails.map((e) => e.id).toList(),
        generatedAt: DateTime.now(),
        metadata: {"model": "gemini", "template_count": templates.length, "email_count": emails.length},
      );

      final savedReport = await saveReport(report);
      stateNotifier.value = DataState(savedReport);
    } on TimeoutException {
      stateNotifier.value = const ErrorState("Report generation timed out after 30 seconds");
    } catch (e) {
      stateNotifier.value = ErrorState("Failed to generate report: ${e.toString()}");
    }
  }

  List<Part> _buildPrompt(List<Email> emails, List<Template> templates) {
    final List<Part> parts = [];

    parts.add(Part.text("Generate a report based on the following templates:"));

    for (var template in templates) {
      parts.add(Part.text("Title: ${template.title}"));
      parts.add(Part.text("Body: ${template.body}"));
      parts.add(Part.text("--------------------------------------------------"));
    }

    parts.add(Part.text("Emails to analyze:"));

    for (int i = 0; i < emails.length; i++) {
      final email = emails[i];
      parts.add(Part.text("Email ${i + 1}:"));
      parts.add(Part.text("Subject: ${email.subject}"));
      parts.add(Part.text("To: ${email.to}"));
      parts.add(Part.text("Date: ${formatRelativeDate(email.date)}"));
      parts.add(Part.text("Body: ${email.body ?? email.snippet}"));
      parts.add(Part.text("--------------------------------------------------"));
    }

    parts.add(Part.text("Please generate a comprehensive report following the template structure above."));
    parts.add(Part.text("Format the report using Markdown syntax (e.g., **bold**, *italic*, # headings) for easy copy and paste."));

    return parts;
  }

  Future<Report> saveReport(Report report) async {
    try {
      if (report.key == null) {
        final key = await reportBox.add(report.toMap());
        return report.copyWith(key: key);
      } else {
        await reportBox.put(report.key, report.toMap());
        return report;
      }
    } catch (e) {
      throw Exception("Failed to save report: ${e.toString()}");
    }
  }

  Future<void> listReports() async {
    try {
      stateNotifier.value = const LoadingState();

      final reports = reportBox
          .toMap()
          .entries
          .where((e) {
            return e.value is Map && e.key is int;
          })
          .map((e) {
            final value = Map<String, dynamic>.from(e.value as Map);
            return Report.fromMap(value).copyWith(key: e.key as int);
          })
          .toList();

      // Sort by generatedAt descending (newest first)
      reports.sort((a, b) => b.generatedAt.compareTo(a.generatedAt));

      stateNotifier.value = ListState(reports);
    } catch (e) {
      stateNotifier.value = ErrorState("Failed to load reports: ${e.toString()}");
    }
  }

  Future<void> deleteReport(int key) async {
    try {
      await reportBox.delete(key);
      await listReports(); // Refresh the list
    } catch (e) {
      stateNotifier.value = ErrorState("Failed to delete report: ${e.toString()}");
    }
  }

  void dispose() {
    stateNotifier.dispose();
  }
}
