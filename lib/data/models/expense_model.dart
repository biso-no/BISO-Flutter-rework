import 'package:equatable/equatable.dart';

class ExpenseModel extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final double amount;
  final String currency;
  final String description;
  final String category; // 'event', 'travel', 'supplies', 'food', 'other'
  final String departmentId;
  final String departmentName;
  final String? eventId; // Optional association with an event
  final String? eventName;
  final String bankAccount; // Norwegian 11-digit format
  final String accountHolderName;
  final bool isPrepayment; // Request advance payment
  final List<String> attachments; // Receipt file URLs
  final String status; // 'draft', 'submitted', 'under_review', 'approved', 'rejected', 'paid'
  final String? rejectionReason;
  final String? approverUserId;
  final String? approverName;
  final DateTime? approvedAt;
  final DateTime? paidAt;
  final String? transactionReference;
  final Map<String, dynamic> metadata; // Additional expense data
  final DateTime expenseDate; // Date of the actual expense
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ExpenseModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.amount,
    this.currency = 'NOK',
    required this.description,
    required this.category,
    required this.departmentId,
    required this.departmentName,
    this.eventId,
    this.eventName,
    required this.bankAccount,
    required this.accountHolderName,
    this.isPrepayment = false,
    this.attachments = const [],
    this.status = 'draft',
    this.rejectionReason,
    this.approverUserId,
    this.approverName,
    this.approvedAt,
    this.paidAt,
    this.transactionReference,
    this.metadata = const {},
    required this.expenseDate,
    this.createdAt,
    this.updatedAt,
  });

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['\$id'] ?? '',
      userId: map['user_id'] ?? '',
      userName: map['user_name'] ?? '',
      userEmail: map['user_email'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      currency: map['currency'] ?? 'NOK',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      departmentId: map['department_id'] ?? '',
      departmentName: map['department_name'] ?? '',
      eventId: map['event_id'],
      eventName: map['event_name'],
      bankAccount: map['bank_account'] ?? '',
      accountHolderName: map['account_holder_name'] ?? '',
      isPrepayment: map['is_prepayment'] ?? false,
      attachments: List<String>.from(map['attachments'] ?? []),
      status: map['status'] ?? 'draft',
      rejectionReason: map['rejection_reason'],
      approverUserId: map['approver_user_id'],
      approverName: map['approver_name'],
      approvedAt: map['approved_at'] != null ? DateTime.parse(map['approved_at']) : null,
      paidAt: map['paid_at'] != null ? DateTime.parse(map['paid_at']) : null,
      transactionReference: map['transaction_reference'],
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
      expenseDate: DateTime.parse(map['expense_date']),
      createdAt: map['\$createdAt'] != null ? DateTime.parse(map['\$createdAt']) : null,
      updatedAt: map['\$updatedAt'] != null ? DateTime.parse(map['\$updatedAt']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'user_name': userName,
      'user_email': userEmail,
      'amount': amount,
      'currency': currency,
      'description': description,
      'category': category,
      'department_id': departmentId,
      'department_name': departmentName,
      'event_id': eventId,
      'event_name': eventName,
      'bank_account': bankAccount,
      'account_holder_name': accountHolderName,
      'is_prepayment': isPrepayment,
      'attachments': attachments,
      'status': status,
      'rejection_reason': rejectionReason,
      'approver_user_id': approverUserId,
      'approver_name': approverName,
      'approved_at': approvedAt?.toIso8601String(),
      'paid_at': paidAt?.toIso8601String(),
      'transaction_reference': transactionReference,
      'metadata': metadata,
      'expense_date': expenseDate.toIso8601String(),
    };
  }

  ExpenseModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    double? amount,
    String? currency,
    String? description,
    String? category,
    String? departmentId,
    String? departmentName,
    String? eventId,
    String? eventName,
    String? bankAccount,
    String? accountHolderName,
    bool? isPrepayment,
    List<String>? attachments,
    String? status,
    String? rejectionReason,
    String? approverUserId,
    String? approverName,
    DateTime? approvedAt,
    DateTime? paidAt,
    String? transactionReference,
    Map<String, dynamic>? metadata,
    DateTime? expenseDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      description: description ?? this.description,
      category: category ?? this.category,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      eventId: eventId ?? this.eventId,
      eventName: eventName ?? this.eventName,
      bankAccount: bankAccount ?? this.bankAccount,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      isPrepayment: isPrepayment ?? this.isPrepayment,
      attachments: attachments ?? this.attachments,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      approverUserId: approverUserId ?? this.approverUserId,
      approverName: approverName ?? this.approverName,
      approvedAt: approvedAt ?? this.approvedAt,
      paidAt: paidAt ?? this.paidAt,
      transactionReference: transactionReference ?? this.transactionReference,
      metadata: metadata ?? this.metadata,
      expenseDate: expenseDate ?? this.expenseDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isDraft => status == 'draft';
  bool get isSubmitted => status == 'submitted';
  bool get isUnderReview => status == 'under_review';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isPaid => status == 'paid';
  bool get canEdit => isDraft;
  bool get canSubmit => isDraft && attachments.isNotEmpty;
  String get formattedAmount => '${amount.toStringAsFixed(2)} $currency';
  String get displayStatus {
    switch (status) {
      case 'draft': return 'Draft';
      case 'submitted': return 'Submitted';
      case 'under_review': return 'Under Review';
      case 'approved': return 'Approved';
      case 'rejected': return 'Rejected';
      case 'paid': return 'Paid';
      default: return status;
    }
  }

  String get displayCategory {
    switch (category) {
      case 'event': return 'Event Expenses';
      case 'travel': return 'Travel';
      case 'supplies': return 'Supplies';
      case 'food': return 'Food & Beverages';
      case 'other': return 'Other';
      default: return category;
    }
  }

  // Validate Norwegian bank account number (11 digits with MOD11 checksum)
  bool get isValidBankAccount {
    if (bankAccount.length != 11) return false;
    if (!RegExp(r'^\d+$').hasMatch(bankAccount)) return false;
    
    // MOD11 validation for Norwegian bank accounts
    final digits = bankAccount.split('').map(int.parse).toList();
    final weights = [5, 4, 3, 2, 7, 6, 5, 4, 3, 2, 1];
    int sum = 0;
    
    for (int i = 0; i < digits.length; i++) {
      sum += digits[i] * weights[i];
    }
    
    return sum % 11 == 0;
  }

  @override
  List<Object?> get props => [
    id, userId, userName, userEmail, amount, currency, description,
    category, departmentId, departmentName, eventId, eventName,
    bankAccount, accountHolderName, isPrepayment, attachments,
    status, rejectionReason, approverUserId, approverName,
    approvedAt, paidAt, transactionReference, metadata,
    expenseDate, createdAt, updatedAt,
  ];
}