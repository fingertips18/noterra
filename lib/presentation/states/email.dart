import '/model/email.dart';

sealed class EmailState {
  const EmailState();
}

class LoadingState extends EmailState {
  const LoadingState();
}

class RefreshState extends EmailState {
  final List<Email> emails;
  final bool hasMore;

  const RefreshState({required this.emails, required this.hasMore});
}

class MoreState extends EmailState {
  final List<Email> emails;

  const MoreState({required this.emails});
}

class DataState extends EmailState {
  final List<Email> emails;
  final bool hasMore;

  const DataState({required this.emails, required this.hasMore});
}

class ErrorState extends EmailState {
  final String message;
  final List<Email> emails; // Keep existing emails on error

  const ErrorState({required this.message, this.emails = const []});
}
