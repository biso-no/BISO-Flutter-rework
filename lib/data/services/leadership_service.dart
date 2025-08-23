import 'dart:convert';
import 'package:appwrite/appwrite.dart';
import '../models/board_member_model.dart';
import 'appwrite_service.dart';

class LeadershipService {
  static const String _functionId = 'get_board_members';

  /// Fetches board members for a specific campus
  /// 
  /// [campusId] - The ID of the campus to get board members for
  /// [departmentId] - Optional department ID. If not provided, 
  /// the function will use the default department for the campus
  static Future<BoardMembersResponse> getBoardMembers({
    required String campusId,
    String? departmentId,
  }) async {
    try {
      // Prepare request body
      final requestBody = {
        'campus': campusId,
        if (departmentId != null) 'departmentId': departmentId,
      };

      // Call the Appwrite function
      final execution = await functions.createExecution(
        functionId: _functionId,
        body: jsonEncode(requestBody),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      // Parse the response
      if (execution.responseStatusCode == 200) {
        final responseData = jsonDecode(execution.responseBody);
        return BoardMembersResponse.fromMap(responseData);
      } else {
        // Handle non-200 status codes
        final responseData = jsonDecode(execution.responseBody);
        return BoardMembersResponse(
          success: false,
          members: [],
          count: 0,
          error: responseData['message'] ?? 'Unknown error occurred',
        );
      }
    } on AppwriteException catch (e) {
      // Handle Appwrite-specific errors
      return BoardMembersResponse(
        success: false,
        members: [],
        count: 0,
        error: 'Appwrite error: ${e.message}',
      );
    } catch (e) {
      // Handle any other errors
      return BoardMembersResponse(
        success: false,
        members: [],
        count: 0,
        error: 'Failed to fetch board members: ${e.toString()}',
      );
    }
  }

  /// Fetches board members for all campuses
  static Future<Map<String, BoardMembersResponse>> getAllCampusBoardMembers() async {
    final campusIds = ['1', '2', '3', '4', '5']; // Oslo, Bergen, Trondheim, Stavanger, National
    final results = <String, BoardMembersResponse>{};

    // Fetch board members for each campus
    for (final campusId in campusIds) {
      try {
        final response = await getBoardMembers(campusId: campusId);
        results[campusId] = response;
      } catch (e) {
        // If one campus fails, continue with others
        results[campusId] = BoardMembersResponse(
          success: false,
          members: [],
          count: 0,
          error: 'Failed to fetch members for campus $campusId: ${e.toString()}',
        );
      }
    }

    return results;
  }

  /// Gets the display name for a campus ID
  static String getCampusDisplayName(String campusId) {
    switch (campusId) {
      case '1':
        return 'Oslo';
      case '2':
        return 'Bergen';
      case '3':
        return 'Trondheim';
      case '4':
        return 'Stavanger';
      case '5':
        return 'National';
      default:
        return 'Unknown Campus';
    }
  }

  /// Gets the default department name for a campus
  static String getDefaultDepartmentName(String campusId) {
    switch (campusId) {
      case '1':
        return 'Ledelsen Oslo';
      case '2':
        return 'Ledelsen Bergen';
      case '3':
        return 'Ledelsen Trondheim';
      case '4':
        return 'Ledelsen Stavanger';
      case '5':
        return 'Operations Unit';
      default:
        return 'Campus Management';
    }
  }
}