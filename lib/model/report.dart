import 'package:equatable/equatable.dart' show Equatable;

class Report extends Equatable {
  final int? key;
  final String content;
  final List<int?> templateKeys;
  final List<String> emailIDs;
  final DateTime generatedAt;
  final Map<String, dynamic>? metadata;

  const Report({this.key, required this.content, required this.templateKeys, required this.emailIDs, required this.generatedAt, this.metadata});

  Map<String, dynamic> toMap() {
    return {
      "key": key,
      "content": content,
      "template_keys": templateKeys,
      "email_ids": emailIDs,
      "generated_at": generatedAt.toIso8601String(),
      "metadata": metadata,
    };
  }

  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      key: map["key"] as int?,
      content: map["content"] as String,
      templateKeys: (map["template_keys"] as List<dynamic>).map((e) => e as int?).toList(),
      emailIDs: (map["email_ids"] as List<dynamic>).map((e) => e.toString()).toList(),
      generatedAt: DateTime.parse(map["generated_at"] as String),
      metadata: map["metadata"] as Map<String, dynamic>?,
    );
  }

  Report copyWith({
    int? key,
    String? content,
    List<int?>? templateKeys,
    List<String>? emailIDs,
    DateTime? generatedAt,
    Object? metadata = const _Sentinel(),
  }) {
    return Report(
      key: key ?? this.key,
      content: content ?? this.content,
      templateKeys: templateKeys ?? this.templateKeys,
      emailIDs: emailIDs ?? this.emailIDs,
      generatedAt: generatedAt ?? this.generatedAt,
      metadata: identical(metadata, const _Sentinel()) ? this.metadata : metadata as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [key, content, templateKeys, emailIDs, generatedAt, metadata];
}

class _Sentinel {
  const _Sentinel();
}
