import 'dart:convert';
import 'package:appwrite/appwrite.dart';

import '../../core/constants/app_constants.dart';
import '../models/job_model.dart';
import 'robust_document_service.dart';
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
			print('🔄 JobService: Fetching jobs for campus: $campusId');
			final execution = await functions.createExecution(
				functionId: AppConstants.fnFetchJobsId,
        xasync: false,
				body: json.encode({
					'campusId': campusId,
				}),
			);
			
			print('📡 JobService: Function execution status: ${execution.responseStatusCode}');
			print('📄 JobService: Function response body: ${execution.responseBody}');
			
			if (execution.responseStatusCode == 200) {
				final Map<String, dynamic> payload = json.decode(execution.responseBody);
				final List<dynamic> jobs = (payload['jobs'] as List<dynamic>? ?? <dynamic>[]);
				
				print('📊 JobService: Found ${jobs.length} jobs in response');
				if (jobs.isNotEmpty) {
					print('📝 JobService: First job sample: ${jobs.first}');
				}
				
				final models = jobs
						.map((j) => JobModel.fromFunctionJob(j as Map<String, dynamic>, campusId: campusId ?? ''))
						.toList(growable: false);
				
				print('✅ JobService: Successfully parsed ${models.length} job models');
				return models.take(limit).toList(growable: false);
			} else {
				print('❌ JobService: Function execution failed with status: ${execution.responseStatusCode}');
			}
		} catch (e) {
			print('❌ JobService: Exception during function execution: $e');
			// Fallback to internal DB if function fails
		}

		print('🔄 JobService: Falling back to internal database');
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
		
		print('📊 JobService: Found ${results.length} jobs in internal database');
		return results.map(JobModel.fromMap).toList(growable: false);
	}
}


