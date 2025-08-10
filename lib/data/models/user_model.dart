import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final String? city;
  final String? zipCode;
  final String? campusId;
  final String? studentId;
  final List<String> departments;
  final String? avatarUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.city,
    this.zipCode,
    this.campusId,
    this.studentId,
    this.departments = const [],
    this.avatarUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    print('🔍 UserModel.fromMap - Raw map keys: ${map.keys.toList()}');
    print('🔍 UserModel.fromMap - department_ids type: ${map['department_ids'].runtimeType}, value: ${map['department_ids']}');
    
    return UserModel(
      id: map['\$id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'],
      address: map['address'],
      city: map['city'],
      zipCode: map['zip'],
      campusId: map['campus_id'],
      studentId: map['student_id'], // Use the direct string field, not the relationship
      departments: _parseDepartmentIds(map['department_ids']), // Use department_ids string array
      avatarUrl: map['avatar'],
      createdAt: map['\$createdAt'] != null ? DateTime.parse(map['\$createdAt']) : null,
      updatedAt: map['\$updatedAt'] != null ? DateTime.parse(map['\$updatedAt']) : null,
    );
  }

  // Helper method to safely parse department IDs
  static List<String> _parseDepartmentIds(dynamic departmentIds) {
    if (departmentIds == null) return <String>[];
    if (departmentIds is List) {
      return departmentIds.map((e) => e?.toString() ?? '').where((e) => e.isNotEmpty).toList();
    }
    if (departmentIds is String) {
      return [departmentIds];
    }
    return <String>[];
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'zip': zipCode,
      'campus_id': campusId,
      'student_id': studentId,
      'departments': departments,
      'avatar': avatarUrl,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? zipCode,
    String? campusId,
    String? studentId,
    List<String>? departments,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      zipCode: zipCode ?? this.zipCode,
      campusId: campusId ?? this.campusId,
      studentId: studentId ?? this.studentId,
      departments: departments ?? this.departments,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        address,
        city,
        zipCode,
        campusId,
        studentId,
        departments,
        avatarUrl,
        createdAt,
        updatedAt,
      ];
}