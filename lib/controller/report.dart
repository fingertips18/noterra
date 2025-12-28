import 'dart:async' show Future, TimeoutException;

import 'package:flutter/material.dart' show ValueNotifier;
import 'package:flutter_gemini/flutter_gemini.dart' show CandidateExtension, Gemini, Part;
import 'package:hive_flutter/hive_flutter.dart' show Hive;
import '/constants/string.dart' show StringConstants;
import '/model/report.dart' show Report;
import '/utils/format.dart' show formatRelativeDate;
import '/model/template.dart' show Template;
import '/model/email.dart' show Email;
import '/presentation/states/report.dart' show IdleState, DataState, ErrorState, GeneratingState, ListState, LoadingState, ReportState;

/// Controller for AI-powered report generation and persistence.
///
/// **Preconditions:**
/// - Hive must be initialized via `Hive.initFlutter()`
/// - The report box must be opened via `Hive.openBox(StringConstants.reportBox)`
/// - Gemini must be initialized via `Gemini.init()`
class ReportController {
  final ValueNotifier<ReportState> stateNotifier = ValueNotifier(const IdleState());
  late final Gemini _gemini;

  ReportController() {
    _gemini = Gemini.instance;
  }

  final reportBox = Hive.box(StringConstants.reportBox);

  Future<void> generateReport({required List<Email> emails, required List<Template> templates}) async {
    final timeoutSeconds = (emails.length * 10).clamp(60, 300);

    try {
      if (emails.isEmpty || templates.isEmpty) {
        stateNotifier.value = const ErrorState("Cannot generate report: emails and templates must not be empty");
        return;
      }

      stateNotifier.value = const GeneratingState();

      final parts = _buildPrompt(emails, templates);

      final response = await _gemini.prompt(parts: parts).timeout(Duration(seconds: timeoutSeconds));

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
      stateNotifier.value = ErrorState("Report generation timed out after $timeoutSeconds seconds");
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
    if (report.key == null) {
      final key = await reportBox.add(report.toMap());
      return report.copyWith(key: key);
    } else {
      await reportBox.put(report.key, report.toMap());
      return report;
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
      // Optimistically update state without LoadingState flicker
      final currentState = stateNotifier.value;
      if (currentState is ListState) {
        final updatedReports = currentState.reports.where((r) => r.key != key).toList();
        stateNotifier.value = ListState(updatedReports);
      } else {
        await listReports(); // Fallback to full refresh
      }
    } catch (e) {
      stateNotifier.value = ErrorState("Failed to delete report: ${e.toString()}");
    }
  }

  /// Sets an existing report as the current state.
  /// Used when viewing a previously generated report.
  void setExistingReport(Report report) {
    stateNotifier.value = DataState(report);
  }

  void dispose() {
    stateNotifier.dispose();
  }
}
