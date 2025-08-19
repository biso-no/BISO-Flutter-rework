import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';

import '../../core/constants/app_constants.dart';
import '../models/large_event_model.dart';
import 'robust_document_service.dart';

class LargeEventItemService {
  static const String collectionId = 'large_event_item';

  Future<List<LargeEventScheduleItem>> listItems({
    required String eventId,
    required String campusId,
  }) async {
    try {
      final docs = await RobustDocumentService.listDocumentsRobust(
        databaseId: AppConstants.databaseId,
        collectionId: collectionId,
        queries: [
          Query.equal('eventId', eventId),
          Query.equal('campusId', campusId),
          Query.orderAsc('sort'),
          Query.orderAsc('startTime'),
          Query.limit(200),
        ],
      );
      return docs
          .map((e) => LargeEventScheduleItem.fromMap(e))
          .toList(growable: false);
    } catch (e, st) {
      debugPrint('LargeEventItemService.listItems error: $e\n$st');
      rethrow;
    }
  }
}
