import 'package:appwrite/appwrite.dart';

import '../../core/constants/app_constants.dart';
import '../models/department_model.dart';
import 'robust_document_service.dart';
import '../services/appwrite_service.dart';

class DepartmentService {
  static const String collectionId = AppConstants.departmentsCollectionId;

  Future<List<DepartmentModel>> getActiveDepartmentsForCampus(String campusId) async {
    print('🔍 DepartmentService: Fetching departments for campus $campusId');
    final docs = await databases.listDocuments(
      databaseId: AppConstants.databaseId,
      collectionId: collectionId,
      queries: [
        Query.select(['\$id', 'Name', 'campus_id', 'logo', 'active', 'type', 'description']),
        Query.equal('active', true),
        //Query.equal('campus_id', campusId),
        Query.orderAsc('Name'),
        Query.limit(200),
      ],
    );
    return docs.documents.map((doc) => DepartmentModel.fromMap(doc.data)).toList();
  }

  Future<DepartmentModel?> getDepartmentById(String id) async {
    try {
      final docs = await RobustDocumentService.listDocumentsRobust(
        databaseId: AppConstants.databaseId,
        collectionId: collectionId,
        queries: [
          Query.select(['\$id', 'Name', 'campus_id', 'logo', 'active', 'type', 'description']),
          Query.equal('\$id', id),
          Query.limit(1),
        ],
      );
      if (docs.isEmpty) return null;
      return DepartmentModel.fromMap(docs.first);
    } catch (_) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getDepartmentSocials(String departmentId) async {
    // Collection name assumed to be 'department_socials' per spec
    final docs = await RobustDocumentService.listDocumentsRobust(
      databaseId: AppConstants.databaseId,
      collectionId: 'department_socials',
      queries: [
        Query.select(['platform', 'url']),
        Query.equal('department_id', departmentId),
        Query.limit(10),
      ],
    );
    return docs;
  }
}


