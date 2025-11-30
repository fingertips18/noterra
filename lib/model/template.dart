import 'package:equatable/equatable.dart';

class Template extends Equatable {
  final int? key;
  final String title;
  final String body;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Template({this.key, required this.title, required this.body, required this.createdAt, required this.updatedAt});

  @override
  List<Object?> get props => [key, title, body, createdAt, updatedAt];

  // Convert Template to Map for Hive storage
  Map<String, dynamic> toMap() {
    return {"key": key, "title": title, "body": body, "created_at": createdAt.toIso8601String(), "updated_at": updatedAt.toIso8601String()};
  }

  // Create Template from Map
  factory Template.fromMap(Map<String, dynamic> map) {
    return Template(
      key: map["key"],
      title: map["title"],
      body: map["body"],
      createdAt: map["created_at"] != null ? DateTime.parse(map["created_at"]) : DateTime.now(),
      updatedAt: map["updated_at"] != null ? DateTime.parse(map["updated_at"]) : DateTime.now(),
    );
  }
}
