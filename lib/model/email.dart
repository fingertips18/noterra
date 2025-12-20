import 'package:equatable/equatable.dart' show Equatable;

class Email extends Equatable {
  final String id;
  final String snippet;
  final String subject;
  final String to;
  final int internalDate;
  final String? body;

  const Email({required this.id, required this.snippet, required this.subject, required this.to, required this.internalDate, this.body});

  DateTime get date => DateTime.fromMillisecondsSinceEpoch(internalDate);

  @override
  List<Object?> get props => [id, snippet, subject, to, internalDate, body];

  Map<String, dynamic> toMap() {
    return {"id": id, "snippet": snippet, "subject": subject, "to": to, "internalDate": internalDate, "body": body};
  }

  factory Email.fromMap(Map<String, dynamic> map) {
    return Email(
      id: map["id"] as String? ?? '',
      snippet: map["snippet"] as String? ?? '',
      subject: map["subject"] as String? ?? '(No subject)',
      to: map["to"] as String? ?? '(No recipient)',
      internalDate: map["internalDate"] as int? ?? 0,
      body: map["body"] as String?,
    );
  }

  Email copyWith({String? id, String? snippet, String? subject, String? to, int? internalDate, String? body}) {
    return Email(
      id: id ?? this.id,
      snippet: snippet ?? this.snippet,
      subject: subject ?? this.subject,
      to: to ?? this.to,
      internalDate: internalDate ?? this.internalDate,
      body: body ?? this.body,
    );
  }
}
