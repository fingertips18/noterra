import 'package:flutter/material.dart'
    show
        AppBar,
        BackButton,
        Border,
        BorderRadius,
        BoxDecoration,
        BuildContext,
        Card,
        Center,
        CircularProgressIndicator,
        CloseButton,
        Colors,
        Column,
        Container,
        CrossAxisAlignment,
        Divider,
        EdgeInsets,
        ElevatedButton,
        Expanded,
        FontWeight,
        Icon,
        IconButton,
        IconData,
        Icons,
        MainAxisAlignment,
        Navigator,
        Padding,
        Row,
        Scaffold,
        ScaffoldMessenger,
        SelectableText,
        SingleChildScrollView,
        SizedBox,
        SnackBar,
        State,
        StatefulWidget,
        Text,
        TextAlign,
        TextButton,
        TextStyle,
        Theme,
        ValueListenableBuilder,
        Widget,
        WidgetsBinding;
import 'package:flutter/services.dart' show Clipboard, ClipboardData, FontWeight, TextAlign;
import '/controller/report.dart' show ReportController;
import '/model/email.dart' show Email;
import '/model/report.dart' show Report;
import '/model/template.dart' show Template;
import '/presentation/states/report.dart' show DataState, ErrorState, GeneratingState, LoadingState, ReportState;
import '/utils/format.dart' show formatRelativeDate;
import '/widgets/confirmation.dart' show confirmation;

class ReportScreen extends StatefulWidget {
  final List<Email>? selectedEmails;
  final List<Template>? templates;
  final ReportController controller;
  final Report? existingReport;

  const ReportScreen({super.key, required this.selectedEmails, required this.templates, required this.controller}) : existingReport = null;

  const ReportScreen.view({super.key, required Report report, required this.controller})
    : existingReport = report,
      selectedEmails = null,
      templates = null;

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  @override
  void initState() {
    super.initState();

    if (widget.existingReport == null) {
      // Generation mode - trigger report generation
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.selectedEmails == null || widget.templates == null) {
          widget.controller.stateNotifier.value = const ErrorState("Invalid state: missing emails or templates");
          return;
        }

        widget.controller.generateReport(emails: widget.selectedEmails!, templates: widget.templates!);
      });
    } else {
      // Viewing mode - set existing report as state
      widget.controller.setExistingReport(widget.existingReport!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        title: ValueListenableBuilder<ReportState>(
          valueListenable: widget.controller.stateNotifier,
          builder: (context, state, _) {
            return Text("${state is DataState ? "Generated" : "Generate"} Report", style: const TextStyle(fontWeight: FontWeight.bold));
          },
        ),
        leading: ValueListenableBuilder<ReportState>(
          valueListenable: widget.controller.stateNotifier,
          builder: (context, value, _) {
            if (value is DataState) {
              return BackButton(onPressed: () => Navigator.of(context).pop());
            }
            return CloseButton(onPressed: () => Navigator.of(context).pop());
          },
        ),
        actions: [
          ValueListenableBuilder<ReportState>(
            valueListenable: widget.controller.stateNotifier,
            builder: (context, state, _) {
              if (state is DataState) {
                return Row(
                  children: [
                    IconButton(
                      onPressed: () => _copyToClipboard(context, report: state.report),
                      icon: const Icon(Icons.copy),
                      tooltip: "Copy to clipboard",
                    ),
                    IconButton(
                      onPressed: () => _deleteReport(context, report: state.report),
                      icon: const Icon(Icons.delete),
                      tooltip: "Delete report",
                    ),
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<ReportState>(
        valueListenable: widget.controller.stateNotifier,
        builder: (context, state, _) {
          // Loading or Generating state
          if (state is LoadingState || state is GeneratingState) {
            final emailCount = widget.selectedEmails?.length ?? 0;
            final templateCount = widget.templates?.length ?? 0;
            final timeoutSeconds = (emailCount * 10).clamp(60, 300);

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 24),
                    Text("Generating report...", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Text(
                      "Using $emailCount email${emailCount != 1 ? 's' : ''} with $templateCount template${templateCount != 1 ? 's' : ''}",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    Text("This may take up to $timeoutSeconds seconds", style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                  ],
                ),
              ),
            );
          }

          // Success - show report
          if (state is DataState) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Metadata section
                  _buildMetadataCard(state.report),
                  const SizedBox(height: 20),

                  // Report content
                  Text("Report Content", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: SelectableText(state.report.content, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14, height: 1.6)),
                  ),
                ],
              ),
            );
          }

          // Error state
          if (state is ErrorState) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
                    const SizedBox(height: 16),
                    Text(
                      "Error",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.redAccent, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(state.message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 24),
                    if (widget.selectedEmails != null && widget.templates != null)
                      ElevatedButton(
                        onPressed: () {
                          widget.controller.generateReport(emails: widget.selectedEmails!, templates: widget.templates!);
                        },
                        child: const Text("Retry"),
                      ),
                    const SizedBox(height: 8),
                    TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Back")),
                  ],
                ),
              ),
            );
          }

          return const Center(child: Text("Initializing..."));
        },
      ),
    );
  }

  Widget _buildMetadataCard(Report report) {
    final metadata = report.metadata ?? {};
    final emailCount = metadata["email_count"] ?? report.emailIDs.length;
    final templateCount = metadata["template_count"] ?? report.templateKeys.length;
    final model = metadata["model"]?.toString() ?? "Unknown";

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 24,
          children: [
            _buildMetadataRow(icon: Icons.access_time, label: "Generated", value: formatRelativeDate(report.generatedAt)),
            const Divider(),
            _buildMetadataRow(icon: Icons.description, label: "Templates", value: "$templateCount template${templateCount != 1 ? 's' : ''}"),
            const Divider(),
            _buildMetadataRow(icon: Icons.email, label: "Emails", value: "$emailCount email${emailCount != 1 ? 's' : ''}"),
            const Divider(),
            _buildMetadataRow(icon: Icons.psychology, label: "Model", value: model),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataRow({required IconData icon, required String label, required String value}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blueAccent),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600)),
              Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _copyToClipboard(BuildContext context, {required Report report}) async {
    await Clipboard.setData(ClipboardData(text: report.content));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Report copied to clipboard"), duration: Duration(seconds: 2)));
    }
  }

  Future<void> _deleteReport(BuildContext context, {required Report report}) async {
    await confirmation(
      context: context,
      title: "Delete Report",
      content: "Are you sure you want to delete this report?",
      action: () async {
        if (report.key == null) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cannot delete report: invalid key")));
          }
          return;
        }

        await widget.controller.deleteReport(report.key!);
      },
    );
  }
}
