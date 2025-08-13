import 'package:appwrite/appwrite.dart';

import '../../core/constants/app_constants.dart';
import '../models/job_model.dart';
import 'robust_document_service.dart';

class JobService {
  static const String collectionId = 'jobs';

  Future<List<JobModel>> getLatestJobs({
    String? campusId,
    String? status = 'open',
    int limit = 10,
  }) async {
    final List<String> queries = [
      Query.orderDesc('\$createdAt'),
      Query.limit(limit),
    ];

    if (campusId != null) {
      queries.add(Query.equal('campus_id', campusId));
    }
    if (status != null) {
      queries.add(Query.equal('status', status));
    }

    final results = await RobustDocumentService.listDocumentsRobust(
      databaseId: AppConstants.databaseId,
      collectionId: collectionId,
      queries: queries,
    );
    return results.map(JobModel.fromMap).toList(growable: false);
  }
}


