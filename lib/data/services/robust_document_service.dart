import 'package:appwrite/appwrite.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'appwrite_service.dart';

import '../../core/logging/print_migration.dart';
/// Robust document service that uses HTTP-only requests for database operations
/// 
/// This service bypasses the Appwrite SDK for database queries due to known
/// deserialization issues where system fields like $sequence are returned as
/// String instead of int, causing type errors.
/// 
/// Uses direct HTTP calls for better performance and reliability.
/// Other Appwrite modules (auth, storage, etc.) can still use the SDK safely.
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
      logPrint('🛡️ RobustDocumentService: Using cached JWT (expires at $_jwtExpiration)');
      return _cachedJwt;
    }
    
    // JWT expired or doesn't exist, create new one
    try {
      logPrint('🛡️ RobustDocumentService: Creating new JWT token');
      final jwt = await account.createJWT();
      _cachedJwt = jwt.jwt;
      _jwtExpiration = now.add(_jwtDuration);
      logPrint('🛡️ RobustDocumentService: New JWT cached until $_jwtExpiration');
      return _cachedJwt;
    } catch (e) {
      logPrint('🛡️ RobustDocumentService: Failed to create JWT: $e');
      // Clear cache on failure
      _cachedJwt = null;
      _jwtExpiration = null;
      return null;
    }
  }

  /// Clears the JWT cache (call this when user signs out)
  static void clearJwtCache() {
    logPrint('🛡️ RobustDocumentService: Clearing JWT cache');
    _cachedJwt = null;
    _jwtExpiration = null;
  }

  /// Forces refresh of JWT token (useful if current token becomes invalid)
  static Future<String?> refreshJwt() async {
    logPrint('🛡️ RobustDocumentService: Forcing JWT refresh');
    _cachedJwt = null;
    _jwtExpiration = null;
    return await _getCachedJwt();
  }

  /// Returns a session JWT, using cache if available
  static Future<String?> getSessionJwt() async {
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
    logPrint('🛡️ RobustDocumentService: Using HTTP-only fetch for document $documentId');
    
    return await _getDocumentViaHttp(
      databaseId: databaseId,
      collectionId: collectionId,
      documentId: documentId,
    );
  }

  /// Creates a document with robust error handling
  static Future<Map<String, dynamic>> createDocumentRobust({
    required String databaseId,
    required String collectionId,
    required Map<String, dynamic> data,
    String? documentId,
    List<String>? permissions,
  }) async {
    try {
      logPrint('🛡️ RobustDocumentService: Using robust create for collection $collectionId');
      final doc = await databases.createDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: documentId ?? ID.unique(),
        data: data,
        permissions: permissions,
      );
      logPrint('🛡️ RobustDocumentService: SDK create successful');
      final map = Map<String, dynamic>.from(doc.data);
      map['\$id'] = doc.$id;
      return map;
    } catch (e) {
      if (e.toString().contains("is not a subtype of type 'int'") ||
          e.toString().contains('is not a subtype of type')) {
        logPrint('🛡️ RobustDocumentService: SDK failed on create, using HTTP fallback');
        logPrint('🛡️ RobustDocumentService: Error was: $e');
        return await _createDocumentViaHttp(
          databaseId: databaseId,
          collectionId: collectionId,
          data: data,
          documentId: documentId,
          permissions: permissions,
        );
      } else {
        rethrow;
      }
    }
  }

  /// Updates a document with robust error handling
  static Future<Map<String, dynamic>> updateDocumentRobust({
    required String databaseId,
    required String collectionId,
    required String documentId,
    required Map<String, dynamic> data,
    List<String>? permissions,
  }) async {
    try {
      logPrint('🛡️ RobustDocumentService: Using robust update for document $documentId');
      final doc = await databases.updateDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: documentId,
        data: data,
        permissions: permissions,
      );
      logPrint('🛡️ RobustDocumentService: SDK update successful');
      final map = Map<String, dynamic>.from(doc.data);
      map['\$id'] = doc.$id;
      return map;
    } catch (e) {
      if (e.toString().contains("is not a subtype of type 'int'") ||
          e.toString().contains('is not a subtype of type')) {
        logPrint('🛡️ RobustDocumentService: SDK failed on update, using HTTP fallback');
        logPrint('🛡️ RobustDocumentService: Error was: $e');
        return await _updateDocumentViaHttp(
          databaseId: databaseId,
          collectionId: collectionId,
          documentId: documentId,
          data: data,
          permissions: permissions,
        );
      } else {
        rethrow;
      }
    }
  }

  /// Deletes a document with robust error handling
  static Future<void> deleteDocumentRobust({
    required String databaseId,
    required String collectionId,
    required String documentId,
  }) async {
    try {
      logPrint('🛡️ RobustDocumentService: Using robust delete for document $documentId');
      await databases.deleteDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: documentId,
      );
      logPrint('🛡️ RobustDocumentService: SDK delete successful');
    } catch (e) {
      if (e.toString().contains("is not a subtype of type 'int'") ||
          e.toString().contains('is not a subtype of type')) {
        logPrint('🛡️ RobustDocumentService: SDK failed on delete, using HTTP fallback');
        logPrint('🛡️ RobustDocumentService: Error was: $e');
        await _deleteDocumentViaHttp(
          databaseId: databaseId,
          collectionId: collectionId,
          documentId: documentId,
        );
      } else {
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
      
      logPrint('🛡️ RobustDocumentService: Making HTTP request to: $url');
      
      final response = await http.get(Uri.parse(url), headers: headers);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        logPrint('🛡️ RobustDocumentService: HTTP fetch successful');
        
        // Clean up system fields that might cause issues
        final cleanedData = _cleanSystemFields(data);
        return cleanedData;
        
      } else {
        logPrint('🛡️ RobustDocumentService: HTTP request failed with status: ${response.statusCode}');
        logPrint('🛡️ RobustDocumentService: Response body: ${response.body}');
        throw AppwriteException('HTTP request failed: ${response.statusCode}');
      }
      
    } catch (e) {
      logPrint('🛡️ RobustDocumentService: HTTP fallback failed: $e');
      rethrow;
    }
  }

  /// Creates document via direct HTTP call (public method)
  static Future<Map<String, dynamic>> createDocumentViaHttpDirect({
    required String databaseId,
    required String collectionId,
    required String documentId,
    required Map<String, dynamic> data,
    List<String>? permissions,
  }) async {
    return await _createDocumentViaHttp(
      databaseId: databaseId,
      collectionId: collectionId,
      data: data,
      documentId: documentId,
      permissions: permissions,
    );
  }

  /// Creates document via direct HTTP call (private)
  static Future<Map<String, dynamic>> _createDocumentViaHttp({
    required String databaseId,
    required String collectionId,
    required Map<String, dynamic> data,
    String? documentId,
    List<String>? permissions,
  }) async {
    try {
      final endpoint = client.endPoint;
      final projectId = client.config['project'];
      final sessionToken = await _getCachedJwt();
      final url = '$endpoint/databases/$databaseId/collections/$collectionId/documents';
      final headers = <String, String>{
        'content-type': 'application/json',
        'X-Appwrite-Project': projectId ?? '',
      };
      if (sessionToken != null) {
        headers['X-Appwrite-JWT'] = sessionToken;
      }
      final body = <String, dynamic>{
        'documentId': documentId ?? 'unique()',
        'data': data,
        if (permissions != null) 'permissions': permissions,
      };
      logPrint('🛡️ RobustDocumentService: Making HTTP create request to: $url');
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );
      if (response.statusCode == 201) {
        final created = json.decode(response.body) as Map<String, dynamic>;
        logPrint('🛡️ RobustDocumentService: HTTP create successful');
        return _cleanSystemFields(created);
      } else {
        logPrint('🛡️ RobustDocumentService: HTTP create failed with status: ${response.statusCode}');
        logPrint('🛡️ RobustDocumentService: Response body: ${response.body}');
        throw AppwriteException('HTTP create request failed: ${response.statusCode}');
      }
    } catch (e) {
      logPrint('🛡️ RobustDocumentService: HTTP create fallback failed: $e');
      rethrow;
    }
  }

  /// Updates document via direct HTTP call
  static Future<Map<String, dynamic>> _updateDocumentViaHttp({
    required String databaseId,
    required String collectionId,
    required String documentId,
    required Map<String, dynamic> data,
    List<String>? permissions,
  }) async {
    try {
      final endpoint = client.endPoint;
      final projectId = client.config['project'];
      final sessionToken = await _getCachedJwt();
      final url = '$endpoint/databases/$databaseId/collections/$collectionId/documents/$documentId';
      final headers = <String, String>{
        'content-type': 'application/json',
        'X-Appwrite-Project': projectId ?? '',
      };
      if (sessionToken != null) {
        headers['X-Appwrite-JWT'] = sessionToken;
      }
      final body = <String, dynamic>{
        'data': data,
        if (permissions != null) 'permissions': permissions,
      };
      logPrint('🛡️ RobustDocumentService: Making HTTP update request to: $url');
      final response = await http.patch(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );
      if (response.statusCode == 200) {
        final updated = json.decode(response.body) as Map<String, dynamic>;
        logPrint('🛡️ RobustDocumentService: HTTP update successful');
        return _cleanSystemFields(updated);
      } else {
        logPrint('🛡️ RobustDocumentService: HTTP update failed with status: ${response.statusCode}');
        logPrint('🛡️ RobustDocumentService: Response body: ${response.body}');
        throw AppwriteException('HTTP update request failed: ${response.statusCode}');
      }
    } catch (e) {
      logPrint('🛡️ RobustDocumentService: HTTP update fallback failed: $e');
      rethrow;
    }
  }

  /// Deletes document via direct HTTP call
  static Future<void> _deleteDocumentViaHttp({
    required String databaseId,
    required String collectionId,
    required String documentId,
  }) async {
    try {
      final endpoint = client.endPoint;
      final projectId = client.config['project'];
      final sessionToken = await _getCachedJwt();
      final url = '$endpoint/databases/$databaseId/collections/$collectionId/documents/$documentId';
      final headers = <String, String>{
        'content-type': 'application/json',
        'X-Appwrite-Project': projectId ?? '',
      };
      if (sessionToken != null) {
        headers['X-Appwrite-JWT'] = sessionToken;
      }
      logPrint('🛡️ RobustDocumentService: Making HTTP delete request to: $url');
      final response = await http.delete(Uri.parse(url), headers: headers);
      if (response.statusCode == 204) {
        logPrint('🛡️ RobustDocumentService: HTTP delete successful');
        return;
      } else {
        logPrint('🛡️ RobustDocumentService: HTTP delete failed with status: ${response.statusCode}');
        logPrint('🛡️ RobustDocumentService: Response body: ${response.body}');
        throw AppwriteException('HTTP delete request failed: ${response.statusCode}');
      }
    } catch (e) {
      logPrint('🛡️ RobustDocumentService: HTTP delete fallback failed: $e');
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
        logPrint('🛡️ RobustDocumentService: Fixed \$sequence field from String to int');
      } catch (e) {
        // If parsing fails, remove the field entirely
        cleaned.remove('\$sequence');
        logPrint('🛡️ RobustDocumentService: Removed problematic \$sequence field');
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
          logPrint('🛡️ RobustDocumentService: Fixed $field field from String to int');
        } catch (e) {
          // If parsing fails, leave as string or remove
          logPrint('🛡️ RobustDocumentService: Could not fix $field field: $e');
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
    logPrint('🛡️ RobustDocumentService: Using HTTP-only list for collection $collectionId');
    
    return await _listDocumentsViaHttp(
      databaseId: databaseId,
      collectionId: collectionId,
      queries: queries,
    );
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
      
      logPrint('🛡️ RobustDocumentService: Making HTTP list request to: $url');
      
      final response = await http.get(Uri.parse(url), headers: headers);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final documents = data['documents'] as List<dynamic>;
        
        logPrint('🛡️ RobustDocumentService: HTTP list successful, found ${documents.length} documents');
        
        // Clean up system fields for each document
        return documents
            .cast<Map<String, dynamic>>()
            .map((doc) => _cleanSystemFields(doc))
            .toList();
            
      } else {
        logPrint('🛡️ RobustDocumentService: HTTP list failed with status: ${response.statusCode}');
        throw AppwriteException('HTTP list request failed: ${response.statusCode}');
      }
      
    } catch (e) {
      logPrint('🛡️ RobustDocumentService: HTTP list fallback failed: $e');
      rethrow;
    }
  }
}