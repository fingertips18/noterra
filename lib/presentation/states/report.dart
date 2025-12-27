import '/model/report.dart';

sealed class ReportState {
  const ReportState();
}

class LoadingState extends ReportState {
  const LoadingState();
}

class GeneratingState extends ReportState {
  const GeneratingState();
}

class DataState extends ReportState {
  final Report report;

  const DataState(this.report);
}

class ListState extends ReportState {
  final List<Report> reports;

  const ListState(this.reports);
}

class ErrorState extends ReportState {
  final String message;

  const ErrorState(this.message);
}
