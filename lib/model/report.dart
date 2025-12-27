import 'package:equatable/equatable.dart' show Equatable;

class Report extends Equatable {
  final String key;
  final String title;
  final String content;
  final List<int?> templateKeys;
  final List<String> emailIDs;
  final DateTime generatedAt;
  final Map<String, dynamic>? metadata;

  const Report({
    required this.key,
    required this.title,
    required this.content,
    required this.templateKeys,
    required this.emailIDs,
    required this.generatedAt,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      "key": key,
      "title": title,
      "content": content,
      "template_keys": templateKeys,
      "email_ids": emailIDs,
      "generated_at": generatedAt.toIso8601String(),
      "metadata": metadata,
    };
  }

  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      key: map["key"],
      title: map["title"],
      content: map["content"],
      templateKeys: map["template_keys"],
      emailIDs: (map["email_ids"] as List).map((e) => e.toString()).toList(),
      generatedAt: DateTime.parse(map["generated_at"] as String),
      metadata: map["metadata"],
    );
  }

  Report copyWith({
    String? key,
    title,
    content,
    List<int?>? templateKeys,
    List<String>? emailIDs,
    DateTime? generatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Report(
      key: key ?? this.key,
      title: title ?? this.title,
      content: content ?? this.content,
      templateKeys: templateKeys ?? this.templateKeys,
      emailIDs: emailIDs ?? this.emailIDs,
      generatedAt: generatedAt ?? this.generatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [key, title, content, templateKeys, emailIDs, generatedAt, metadata];
}
