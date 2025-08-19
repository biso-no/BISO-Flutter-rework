import 'dart:convert';
import 'package:appwrite/appwrite.dart';

import '../../core/constants/app_constants.dart';
import '../models/job_model.dart';
import 'appwrite_service.dart';

class JobService {
  static const String collectionId = 'jobs';

  Future<List<JobModel>> getLatestJobs({
    String? campusId,
    String? status = 'open',
    int limit = 10,
  }) async {
    // Try Appwrite Function (WordPress-backed)
    try {
      final execution = await functions.createExecution(
        functionId: AppConstants.fnFetchJobsId,
        xasync: false,
        body: json.encode({'campusId': campusId}),
      );

      if (execution.responseStatusCode == 200) {
        final Map<String, dynamic> payload = json.decode(
          execution.responseBody,
        );
        final List<dynamic> jobs =
            (payload['jobs'] as List<dynamic>? ?? <dynamic>[]);

        final models = jobs
            .map(
              (j) => JobModel.fromFunctionJob(
                j as Map<String, dynamic>,
                campusId: campusId ?? '',
              ),
            )
            .toList(growable: false);

        return models.take(limit).toList(growable: false);
      } else {}
    } catch (e) {
      // Fallback to internal DB if function fails
    }

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

    final results = await databases.listDocuments(
      databaseId: AppConstants.databaseId,
      collectionId: collectionId,
      queries: queries,
    );

    return results.documents.map((doc) => JobModel.fromMap(doc.data)).toList(growable: false);
  }
}
