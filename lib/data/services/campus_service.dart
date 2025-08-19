import 'package:appwrite/appwrite.dart';

import '../../core/constants/app_constants.dart';
import '../models/campus_model.dart';
import 'robust_document_service.dart';

class CampusService {
  static const String collectionId = AppConstants.campusesCollectionId;

  Future<List<CampusModel>> getAllCampuses() async {
    try {
      final results = await RobustDocumentService.listDocumentsRobust(
        databaseId: AppConstants.databaseId,
        collectionId: collectionId,
        queries: [
          Query.orderAsc('name'),
          Query.select(['\$id', 'name']),
        ],
      );

      final campuses = results.map((doc) {
        return CampusModel.fromMap(doc);
      }).toList();

      return campuses;
    } catch (e) {
      // Fallback to static data if Appwrite fails
      return CampusData.campuses;
    }
  }

  Future<CampusModel?> getCampusById(String campusId) async {
    try {
      final document = await RobustDocumentService.getDocumentRobust(
        databaseId: AppConstants.databaseId,
        collectionId: collectionId,
        documentId: campusId,
      );

      return CampusModel.fromMap(document);
    } catch (e) {
      // Fallback to static data
      return CampusData.getCampusById(campusId);
    }
  }
}
