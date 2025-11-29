import 'package:equatable/equatable.dart';

class Template extends Equatable {
  final String title;
  final String body;

  const Template({required this.title, required this.body});

  @override
  List<Object> get props => [title, body];

  // Convert Template to Map for Hive storage
  Map<String, dynamic> toMap() {
    return {"title": title, "body": body};
  }

  // Create Template from Map
  factory Template.fromMap(Map<String, dynamic> map) {
    return Template(title: map["title"], body: map["body"]);
  }
}
