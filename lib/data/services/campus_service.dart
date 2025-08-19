import 'package:appwrite/appwrite.dart';

import '../../core/constants/app_constants.dart';
import '../models/campus_model.dart';
import 'appwrite_service.dart';

class CampusService {
  static const String collectionId = AppConstants.campusesCollectionId;

  Future<List<CampusModel>> getAllCampuses() async {
    try {
      final results = await databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: collectionId,
        queries: [
          Query.orderAsc('name'),
          Query.select(['\$id', 'name']),
        ],
      );

      final campuses = results.documents.map((doc) {
        return CampusModel.fromMap(doc.data);
      }).toList();

      return campuses;
    } catch (e) {
      // Fallback to static data if Appwrite fails
      return CampusData.campuses;
    }
  }

  Future<CampusModel?> getCampusById(String campusId) async {
    try {
      final document = await databases.getDocument(
        databaseId: AppConstants.databaseId,
        collectionId: collectionId,
        documentId: campusId,
      );

      return CampusModel.fromMap(document.data);
    } catch (e) {
      // Fallback to static data
      return CampusData.getCampusById(campusId);
    }
  }
}
