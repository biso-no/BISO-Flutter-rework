import 'dart:io';
import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as aw_models;
import 'package:http/http.dart' as http;

import '../../core/constants/app_constants.dart';
import '../../core/logging/print_migration.dart';
import '../models/expense_model.dart';
import '../models/expense_attachment_model.dart';
import 'appwrite_service.dart';
import 'robust_document_service.dart';

class ExpenseService {
  static const String expensesCollectionId = AppConstants.expensesCollectionId;
  static const String attachmentsCollectionId = AppConstants.expenseAttachmentsCollectionId;

  Future<Map<String, dynamic>> createExpenseDocument({
    required Map<String, dynamic> data,
  }) async {
    final map = await RobustDocumentService.createDocumentRobust(
      databaseId: AppConstants.databaseId,
      collectionId: expensesCollectionId,
      data: data,
    );
    return map;
  }

  Future<String> uploadAttachmentFile(File file) async {
    final aw_models.File created = await storage.createFile(
      bucketId: AppConstants.expensesBucketId,
      fileId: ID.unique(),
      file: InputFile.fromPath(path: file.path),
    );
    return _publicFileUrl(AppConstants.expensesBucketId, created.$id);
  }

  Future<Map<String, dynamic>> createAttachmentDocument({
    required DateTime date,
    required String url,
    required double amount,
    required String description,
    required String type,
  }) async {
    final map = await RobustDocumentService.createDocumentRobust(
      databaseId: AppConstants.databaseId,
      collectionId: attachmentsCollectionId,
      data: {
        'date': date.toIso8601String(),
        'url': url,
        'amount': amount,
        'description': description,
        'type': type,
      },
    );
    return map;
  }

  Future<List<Map<String, dynamic>>> listDepartmentsForCampus(String campusId) async {
    final results = await RobustDocumentService.listDocumentsRobust(
      databaseId: AppConstants.databaseId,
      collectionId: AppConstants.departmentsCollectionId,
      queries: [
        Query.equal('campus_id', campusId),
        Query.orderAsc('Name'),
        Query.limit(100),
      ],
    );
    return results;
  }

  Future<List<Map<String, String>>> listCampuses() async {
    final results = await RobustDocumentService.listDocumentsRobust(
      databaseId: AppConstants.databaseId,
      collectionId: AppConstants.campusesCollectionId,
      queries: [
        Query.select(['\$id', 'name']),
        Query.orderAsc('name'),
        Query.limit(100),
      ],
    );
    return results.map((e) => {
      'id': (e['\$id'] ?? '').toString(),
      'name': (e['name'] ?? '').toString(),
    }).where((e) => e['id']!.isNotEmpty && e['name']!.isNotEmpty).toList();
  }

  Future<Map<String, dynamic>> analyzeReceiptText(String ocrText) async {
    final endpoint = client.endPoint;
    final projectId = client.config['project'];
    final cachedJwt = await RobustDocumentService.getSessionJwt();
    final jwt = cachedJwt ?? (await account.createJWT()).jwt;
    final url = '$endpoint/functions/${AppConstants.fnParseReceiptId}/executions';
    final res = await http.post(
      Uri.parse(url),
      headers: {
        'content-type': 'application/json',
        'X-Appwrite-Project': projectId ?? '',
        'X-Appwrite-JWT': jwt,
      },
      body: jsonEncode({'body': ocrText}),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final response = (data['response'] ?? '') as String;
      if (response.isEmpty) return <String, dynamic>{};
      try {
        return jsonDecode(response) as Map<String, dynamic>;
      } catch (_) {
        return <String, dynamic>{};
      }
    }
    return <String, dynamic>{};
  }

  Future<String> summarizeExpenseDescriptions(List<String> descriptions) async {
    final endpoint = client.endPoint;
    final projectId = client.config['project'];
    final cachedJwt = await RobustDocumentService.getSessionJwt();
    final jwt = cachedJwt ?? (await account.createJWT()).jwt;
    final url = '$endpoint/functions/${AppConstants.fnSummarizeExpenseId}/executions';
    final payload = {'descriptions': descriptions};
    final res = await http.post(
      Uri.parse(url),
      headers: {
        'content-type': 'application/json',
        'X-Appwrite-Project': projectId ?? '',
        'X-Appwrite-JWT': jwt,
      },
      body: jsonEncode({'body': jsonEncode(payload)}),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final response = (data['response'] ?? '') as String;
      return response;
    }
    return '';
  }

  String _publicFileUrl(String bucketId, String fileId) {
    final endpoint = client.endPoint;
    final projectId = client.config['project'];
    return '$endpoint/storage/buckets/$bucketId/files/$fileId/view?project=$projectId';
  }

  // MARK: - New Database Operations for Production

  /// Get all expenses for the current user
  Future<List<ExpenseModel>> getUserExpenses({
    String? userId,
    List<String> queries = const [],
  }) async {
    try {
      logPrint('💰 ExpenseService: Fetching user expenses');
      
      // If no userId provided, get current user
      String targetUserId = userId ?? '';
      if (targetUserId.isEmpty) {
        try {
          final user = await account.get();
          targetUserId = user.$id;
        } catch (e) {
          logPrint('💰 ExpenseService: No authenticated user, returning empty list');
          return [];
        }
      }

      // Build queries to filter by user
      final userQueries = [
        'equal("userId", "$targetUserId")',
        ...queries,
      ];

      final documents = await RobustDocumentService.listDocumentsRobust(
        databaseId: AppConstants.databaseId,
        collectionId: expensesCollectionId,
        queries: userQueries,
      );

      logPrint('💰 ExpenseService: Found ${documents.length} expenses');

      final expenses = <ExpenseModel>[];
      for (final doc in documents) {
        try {
          // Fetch attachments for each expense
          final expenseId = doc['\$id'];
          final attachments = await _getExpenseAttachments(expenseId);
          
          // Add attachments to document data
          final docWithAttachments = Map<String, dynamic>.from(doc);
          docWithAttachments['expenseAttachments'] = attachments.map((a) => a.toMap()).toList();
          
          final expense = ExpenseModel.fromMap(docWithAttachments);
          expenses.add(expense);
        } catch (e) {
          logPrint('💰 ExpenseService: Failed to parse expense ${doc['\$id']}: $e');
          // Continue with other expenses instead of failing completely
        }
      }

      return expenses;
    } catch (e) {
      logPrint('💰 ExpenseService: Failed to fetch user expenses: $e');
      throw Exception('Failed to fetch expenses: $e');
    }
  }

  /// Get a specific expense by ID
  Future<ExpenseModel?> getExpense(String expenseId) async {
    try {
      logPrint('💰 ExpenseService: Fetching expense $expenseId');

      final doc = await RobustDocumentService.getDocumentRobust(
        databaseId: AppConstants.databaseId,
        collectionId: expensesCollectionId,
        documentId: expenseId,
      );

      // Fetch attachments
      final attachments = await _getExpenseAttachments(expenseId);
      
      // Add attachments to document data
      final docWithAttachments = Map<String, dynamic>.from(doc);
      docWithAttachments['expenseAttachments'] = attachments.map((a) => a.toMap()).toList();

      return ExpenseModel.fromMap(docWithAttachments);
    } catch (e) {
      logPrint('💰 ExpenseService: Failed to fetch expense $expenseId: $e');
      return null;
    }
  }

  /// Create a new expense
  Future<ExpenseModel> createExpense({
    required String campus,
    required String department,
    required String bankAccount,
    String? description,
    required double total,
    double? prepaymentAmount,
    String status = 'pending',
    String? eventName,
    List<ExpenseAttachmentModel> attachments = const [],
  }) async {
    try {
      logPrint('💰 ExpenseService: Creating new expense');

      // Get current user
      final user = await account.get();
      
      final expenseData = {
        'userId': user.$id,
        'campus': campus,
        'department': department,
        'bank_account': bankAccount,
        if (description != null) 'description': description,
        'total': total,
        if (prepaymentAmount != null) 'prepayment_amount': prepaymentAmount,
        'status': status,
        if (eventName != null) 'eventName': eventName,
      };

      final doc = await RobustDocumentService.createDocumentRobust(
        databaseId: AppConstants.databaseId,
        collectionId: expensesCollectionId,
        data: expenseData,
      );

      final expenseId = doc['\$id'];
      logPrint('💰 ExpenseService: Created expense $expenseId');

      // Create attachments if provided
      final createdAttachments = <ExpenseAttachmentModel>[];
      for (final attachment in attachments) {
        try {
          final attachmentData = attachment.toMap();
          attachmentData['expense_id'] = expenseId; // Link to expense
          
          final attachmentDoc = await RobustDocumentService.createDocumentRobust(
            databaseId: AppConstants.databaseId,
            collectionId: attachmentsCollectionId,
            data: attachmentData,
          );
          
          createdAttachments.add(ExpenseAttachmentModel.fromMap(attachmentDoc));
        } catch (e) {
          logPrint('💰 ExpenseService: Failed to create attachment: $e');
          // Continue with other attachments
        }
      }

      // Add attachments to document data and return expense
      final docWithAttachments = Map<String, dynamic>.from(doc);
      docWithAttachments['expenseAttachments'] = createdAttachments.map((a) => a.toMap()).toList();

      return ExpenseModel.fromMap(docWithAttachments);
    } catch (e) {
      logPrint('💰 ExpenseService: Failed to create expense: $e');
      throw Exception('Failed to create expense: $e');
    }
  }

  /// Update an existing expense
  Future<ExpenseModel> updateExpense({
    required String expenseId,
    String? campus,
    String? department,
    String? bankAccount,
    String? description,
    double? total,
    double? prepaymentAmount,
    String? status,
    String? eventName,
  }) async {
    try {
      logPrint('💰 ExpenseService: Updating expense $expenseId');

      final updateData = <String, dynamic>{};
      if (campus != null) updateData['campus'] = campus;
      if (department != null) updateData['department'] = department;
      if (bankAccount != null) updateData['bank_account'] = bankAccount;
      if (description != null) updateData['description'] = description;
      if (total != null) updateData['total'] = total;
      if (prepaymentAmount != null) updateData['prepayment_amount'] = prepaymentAmount;
      if (status != null) updateData['status'] = status;
      if (eventName != null) updateData['eventName'] = eventName;

      final doc = await RobustDocumentService.updateDocumentRobust(
        databaseId: AppConstants.databaseId,
        collectionId: expensesCollectionId,
        documentId: expenseId,
        data: updateData,
      );

      // Fetch attachments
      final attachments = await _getExpenseAttachments(expenseId);
      
      // Add attachments to document data
      final docWithAttachments = Map<String, dynamic>.from(doc);
      docWithAttachments['expenseAttachments'] = attachments.map((a) => a.toMap()).toList();

      return ExpenseModel.fromMap(docWithAttachments);
    } catch (e) {
      logPrint('💰 ExpenseService: Failed to update expense $expenseId: $e');
      throw Exception('Failed to update expense: $e');
    }
  }

  /// Delete an expense
  Future<void> deleteExpense(String expenseId) async {
    try {
      logPrint('💰 ExpenseService: Deleting expense $expenseId');

      // Delete all attachments first
      final attachments = await _getExpenseAttachments(expenseId);
      for (final attachment in attachments) {
        if (attachment.id != null) {
          try {
            await RobustDocumentService.deleteDocumentRobust(
              databaseId: AppConstants.databaseId,
              collectionId: attachmentsCollectionId,
              documentId: attachment.id!,
            );
          } catch (e) {
            logPrint('💰 ExpenseService: Failed to delete attachment ${attachment.id}: $e');
            // Continue with other attachments
          }
        }
      }

      // Delete the expense
      await RobustDocumentService.deleteDocumentRobust(
        databaseId: AppConstants.databaseId,
        collectionId: expensesCollectionId,
        documentId: expenseId,
      );

      logPrint('💰 ExpenseService: Successfully deleted expense $expenseId');
    } catch (e) {
      logPrint('💰 ExpenseService: Failed to delete expense $expenseId: $e');
      throw Exception('Failed to delete expense: $e');
    }
  }

  /// Add attachment to an expense
  Future<ExpenseAttachmentModel> addExpenseAttachment({
    required String expenseId,
    required String type,
    DateTime? date,
    String? url,
    double? amount,
    String? description,
  }) async {
    try {
      logPrint('💰 ExpenseService: Adding attachment to expense $expenseId');

      final attachmentData = {
        'expense_id': expenseId,
        'type': type,
        if (date != null) 'date': date.toIso8601String(),
        if (url != null) 'url': url,
        if (amount != null) 'amount': amount,
        if (description != null) 'description': description,
      };

      final doc = await RobustDocumentService.createDocumentRobust(
        databaseId: AppConstants.databaseId,
        collectionId: attachmentsCollectionId,
        data: attachmentData,
      );

      return ExpenseAttachmentModel.fromMap(doc);
    } catch (e) {
      logPrint('💰 ExpenseService: Failed to add attachment: $e');
      throw Exception('Failed to add attachment: $e');
    }
  }

  /// Get attachments for a specific expense
  Future<List<ExpenseAttachmentModel>> _getExpenseAttachments(String expenseId) async {
    try {
      logPrint('💰 ExpenseService: Fetching attachments for expense $expenseId');

      final documents = await RobustDocumentService.listDocumentsRobust(
        databaseId: AppConstants.databaseId,
        collectionId: attachmentsCollectionId,
        queries: ['equal("expense", "$expenseId")'],
      );

      final attachments = documents
          .map((doc) {
            try {
              return ExpenseAttachmentModel.fromMap(doc);
            } catch (e) {
              logPrint('💰 ExpenseService: Failed to parse attachment ${doc['\$id']}: $e');
              return null;
            }
          })
          .where((attachment) => attachment != null)
          .cast<ExpenseAttachmentModel>()
          .toList();

      logPrint('💰 ExpenseService: Found ${attachments.length} attachments');
      return attachments;
    } catch (e) {
      logPrint('💰 ExpenseService: Failed to fetch attachments: $e');
      return [];
    }
  }

  /// Get expenses filtered by status
  Future<List<ExpenseModel>> getExpensesByStatus(String status, {String? userId}) async {
    return getUserExpenses(
      userId: userId,
      queries: ['equal("status", "$status")'],
    );
  }

  /// Get expenses filtered by campus
  Future<List<ExpenseModel>> getExpensesByCampus(String campus, {String? userId}) async {
    return getUserExpenses(
      userId: userId,
      queries: ['equal("campus", "$campus")'],
    );
  }

  /// Get expenses filtered by department
  Future<List<ExpenseModel>> getExpensesByDepartment(String department, {String? userId}) async {
    return getUserExpenses(
      userId: userId,
      queries: ['equal("department", "$department")'],
    );
  }

  /// Get expense statistics for the current user
  Future<Map<String, dynamic>> getExpenseStatistics({String? userId}) async {
    try {
      final expenses = await getUserExpenses(userId: userId);
      
      final stats = <String, dynamic>{
        'total_count': expenses.length,
        'total_amount': 0.0,
        'pending_count': 0,
        'pending_amount': 0.0,
        'approved_count': 0,
        'approved_amount': 0.0,
        'rejected_count': 0,
        'rejected_amount': 0.0,
        'paid_count': 0,
        'paid_amount': 0.0,
        'prepayment_count': 0,
        'prepayment_amount': 0.0,
      };

      for (final expense in expenses) {
        stats['total_amount'] += expense.total;
        
        switch (expense.status) {
          case 'pending':
            stats['pending_count']++;
            stats['pending_amount'] += expense.total;
            break;
          case 'approved':
            stats['approved_count']++;
            stats['approved_amount'] += expense.total;
            break;
          case 'rejected':
            stats['rejected_count']++;
            stats['rejected_amount'] += expense.total;
            break;
          case 'paid':
            stats['paid_count']++;
            stats['paid_amount'] += expense.total;
            break;
        }

        if (expense.hasPrepayment) {
          stats['prepayment_count']++;
          stats['prepayment_amount'] += expense.prepaymentAmount ?? 0.0;
        }
      }

      return stats;
    } catch (e) {
      logPrint('💰 ExpenseService: Failed to get statistics: $e');
      return {};
    }
  }
}


