import 'package:appwrite/appwrite.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'appwrite_service.dart';

/// Robust document service to handle Appwrite SDK deserialization issues
/// 
/// This service provides a workaround for the known issue where Appwrite SDK
/// fails to deserialize documents when system fields like $sequence are 
/// returned as String instead of int from the API.
/// 
/// TEMPORARY WORKAROUND - Can be removed once Appwrite SDK fixes the issue:
/// https://github.com/appwrite/sdk-for-dart/issues/261
class RobustDocumentService {
  // JWT cache with 15-minute expiration
  static String? _cachedJwt;
  static DateTime? _jwtExpiration;
  static const Duration _jwtDuration = Duration(minutes: 14); // Use 14 mins to be safe

  /// Gets cached JWT or creates a new one if expired/missing
  static Future<String?> _getCachedJwt() async {
    final now = DateTime.now();
    
    // Check if cached JWT is still valid
    if (_cachedJwt != null && 
        _jwtExpiration != null && 
        now.isBefore(_jwtExpiration!)) {
      print('🛡️ RobustDocumentService: Using cached JWT (expires at $_jwtExpiration)');
      return _cachedJwt;
    }
    
    // JWT expired or doesn't exist, create new one
    try {
      print('🛡️ RobustDocumentService: Creating new JWT token');
      final jwt = await account.createJWT();
      _cachedJwt = jwt.jwt;
      _jwtExpiration = now.add(_jwtDuration);
      print('🛡️ RobustDocumentService: New JWT cached until $_jwtExpiration');
      return _cachedJwt;
    } catch (e) {
      print('🛡️ RobustDocumentService: Failed to create JWT: $e');
      // Clear cache on failure
      _cachedJwt = null;
      _jwtExpiration = null;
      return null;
    }
  }

  /// Clears the JWT cache (call this when user signs out)
  static void clearJwtCache() {
    print('🛡️ RobustDocumentService: Clearing JWT cache');
    _cachedJwt = null;
    _jwtExpiration = null;
  }

  /// Forces refresh of JWT token (useful if current token becomes invalid)
  static Future<String?> refreshJwt() async {
    print('🛡️ RobustDocumentService: Forcing JWT refresh');
    _cachedJwt = null;
    _jwtExpiration = null;
    return await _getCachedJwt();
  }

  /// Checks if we have a valid cached JWT
  static bool hasValidJwt() {
    final now = DateTime.now();
    return _cachedJwt != null && 
           _jwtExpiration != null && 
           now.isBefore(_jwtExpiration!);
  }

  /// Fetches a document using direct HTTP call to bypass SDK deserialization issues
  static Future<Map<String, dynamic>> getDocumentRobust({
    required String databaseId,
    required String collectionId,
    required String documentId,
  }) async {
    try {
      print('🛡️ RobustDocumentService: Using robust fetch for document $documentId');
      
      // First try the normal SDK method
      final document = await databases.getDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: documentId,
      );
      
      print('🛡️ RobustDocumentService: SDK fetch successful');
      return document.data;
      
    } catch (e) {
      // If SDK fails with type error, use HTTP fallback
      if (e.toString().contains("is not a subtype of type 'int'") ||
          e.toString().contains("is not a subtype of type")) {
        
        print('🛡️ RobustDocumentService: SDK failed with type error, using HTTP fallback');
        print('🛡️ RobustDocumentService: Error was: $e');
        
        return await _getDocumentViaHttp(
          databaseId: databaseId,
          collectionId: collectionId,
          documentId: documentId,
        );
      } else {
        // Re-throw other errors
        rethrow;
      }
    }
  }

  /// Fetches document via direct HTTP call
  static Future<Map<String, dynamic>> _getDocumentViaHttp({
    required String databaseId,
    required String collectionId,
    required String documentId,
  }) async {
    try {
      final endpoint = client.endPoint;
      final projectId = client.config['project'];
      
      // Get cached JWT token
      final sessionToken = await _getCachedJwt();
      
      final url = '$endpoint/databases/$databaseId/collections/$collectionId/documents/$documentId';
      
      final headers = <String, String>{
        'content-type': 'application/json',
        'X-Appwrite-Project': projectId ?? '',
      };
      
      // Add session token if available
      if (sessionToken != null) {
        headers['X-Appwrite-JWT'] = sessionToken;
      }
      
      print('🛡️ RobustDocumentService: Making HTTP request to: $url');
      
      final response = await http.get(Uri.parse(url), headers: headers);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        print('🛡️ RobustDocumentService: HTTP fetch successful');
        
        // Clean up system fields that might cause issues
        final cleanedData = _cleanSystemFields(data);
        return cleanedData;
        
      } else {
        print('🛡️ RobustDocumentService: HTTP request failed with status: ${response.statusCode}');
        print('🛡️ RobustDocumentService: Response body: ${response.body}');
        throw AppwriteException('HTTP request failed: ${response.statusCode}');
      }
      
    } catch (e) {
      print('🛡️ RobustDocumentService: HTTP fallback failed: $e');
      rethrow;
    }
  }

  /// Cleans problematic system fields from document data
  static Map<String, dynamic> _cleanSystemFields(Map<String, dynamic> data) {
    final cleaned = Map<String, dynamic>.from(data);
    
    // Fix $sequence field if it's a String
    if (cleaned['\$sequence'] is String) {
      try {
        cleaned['\$sequence'] = int.parse(cleaned['\$sequence']);
        print('🛡️ RobustDocumentService: Fixed \$sequence field from String to int');
      } catch (e) {
        // If parsing fails, remove the field entirely
        cleaned.remove('\$sequence');
        print('🛡️ RobustDocumentService: Removed problematic \$sequence field');
      }
    }
    
    // Fix other potential numeric fields that might be strings
    final numericFields = ['\$internalId', '\$permissions'];
    for (final field in numericFields) {
      if (cleaned[field] is String) {
        try {
          if (field == '\$internalId') {
            cleaned[field] = int.parse(cleaned[field]);
          }
          print('🛡️ RobustDocumentService: Fixed $field field from String to int');
        } catch (e) {
          // If parsing fails, leave as string or remove
          print('🛡️ RobustDocumentService: Could not fix $field field: $e');
        }
      }
    }
    
    return cleaned;
  }

  /// Lists documents with robust error handling
  static Future<List<Map<String, dynamic>>> listDocumentsRobust({
    required String databaseId,
    required String collectionId,
    List<String> queries = const [],
  }) async {
    try {
      print('🛡️ RobustDocumentService: Using robust list for collection $collectionId');
      
      // First try the normal SDK method
      final response = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: collectionId,
        queries: queries,
      );
      
      print('🛡️ RobustDocumentService: SDK list successful');
      return response.documents.map((doc) => doc.data).toList();
      
    } catch (e) {
      // If SDK fails with type error, use HTTP fallback
      if (e.toString().contains("is not a subtype of type 'int'") ||
          e.toString().contains("is not a subtype of type")) {
        
        print('🛡️ RobustDocumentService: SDK failed with type error, using HTTP fallback for list');
        print('🛡️ RobustDocumentService: Error was: $e');
        
        return await _listDocumentsViaHttp(
          databaseId: databaseId,
          collectionId: collectionId,
          queries: queries,
        );
      } else {
        // Re-throw other errors
        rethrow;
      }
    }
  }

  /// Lists documents via direct HTTP call
  static Future<List<Map<String, dynamic>>> _listDocumentsViaHttp({
    required String databaseId,
    required String collectionId,
    List<String> queries = const [],
  }) async {
    try {
      final endpoint = client.endPoint;
      final projectId = client.config['project'];
      
      // Get cached JWT token
      final sessionToken = await _getCachedJwt();
      
      var url = '$endpoint/databases/$databaseId/collections/$collectionId/documents';
      
      // Add query parameters
      if (queries.isNotEmpty) {
        final queryParams = queries.map((q) => 'queries[]=${Uri.encodeComponent(q)}').join('&');
        url += '?$queryParams';
      }
      
      final headers = <String, String>{
        'content-type': 'application/json',
        'X-Appwrite-Project': projectId ?? '',
      };
      
      if (sessionToken != null) {
        headers['X-Appwrite-JWT'] = sessionToken;
      }
      
      print('🛡️ RobustDocumentService: Making HTTP list request to: $url');
      
      final response = await http.get(Uri.parse(url), headers: headers);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final documents = data['documents'] as List<dynamic>;
        
        print('🛡️ RobustDocumentService: HTTP list successful, found ${documents.length} documents');
        
        // Clean up system fields for each document
        return documents
            .cast<Map<String, dynamic>>()
            .map((doc) => _cleanSystemFields(doc))
            .toList();
            
      } else {
        print('🛡️ RobustDocumentService: HTTP list failed with status: ${response.statusCode}');
        throw AppwriteException('HTTP list request failed: ${response.statusCode}');
      }
      
    } catch (e) {
      print('🛡️ RobustDocumentService: HTTP list fallback failed: $e');
      rethrow;
    }
  }
}