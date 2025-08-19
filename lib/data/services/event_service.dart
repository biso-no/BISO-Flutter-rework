import 'package:appwrite/appwrite.dart';
import 'dart:convert';

import '../../core/constants/app_constants.dart';
import '../models/event_model.dart';
import 'appwrite_service.dart';

class EventService {
  Databases get _databases => databases;

  // Get events from WordPress API (external events)
  Future<List<EventModel>> getWordPressEvents({
    String? campusId,
    int limit = AppConstants.defaultPageSize,
    int offset = 0,
  }) async {
    // Backwards-compatible wrapper over Appwrite Function-based fetch
    return getFunctionEvents(campusId: campusId, limit: limit, offset: offset);
  }

  // Get events via Appwrite Function which fetches from WordPress
  Future<List<EventModel>> getFunctionEvents({
    String? campusId,
    int limit = AppConstants.defaultPageSize,
    int offset = 0,
  }) async {
    try {
      final requestBody = {
        'campusId': campusId,
        'per_page': limit,
      };

      final execution = await functions.createExecution(
        functionId: AppConstants.fnFetchEventsId,
        body: json.encode(requestBody),
      );

      if (execution.responseStatusCode == 200) {
        final Map<String, dynamic> payload = json.decode(
          execution.responseBody,
        );
        final List<dynamic> events =
            (payload['events'] as List<dynamic>? ?? <dynamic>[]);
        final models = events
            .map((e) => EventModel.fromFunctionEvent(e as Map<String, dynamic>))
            .toList();

        // Sort by start date ascending and apply limit/offset locally
        models.sort((a, b) => a.startDate.compareTo(b.startDate));
        final start = offset < models.length ? offset : models.length;
        final end = (start + limit) < models.length
            ? (start + limit)
            : models.length;
        return models.sublist(start, end);
      } else {
        throw EventException(
          'Failed to fetch events (function): HTTP ${execution.responseStatusCode}',
        );
      }
    } catch (e) {
      throw EventException('Error fetching events via function: $e');
    }
  }

  // Get events from Appwrite database (internal events)
  Future<List<EventModel>> getAppwriteEvents({
    String? campusId,
    String? category,
    String? status,
    int limit = AppConstants.defaultPageSize,
    int offset = 0,
  }) async {
    try {
      List<String> queries = [
        Query.limit(limit),
        Query.offset(offset),
        Query.orderDesc('\$createdAt'),
      ];

      if (campusId != null) {
        queries.add(Query.equal('campus_id', campusId));
      }

      if (category != null) {
        queries.add(Query.contains('categories', category));
      }

      if (status != null) {
        queries.add(Query.equal('status', status));
      }

      final response = await _databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: 'events',
        queries: queries,
      );

      return response.documents
          .map((doc) => EventModel.fromMap(doc.data))
          .toList();
    } on AppwriteException catch (e) {
      throw EventException('Failed to fetch events: ${e.message}');
    } catch (e) {
      throw EventException('Network error occurred');
    }
  }

  // Get all events (combined WordPress + Appwrite)
  Future<List<EventModel>> getAllEvents({
    String? campusId,
    String? category,
    String? status,
    int limit = AppConstants.defaultPageSize,
    int offset = 0,
  }) async {
    // Since we don't use Appwrite events collection, rely solely on WordPress
    return getWordPressEvents(
      campusId: campusId,
      limit: limit,
      offset: offset,
    );
  }

  // Get single event by ID
  Future<EventModel?> getEventById(String eventId) async {
    try {
      final doc = await _databases.getDocument(
        databaseId: AppConstants.databaseId,
        collectionId: 'events',
        documentId: eventId,
      );

      return EventModel.fromMap(doc.data);
    } on AppwriteException catch (e) {
      if (e.code == 404) return null;
      throw EventException('Failed to fetch event: ${e.message}');
    } catch (e) {
      throw EventException('Network error occurred');
    }
  }

  // Create new event (admin/organizer function)
  Future<EventModel> createEvent(EventModel event) async {
    try {
      final doc = await _databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: 'events',
        documentId: ID.unique(),
        data: event.toMap(),
      );

      return EventModel.fromMap(doc.data);
    } on AppwriteException catch (e) {
      throw EventException('Failed to create event: ${e.message}');
    } catch (e) {
      throw EventException('Network error occurred');
    }
  }

  // Update event
  Future<EventModel> updateEvent(EventModel event) async {
    try {
      final doc = await _databases.updateDocument(
        databaseId: AppConstants.databaseId,
        collectionId: 'events',
        documentId: event.id,
        data: event.toMap(),
      );

      return EventModel.fromMap(doc.data);
    } on AppwriteException catch (e) {
      throw EventException('Failed to update event: ${e.message}');
    } catch (e) {
      throw EventException('Network error occurred');
    }
  }

  // Register for event (if registration is required)
  Future<void> registerForEvent(String eventId, String userId) async {
    try {
      await _databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: 'event_registrations',
        documentId: ID.unique(),
        data: {
          'event_id': eventId,
          'user_id': userId,
          'registration_date': DateTime.now().toIso8601String(),
          'status': 'confirmed',
        },
      );

      // Update event attendee count
      final event = await getEventById(eventId);
      if (event != null) {
        await updateEvent(
          event.copyWith(currentAttendees: event.currentAttendees + 1),
        );
      }
    } on AppwriteException catch (e) {
      throw EventException('Failed to register for event: ${e.message}');
    } catch (e) {
      throw EventException('Network error occurred');
    }
  }

  // Cancel event registration
  Future<void> cancelEventRegistration(String eventId, String userId) async {
    try {
      final response = await _databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: 'event_registrations',
        queries: [
          Query.equal('event_id', eventId),
          Query.equal('user_id', userId),
        ],
      );

      if (response.documents.isNotEmpty) {
        await _databases.deleteDocument(
          databaseId: AppConstants.databaseId,
          collectionId: 'event_registrations',
          documentId: response.documents.first.$id,
        );

        // Update event attendee count
        final event = await getEventById(eventId);
        if (event != null) {
          await updateEvent(
            event.copyWith(
              currentAttendees: (event.currentAttendees - 1)
                  .clamp(0, double.infinity)
                  .toInt(),
            ),
          );
        }
      }
    } on AppwriteException catch (e) {
      throw EventException('Failed to cancel registration: ${e.message}');
    } catch (e) {
      throw EventException('Network error occurred');
    }
  }

  // Check if user is registered for event
  Future<bool> isUserRegistered(String eventId, String userId) async {
    try {
      final response = await _databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: 'event_registrations',
        queries: [
          Query.equal('event_id', eventId),
          Query.equal('user_id', userId),
        ],
      );

      return response.documents.isNotEmpty;
    } on AppwriteException catch (e) {
      throw EventException('Failed to check registration: ${e.message}');
    } catch (e) {
      throw EventException('Network error occurred');
    }
  }

  // Search events
  Future<List<EventModel>> searchEvents({
    required String query,
    String? campusId,
    String? category,
    int limit = AppConstants.defaultPageSize,
  }) async {
    try {
      List<String> queries = [
        Query.search('title', query),
        Query.limit(limit),
        Query.orderDesc('\$createdAt'),
      ];

      if (campusId != null) {
        queries.add(Query.equal('campus_id', campusId));
      }

      if (category != null) {
        queries.add(Query.contains('categories', category));
      }

      final response = await _databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: 'events',
        queries: queries,
      );

      return response.documents
          .map((doc) => EventModel.fromMap(doc.data))
          .toList();
    } on AppwriteException catch (e) {
      throw EventException('Failed to search events: ${e.message}');
    } catch (e) {
      throw EventException('Network error occurred');
    }
  }
}

class EventException implements Exception {
  final String message;
  EventException(this.message);

  @override
  String toString() => message;
}
