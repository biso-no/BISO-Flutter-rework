import 'package:equatable/equatable.dart';

class EventModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime? endDate;
  final String venue;
  final String? location;
  final String organizerId;
  final String organizerName;
  final String? organizerLogo;
  final String campusId;
  final List<String> categories;
  final List<String> images;
  final int maxAttendees;
  final int currentAttendees;
  final bool isPublic;
  final bool requiresRegistration;
  final double? price;
  final String? registrationUrl;
  final DateTime? registrationDeadline;
  final String status; // 'upcoming', 'ongoing', 'completed', 'cancelled'
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    this.endDate,
    required this.venue,
    this.location,
    required this.organizerId,
    required this.organizerName,
    this.organizerLogo,
    required this.campusId,
    this.categories = const [],
    this.images = const [],
    this.maxAttendees = 0,
    this.currentAttendees = 0,
    this.isPublic = true,
    this.requiresRegistration = false,
    this.price,
    this.registrationUrl,
    this.registrationDeadline,
    this.status = 'upcoming',
    this.createdAt,
    this.updatedAt,
  });

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['\$id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      startDate: DateTime.parse(map['start_date']),
      endDate: map['end_date'] != null ? DateTime.parse(map['end_date']) : null,
      venue: map['venue'] ?? '',
      location: map['location'],
      organizerId: map['organizer_id'] ?? '',
      organizerName: map['organizer_name'] ?? '',
      organizerLogo: map['organizer_logo'],
      campusId: map['campus_id'] ?? '',
      categories: List<String>.from(map['categories'] ?? []),
      images: List<String>.from(map['images'] ?? []),
      maxAttendees: map['max_attendees'] ?? 0,
      currentAttendees: map['current_attendees'] ?? 0,
      isPublic: map['is_public'] ?? true,
      requiresRegistration: map['requires_registration'] ?? false,
      price: map['price']?.toDouble(),
      registrationUrl: map['registration_url'],
      registrationDeadline: map['registration_deadline'] != null 
          ? DateTime.parse(map['registration_deadline']) : null,
      status: map['status'] ?? 'upcoming',
      createdAt: map['\$createdAt'] != null ? DateTime.parse(map['\$createdAt']) : null,
      updatedAt: map['\$updatedAt'] != null ? DateTime.parse(map['\$updatedAt']) : null,
    );
  }

  // Factory for WordPress API response
  factory EventModel.fromWordPress(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'].toString(),
      title: map['title']['rendered'] ?? '',
      description: map['content']['rendered'] ?? '',
      startDate: DateTime.parse(map['meta']['start_date'] ?? DateTime.now().toIso8601String()),
      endDate: map['meta']['end_date'] != null ? DateTime.parse(map['meta']['end_date']) : null,
      venue: map['meta']['venue'] ?? '',
      location: map['meta']['location'],
      organizerId: map['meta']['organizer_id'] ?? '',
      organizerName: map['meta']['organizer_name'] ?? '',
      organizerLogo: map['meta']['organizer_logo'],
      campusId: map['meta']['campus_id'] ?? '',
      categories: List<String>.from(map['categories'] ?? []),
      images: List<String>.from(map['meta']['images'] ?? []),
      maxAttendees: int.tryParse(map['meta']['max_attendees']?.toString() ?? '0') ?? 0,
      currentAttendees: int.tryParse(map['meta']['current_attendees']?.toString() ?? '0') ?? 0,
      isPublic: map['meta']['is_public'] == '1' || map['meta']['is_public'] == true,
      requiresRegistration: map['meta']['requires_registration'] == '1' || map['meta']['requires_registration'] == true,
      price: map['meta']['price'] != null ? double.tryParse(map['meta']['price'].toString()) : null,
      registrationUrl: map['meta']['registration_url'],
      registrationDeadline: map['meta']['registration_deadline'] != null 
          ? DateTime.parse(map['meta']['registration_deadline']) : null,
      status: map['meta']['status'] ?? 'upcoming',
      createdAt: DateTime.parse(map['date']),
      updatedAt: DateTime.parse(map['modified']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'venue': venue,
      'location': location,
      'organizer_id': organizerId,
      'organizer_name': organizerName,
      'organizer_logo': organizerLogo,
      'campus_id': campusId,
      'categories': categories,
      'images': images,
      'max_attendees': maxAttendees,
      'current_attendees': currentAttendees,
      'is_public': isPublic,
      'requires_registration': requiresRegistration,
      'price': price,
      'registration_url': registrationUrl,
      'registration_deadline': registrationDeadline?.toIso8601String(),
      'status': status,
    };
  }

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? venue,
    String? location,
    String? organizerId,
    String? organizerName,
    String? organizerLogo,
    String? campusId,
    List<String>? categories,
    List<String>? images,
    int? maxAttendees,
    int? currentAttendees,
    bool? isPublic,
    bool? requiresRegistration,
    double? price,
    String? registrationUrl,
    DateTime? registrationDeadline,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      venue: venue ?? this.venue,
      location: location ?? this.location,
      organizerId: organizerId ?? this.organizerId,
      organizerName: organizerName ?? this.organizerName,
      organizerLogo: organizerLogo ?? this.organizerLogo,
      campusId: campusId ?? this.campusId,
      categories: categories ?? this.categories,
      images: images ?? this.images,
      maxAttendees: maxAttendees ?? this.maxAttendees,
      currentAttendees: currentAttendees ?? this.currentAttendees,
      isPublic: isPublic ?? this.isPublic,
      requiresRegistration: requiresRegistration ?? this.requiresRegistration,
      price: price ?? this.price,
      registrationUrl: registrationUrl ?? this.registrationUrl,
      registrationDeadline: registrationDeadline ?? this.registrationDeadline,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isUpcoming => status == 'upcoming';
  bool get isOngoing => status == 'ongoing';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  bool get isFull => maxAttendees > 0 && currentAttendees >= maxAttendees;
  bool get canRegister => isUpcoming && !isFull && (registrationDeadline?.isAfter(DateTime.now()) ?? true);

  @override
  List<Object?> get props => [
    id, title, description, startDate, endDate, venue, location,
    organizerId, organizerName, organizerLogo, campusId, categories,
    images, maxAttendees, currentAttendees, isPublic, requiresRegistration,
    price, registrationUrl, registrationDeadline, status, createdAt, updatedAt,
  ];
}