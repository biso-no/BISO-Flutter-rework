import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';

import '../../core/constants/app_constants.dart';
import '../models/large_event_model.dart';
import 'appwrite_service.dart';
import 'robust_document_service.dart';

class LargeEventService {
  static const String collectionId = 'large_event';

  Future<List<LargeEventModel>> fetchActiveEvents() async {
    try {
      final results = await RobustDocumentService.listDocumentsRobust(
        databaseId: AppConstants.databaseId,
        collectionId: collectionId,
        queries: [
          Query.equal('isActive', true),
          Query.orderDesc('priority'),
        ],
      );

      return results.map(LargeEventModel.fromMap).toList(growable: false);
    } catch (e, st) {
      debugPrint('LargeEventService.fetchActiveEvents error: $e\n$st');
      rethrow;
    }
  }

  Future<LargeEventModel?> fetchEventBySlug(String slug) async {
    try {
      final results = await RobustDocumentService.listDocumentsRobust(
        databaseId: AppConstants.databaseId,
        collectionId: collectionId,
        queries: [Query.equal('slug', slug), Query.limit(1)],
      );
      if (results.isEmpty) return null;
      return LargeEventModel.fromMap(results.first);
    } catch (e, st) {
      debugPrint('LargeEventService.fetchEventBySlug error: $e\n$st');
      rethrow;
    }
  }

  Stream<List<LargeEventModel>> subscribeActiveEvents() {
    final channel =
        'databases.${AppConstants.databaseId}.collections.$collectionId.documents';
    final stream = realtime.subscribe([channel]);
    return stream.stream.asyncMap((message) async {
      // After any change, re-fetch active list
      return await fetchActiveEvents();
    });
  }
}


