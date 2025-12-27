import 'package:equatable/equatable.dart' show Equatable;

import '/model/report.dart';

sealed class ReportState extends Equatable {
  const ReportState();
}

class IdleState extends ReportState {
  const IdleState();

  @override
  List<Object?> get props => [];
}

class LoadingState extends ReportState {
  const LoadingState();

  @override
  List<Object?> get props => [];
}

class GeneratingState extends ReportState {
  const GeneratingState();

  @override
  List<Object?> get props => [];
}

class DataState extends ReportState {
  final Report report;

  const DataState(this.report);

  @override
  List<Object?> get props => [report];
}

class ListState extends ReportState {
  final List<Report> reports;

  const ListState(this.reports);

  @override
  List<Object?> get props => [reports];
}

class ErrorState extends ReportState {
  final String message;

  const ErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
