import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tag.g.dart';

/// Tag entity for categorizing tasks
@JsonSerializable()
class Tag extends Equatable {
  final String id;
  final String name;
  final String? color;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Tag({
    required this.id,
    required this.name,
    this.color,
    required this.createdAt,
    this.updatedAt,
  });

  /// Creates a new tag with generated ID and current timestamp
  factory Tag.create({
    required String name,
    String? color,
  }) {
    return Tag(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      color: color,
      createdAt: DateTime.now(),
    );
  }

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);

  Map<String, dynamic> toJson() => _$TagToJson(this);

  Tag copyWith({
    String? id,
    String? name,
    String? color,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Tag(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  @override
  List<Object?> get props => [id, name, color, createdAt, updatedAt];
}
