import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';

import '../../core/constants/app_constants.dart';
import '../models/large_event_model.dart';
import 'appwrite_service.dart';

class LargeEventService {
  static const String collectionId = 'large_event';

  Future<List<LargeEventModel>> fetchActiveEvents() async {
    try {
      final results = await databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: collectionId,
        queries: [Query.equal('isActive', true), Query.orderDesc('priority')],
      );

      return results.documents.map((doc) => LargeEventModel.fromMap(doc.data)).toList(growable: false);
    } catch (e, st) {
      debugPrint('LargeEventService.fetchActiveEvents error: $e\n$st');
      rethrow;
    }
  }

  Future<LargeEventModel?> fetchEventBySlug(String slug) async {
    try {
      final results = await databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: collectionId,
        queries: [Query.equal('slug', slug), Query.limit(1)],
      );
      if (results.documents.isEmpty) return null;
      return LargeEventModel.fromMap(results.documents.first.data);
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
