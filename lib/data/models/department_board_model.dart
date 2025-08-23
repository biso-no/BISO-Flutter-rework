import 'package:equatable/equatable.dart';

class DepartmentBoardModel extends Equatable {
  final String id;
  final String name;
  final String role;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DepartmentBoardModel({
    required this.id,
    required this.name,
    required this.role,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory DepartmentBoardModel.fromMap(Map<String, dynamic> map) {
    return DepartmentBoardModel(
      id: map['\$id'] ?? map['id'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? '',
      imageUrl: map['imageUrl'],
      createdAt: map['\$createdAt'] != null
          ? DateTime.parse(map['\$createdAt'])
          : null,
      updatedAt: map['\$updatedAt'] != null
          ? DateTime.parse(map['\$updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'role': role,
      'imageUrl': imageUrl,
    };
  }

  DepartmentBoardModel copyWith({
    String? id,
    String? name,
    String? role,
    String? imageUrl,
  }) {
    return DepartmentBoardModel(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        role,
        imageUrl,
        createdAt,
        updatedAt,
      ];
}