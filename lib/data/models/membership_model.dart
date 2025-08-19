import 'package:equatable/equatable.dart';

enum MembershipStatus { active, expired, pending }

/// Represents a membership from the 24SevenOffice/Database integration
class MembershipModel extends Equatable {
  final String id; // membership_id from database
  final String name; // membership name
  final int price; // price in NOK
  final String category; // category ID that matches 24SevenOffice
  final bool status; // active status
  final DateTime? expiryDate; // when membership expires
  final DateTime? createdAt;

  const MembershipModel({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.status,
    this.expiryDate,
    this.createdAt,
  });

  factory MembershipModel.fromMap(Map<String, dynamic> map) {
    return MembershipModel(
      id: map['\$id'] ?? map['membership_id'] ?? '',
      name: map['name'] ?? '',
      price: map['price'] ?? 0,
      category: map['category']?.toString() ?? '',
      status: map['status'] ?? false,
      expiryDate: map['expiryDate'] != null
          ? DateTime.parse(map['expiryDate'])
          : null,
      createdAt: map['\$createdAt'] != null
          ? DateTime.parse(map['\$createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'category': category,
      'status': status,
      'expiryDate': expiryDate?.toIso8601String(),
    };
  }

  MembershipModel copyWith({
    String? id,
    String? name,
    int? price,
    String? category,
    bool? status,
    DateTime? expiryDate,
    DateTime? createdAt,
  }) {
    return MembershipModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      category: category ?? this.category,
      status: status ?? this.status,
      expiryDate: expiryDate ?? this.expiryDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isActive =>
      status && (expiryDate == null || expiryDate!.isAfter(DateTime.now()));
  bool get isExpired =>
      !status || (expiryDate != null && expiryDate!.isBefore(DateTime.now()));

  String get displayName => name;
  int get priceNok => price;

  @override
  List<Object?> get props => [
    id,
    name,
    price,
    category,
    status,
    expiryDate,
    createdAt,
  ];
}

class MembershipVerificationResult extends Equatable {
  final bool isMember;
  final MembershipModel? membership;
  final String? error;

  const MembershipVerificationResult({
    required this.isMember,
    this.membership,
    this.error,
  });

  @override
  List<Object?> get props => [isMember, membership, error];
}

class MembershipPurchaseOption extends Equatable {
  final String membershipId;
  final String displayName;
  final int priceNok;
  final String description;
  final List<String> benefits;
  final String category;

  const MembershipPurchaseOption({
    required this.membershipId,
    required this.displayName,
    required this.priceNok,
    required this.description,
    required this.benefits,
    required this.category,
  });

  /// Creates a purchase option from a membership model
  factory MembershipPurchaseOption.fromMembership(
    MembershipModel membership, {
    String? description,
    List<String>? benefits,
  }) {
    return MembershipPurchaseOption(
      membershipId: membership.id,
      displayName: membership.name,
      priceNok: membership.price,
      category: membership.category,
      description: description ?? 'BISO membership - ${membership.name}',
      benefits:
          benefits ??
          [
            'Access to all events',
            'Expense reimbursements',
            'Marketplace discounts',
            'Student chat access',
            'Priority support',
          ],
    );
  }

  @override
  List<Object?> get props => [
    membershipId,
    displayName,
    priceNok,
    description,
    benefits,
    category,
  ];
}
