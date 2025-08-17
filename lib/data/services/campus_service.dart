import 'package:appwrite/appwrite.dart';

import '../../core/constants/app_constants.dart';
import '../models/campus_model.dart';
import 'robust_document_service.dart';

class CampusService {
  static const String collectionId = AppConstants.campusesCollectionId;

  Future<List<CampusModel>> getAllCampuses() async {
    try {
      print('🏛️ CampusService: Fetching all campuses from Appwrite');
      
      final results = await RobustDocumentService.listDocumentsRobust(
        databaseId: AppConstants.databaseId,
        collectionId: collectionId,
        queries: [
          Query.orderAsc('name'),
        ],
      );
      
      print('🏛️ CampusService: Found ${results.length} campuses in database');
      
      final campuses = results.map((doc) {
        print('📍 Campus document: ${doc['\$id']} - ${doc['name']}');
        return CampusModel.fromMap(doc);
      }).toList();
      
      return campuses;
    } catch (e) {
      print('❌ CampusService: Error fetching campuses: $e');
      // Fallback to static data if Appwrite fails
      print('🔄 CampusService: Falling back to static campus data');
      return CampusData.campuses;
    }
  }

  Future<CampusModel?> getCampusById(String campusId) async {
    try {
      print('🏛️ CampusService: Fetching campus with ID: $campusId');
      
      final document = await RobustDocumentService.getDocumentRobust(
        databaseId: AppConstants.databaseId,
        collectionId: collectionId,
        documentId: campusId,
      );
      
      if (document != null) {
        print('✅ CampusService: Found campus: ${document['name']}');
        return CampusModel.fromMap(document);
      } else {
        print('❌ CampusService: Campus not found with ID: $campusId');
        return null;
      }
    } catch (e) {
      print('❌ CampusService: Error fetching campus $campusId: $e');
      // Fallback to static data
      return CampusData.getCampusById(campusId);
    }
  }
}