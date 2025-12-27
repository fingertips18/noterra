import 'package:equatable/equatable.dart' show Equatable;

import '/model/email.dart';

sealed class EmailState extends Equatable {
  const EmailState();
}

class LoadingState extends EmailState {
  const LoadingState();

  @override
  List<Object?> get props => [];
}

class RefreshState extends EmailState {
  final List<Email> emails;
  final bool hasMore;

  const RefreshState({required this.emails, required this.hasMore});

  @override
  List<Object?> get props => [emails, hasMore];
}

class MoreState extends EmailState {
  final List<Email> emails;

  const MoreState({required this.emails});

  @override
  List<Object?> get props => [emails];
}

class DataState extends EmailState {
  final List<Email> emails;
  final bool hasMore;

  const DataState({required this.emails, required this.hasMore});

  @override
  List<Object?> get props => [emails, hasMore];
}

class ErrorState extends EmailState {
  final String message;
  final List<Email> emails; // Keep existing emails on error

  const ErrorState({required this.message, this.emails = const []});

  @override
  List<Object?> get props => [message, emails];
}
