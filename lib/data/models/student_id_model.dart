import 'package:equatable/equatable.dart';

class StudentIdModel extends Equatable {
  final String id;
  final String userId;
  final String studentNumber;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime? verifiedAt;

  const StudentIdModel({
    required this.id,
    required this.userId,
    required this.studentNumber,
    required this.isVerified,
    required this.createdAt,
    this.verifiedAt,
  });

  factory StudentIdModel.fromMap(Map<String, dynamic> map) {
    return StudentIdModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      studentNumber: map['studentNumber'] as String,
      isVerified: map['isVerified'] as bool? ?? false,
      createdAt: DateTime.parse(map['createdAt'] as String),
      verifiedAt: map['verifiedAt'] != null 
          ? DateTime.parse(map['verifiedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'studentNumber': studentNumber,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'verifiedAt': verifiedAt?.toIso8601String(),
    };
  }

  StudentIdModel copyWith({
    String? id,
    String? userId,
    String? studentNumber,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? verifiedAt,
  }) {
    return StudentIdModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      studentNumber: studentNumber ?? this.studentNumber,
      isVerified: isVerified ?? this.isVerified,
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
    createdAt,
    verifiedAt,
  ];

  @override
  String toString() {
    return 'StudentIdModel(id: $id, userId: $userId, studentNumber: $studentNumber, isVerified: $isVerified, createdAt: $createdAt, verifiedAt: $verifiedAt)';
  }
}