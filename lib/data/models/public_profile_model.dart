import 'package:equatable/equatable.dart';

class PublicProfileModel extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String? email;
  final String? phone;
  final String? campusId;
  final String? avatar;
  final bool emailVisible;
  final bool phoneVisible;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PublicProfileModel({
    required this.id,
    required this.userId,
    required this.name,
    this.email,
    this.phone,
    this.campusId,
    this.avatar,
    this.emailVisible = false,
    this.phoneVisible = false,
    this.createdAt,
    this.updatedAt,
  });

  factory PublicProfileModel.fromMap(Map<String, dynamic> map) {
    return PublicProfileModel(
      id: map['\$id'] ?? '',
      userId: map['user_id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'],
      phone: map['phone'],
      campusId: map['campus_id'],
      avatar: map['avatar'],
      emailVisible: map['email_visible'] ?? false,
      phoneVisible: map['phone_visible'] ?? false,
      createdAt: map['\$createdAt'] != null ? DateTime.parse(map['\$createdAt']) : null,
      updatedAt: map['\$updatedAt'] != null ? DateTime.parse(map['\$updatedAt']) : null,
    );
  }

  factory PublicProfileModel.fromDocument(dynamic document) {
    if (document is Map<String, dynamic>) {
      return PublicProfileModel.fromMap(document);
    }
    return PublicProfileModel.fromMap(document.data);
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'campus_id': campusId,
      'avatar': avatar,
      'email_visible': emailVisible,
      'phone_visible': phoneVisible,
    };
  }

  PublicProfileModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? email,
    String? phone,
    String? campusId,
    String? avatar,
    bool? emailVisible,
    bool? phoneVisible,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PublicProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      campusId: campusId ?? this.campusId,
      avatar: avatar ?? this.avatar,
      emailVisible: emailVisible ?? this.emailVisible,
      phoneVisible: phoneVisible ?? this.phoneVisible,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get the display email - only returns email if it's visible
  String? get displayEmail => emailVisible ? email : null;

  /// Get the display phone - only returns phone if it's visible
  String? get displayPhone => phoneVisible ? phone : null;

  /// Get a map suitable for display in UI (respects visibility settings)
  Map<String, dynamic> toDisplayMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'email': displayEmail,
      'phone': displayPhone,
      'campus_id': campusId,
      'avatar': avatar,
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        email,
        phone,
        campusId,
        avatar,
        emailVisible,
        phoneVisible,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'PublicProfileModel(id: $id, userId: $userId, name: $name, emailVisible: $emailVisible, phoneVisible: $phoneVisible)';
  }
}