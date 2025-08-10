import 'package:appwrite/appwrite.dart';
import 'package:http/http.dart' as http;
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
    try {
      String url = AppConstants.wordPressEventsApi;
      final queryParams = <String, String>{
        'per_page': limit.toString(),
        'offset': offset.toString(),
      };
      
      if (campusId != null) {
        queryParams['campus'] = campusId;
      }

      final uri = Uri.parse(url).replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => EventModel.fromWordPress(json)).toList();
      } else {
        throw EventException('Failed to fetch WordPress events: ${response.statusCode}');
      }
    } catch (e) {
      throw EventException('Network error: $e');
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
    try {
      final futures = await Future.wait([
        getWordPressEvents(campusId: campusId, limit: limit ~/ 2, offset: offset),
        getAppwriteEvents(
          campusId: campusId,
          category: category,
          status: status,
          limit: limit ~/ 2,
          offset: offset,
        ),
      ]);

      final allEvents = <EventModel>[];
      allEvents.addAll(futures[0]);
      allEvents.addAll(futures[1]);

      // Sort by start date
      allEvents.sort((a, b) => a.startDate.compareTo(b.startDate));

      return allEvents.take(limit).toList();
    } catch (e) {
      throw EventException('Failed to fetch events: $e');
    }
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
        await updateEvent(event.copyWith(
          currentAttendees: event.currentAttendees + 1,
        ));
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
          await updateEvent(event.copyWith(
            currentAttendees: (event.currentAttendees - 1).clamp(0, double.infinity).toInt(),
          ));
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