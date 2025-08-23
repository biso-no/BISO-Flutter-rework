import 'package:equatable/equatable.dart';

class BoardMemberModel extends Equatable {
  final String name;
  final String email;
  final String phone;
  final String role;
  final String officeLocation;
  final String? profilePhotoUrl;

  const BoardMemberModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.officeLocation,
    this.profilePhotoUrl,
  });

  factory BoardMemberModel.fromMap(Map<String, dynamic> map) {
    return BoardMemberModel(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? '',
      officeLocation: map['officeLocation'] ?? '',
      profilePhotoUrl: map['profilePhotoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'officeLocation': officeLocation,
      'profilePhotoUrl': profilePhotoUrl,
    };
  }

  BoardMemberModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? role,
    String? officeLocation,
    String? profilePhotoUrl,
  }) {
    return BoardMemberModel(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      officeLocation: officeLocation ?? this.officeLocation,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
    );
  }

  @override
  List<Object?> get props => [
        name,
        email,
        phone,
        role,
        officeLocation,
        profilePhotoUrl,
      ];
}

class BoardMembersResponse extends Equatable {
  final bool success;
  final List<BoardMemberModel> members;
  final int count;
  final String? departmentName;
  final String? campus;
  final String? message;
  final String? error;

  const BoardMembersResponse({
    required this.success,
    required this.members,
    required this.count,
    this.departmentName,
    this.campus,
    this.message,
    this.error,
  });

  factory BoardMembersResponse.fromMap(Map<String, dynamic> map) {
    return BoardMembersResponse(
      success: map['success'] ?? false,
      members: (map['members'] as List<dynamic>?)
              ?.map((memberMap) => BoardMemberModel.fromMap(memberMap))
              .toList() ??
          [],
      count: map['count'] ?? 0,
      departmentName: map['departmentName'],
      campus: map['campus'],
      message: map['message'],
      error: map['error'],
    );
  }

  @override
  List<Object?> get props => [
        success,
        members,
        count,
        departmentName,
        campus,
        message,
        error,
      ];
}