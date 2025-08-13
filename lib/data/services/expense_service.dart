import 'dart:io';
import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as aw_models;
import 'package:http/http.dart' as http;

import '../../core/constants/app_constants.dart';
import 'appwrite_service.dart';
import 'robust_document_service.dart';

class ExpenseService {
  static const String expensesCollectionId = AppConstants.expensesCollectionId;
  static const String attachmentsCollectionId = AppConstants.expenseAttachmentsCollectionId;

  Future<Map<String, dynamic>> createExpenseDocument({
    required Map<String, dynamic> data,
  }) async {
    final doc = await databases.createDocument(
      databaseId: AppConstants.databaseId,
      collectionId: expensesCollectionId,
      documentId: ID.unique(),
      data: data,
    );
    final map = Map<String, dynamic>.from(doc.data);
    map['\$id'] = doc.$id;
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
    final doc = await databases.createDocument(
      databaseId: AppConstants.databaseId,
      collectionId: attachmentsCollectionId,
      documentId: ID.unique(),
      data: {
        'date': date.toIso8601String(),
        'url': url,
        'amount': amount,
        'description': description,
        'type': type,
      },
    );
    final map = Map<String, dynamic>.from(doc.data);
    map['\$id'] = doc.$id;
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
    final jwt = await account.createJWT();
    final url = '$endpoint/functions/${AppConstants.fnParseReceiptId}/executions';
    final res = await http.post(
      Uri.parse(url),
      headers: {
        'content-type': 'application/json',
        'X-Appwrite-Project': projectId ?? '',
        'X-Appwrite-JWT': jwt.jwt,
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
    final jwt = await account.createJWT();
    final url = '$endpoint/functions/${AppConstants.fnSummarizeExpenseId}/executions';
    final payload = {'descriptions': descriptions};
    final res = await http.post(
      Uri.parse(url),
      headers: {
        'content-type': 'application/json',
        'X-Appwrite-Project': projectId ?? '',
        'X-Appwrite-JWT': jwt.jwt,
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
}


