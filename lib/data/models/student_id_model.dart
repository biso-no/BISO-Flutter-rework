import 'package:equatable/equatable.dart';

class StudentIdModel extends Equatable {
  final String id;
  final String userId;
  final String studentNumber;
  final bool isVerified;
  final bool isMember;
  final DateTime? membershipExpiry;
  final Map<String, dynamic>? membershipDetails;
  final DateTime createdAt;
  final DateTime? verifiedAt;

  const StudentIdModel({
    required this.id,
    required this.userId,
    required this.studentNumber,
    required this.isVerified,
    this.isMember = false,
    this.membershipExpiry,
    this.membershipDetails,
    required this.createdAt,
    this.verifiedAt,
  });

  factory StudentIdModel.fromMap(Map<String, dynamic> map) {
    return StudentIdModel(
      id: map['\$id'] ?? map['id'] ?? '',
      userId: map['user_id'] ?? map['userId'] ?? '',
      studentNumber: map['student_number'] ?? map['studentNumber'] ?? '',
      isVerified: map['verified'] ?? map['isVerified'] ?? false,
      isMember: map['is_member'] ?? map['isMember'] ?? false,
      membershipExpiry: map['membership_expiry'] != null
          ? DateTime.parse(map['membership_expiry'])
          : (map['membershipExpiry'] != null
                ? DateTime.parse(map['membershipExpiry'])
                : null),
      membershipDetails: map['membership_details'] as Map<String, dynamic>?,
      createdAt: map['\$createdAt'] != null
          ? DateTime.parse(map['\$createdAt'])
          : (map['createdAt'] != null
                ? DateTime.parse(map['createdAt'])
                : DateTime.now()),
      verifiedAt: map['verified_at'] != null
          ? DateTime.parse(map['verified_at'])
          : (map['verifiedAt'] != null
                ? DateTime.parse(map['verifiedAt'])
                : null),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'student_number': studentNumber,
      'verified': isVerified,
      'is_member': isMember,
      'membership_expiry': membershipExpiry?.toIso8601String(),
      'membership_details': membershipDetails,
      'verified_at': verifiedAt?.toIso8601String(),
    };
  }

  StudentIdModel copyWith({
    String? id,
    String? userId,
    String? studentNumber,
    bool? isVerified,
    bool? isMember,
    DateTime? membershipExpiry,
    Map<String, dynamic>? membershipDetails,
    DateTime? createdAt,
    DateTime? verifiedAt,
  }) {
    return StudentIdModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      studentNumber: studentNumber ?? this.studentNumber,
      isVerified: isVerified ?? this.isVerified,
      isMember: isMember ?? this.isMember,
      membershipExpiry: membershipExpiry ?? this.membershipExpiry,
      membershipDetails: membershipDetails ?? this.membershipDetails,
      createdAt: createdAt ?? this.createdAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    studentNumber,
    isVerified,
    isMember,
    membershipExpiry,
    membershipDetails,
    createdAt,
    verifiedAt,
  ];

  // Helper methods
  bool get hasValidMembership {
    if (!isMember) return false;
    if (membershipExpiry == null) return true; // Lifetime membership
    return DateTime.now().isBefore(membershipExpiry!);
  }

  String get membershipStatus {
    if (!isVerified) return 'Unverified';
    if (!isMember) return 'Not a Member';
    if (hasValidMembership) return 'Active Member';
    return 'Membership Expired';
  }

  @override
  String toString() {
    return 'StudentIdModel(id: $id, userId: $userId, studentNumber: $studentNumber, isVerified: $isVerified, isMember: $isMember, membershipStatus: $membershipStatus)';
  }
}
