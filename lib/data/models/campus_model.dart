import 'package:equatable/equatable.dart';

class CampusModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final String location;
  final String imageUrl;
  final String heroImageUrl;
  final List<String> benefits;
  final WeatherData? weather;
  final CampusStats stats;
  final Map<String, dynamic> metadata;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CampusModel({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.imageUrl,
    required this.heroImageUrl,
    this.benefits = const [],
    this.weather,
    required this.stats,
    this.metadata = const {},
    this.createdAt,
    this.updatedAt,
  });

  factory CampusModel.fromMap(Map<String, dynamic> map) {
    return CampusModel(
      id: map['\$id'] ?? map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      imageUrl: map['image_url'] ?? '',
      heroImageUrl: map['hero_image_url'] ?? '',
      benefits: List<String>.from(map['benefits'] ?? []),
      weather: map['weather'] != null
          ? WeatherData.fromMap(map['weather'])
          : null,
      stats: CampusStats.fromMap(map['stats'] ?? {}),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
      createdAt: map['\$createdAt'] != null
          ? DateTime.parse(map['\$createdAt'])
          : null,
      updatedAt: map['\$updatedAt'] != null
          ? DateTime.parse(map['\$updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'location': location,
      'image_url': imageUrl,
      'hero_image_url': heroImageUrl,
      'benefits': benefits,
      'weather': weather?.toMap(),
      'stats': stats.toMap(),
      'metadata': metadata,
    };
  }

  CampusModel copyWith({
    String? id,
    String? name,
    String? description,
    String? location,
    String? imageUrl,
    String? heroImageUrl,
    List<String>? benefits,
    WeatherData? weather,
    CampusStats? stats,
    Map<String, dynamic>? metadata,
  }) {
    return CampusModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      heroImageUrl: heroImageUrl ?? this.heroImageUrl,
      benefits: benefits ?? this.benefits,
      weather: weather ?? this.weather,
      stats: stats ?? this.stats,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    location,
    imageUrl,
    heroImageUrl,
    benefits,
    weather,
    stats,
    metadata,
    createdAt,
    updatedAt,
  ];
}

class WeatherData extends Equatable {
  final double temperature;
  final String condition;
  final String icon;
  final int humidity;
  final double windSpeed;

  const WeatherData({
    required this.temperature,
    required this.condition,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
  });

  factory WeatherData.fromMap(Map<String, dynamic> map) {
    return WeatherData(
      temperature: (map['temperature'] ?? 0).toDouble(),
      condition: map['condition'] ?? '',
      icon: map['icon'] ?? '',
      humidity: map['humidity'] ?? 0,
      windSpeed: (map['wind_speed'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'temperature': temperature,
      'condition': condition,
      'icon': icon,
      'humidity': humidity,
      'wind_speed': windSpeed,
    };
  }

  @override
  List<Object?> get props => [
    temperature,
    condition,
    icon,
    humidity,
    windSpeed,
  ];
}

class CampusStats extends Equatable {
  final int studentCount;
  final int activeEvents;
  final int availableJobs;
  final int marketplaceItems;

  const CampusStats({
    this.studentCount = 0,
    this.activeEvents = 0,
    this.availableJobs = 0,
    this.marketplaceItems = 0,
  });

  factory CampusStats.fromMap(Map<String, dynamic> map) {
    return CampusStats(
      studentCount: map['student_count'] ?? 0,
      activeEvents: map['active_events'] ?? 0,
      availableJobs: map['available_jobs'] ?? 0,
      marketplaceItems: map['marketplace_items'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'student_count': studentCount,
      'active_events': activeEvents,
      'available_jobs': availableJobs,
      'marketplace_items': marketplaceItems,
    };
  }

  @override
  List<Object?> get props => [
    studentCount,
    activeEvents,
    availableJobs,
    marketplaceItems,
  ];
}

// Static campus data for now (can be moved to Appwrite later)
class CampusData {
  static const List<CampusModel> campuses = [
    CampusModel(
      id: 'oslo',
      name: 'Oslo',
      description: 'Norway\'s capital and largest campus',
      location: 'Oslo, Norway',
      imageUrl: 'assets/images/oslo_campus.jpg',
      heroImageUrl: 'assets/images/oslo_hero.jpg',
      benefits: [
        'Largest student body',
        'Most events and activities',
        'Central location',
        'Excellent transport links',
      ],
      weather: WeatherData(
        temperature: 8.5,
        condition: 'Cloudy',
        icon: '☁️',
        humidity: 78,
        windSpeed: 12.3,
      ),
      stats: CampusStats(
        studentCount: 12500,
        activeEvents: 45,
        availableJobs: 23,
        marketplaceItems: 156,
      ),
    ),
    CampusModel(
      id: 'bergen',
      name: 'Bergen',
      description: 'Beautiful coastal campus',
      location: 'Bergen, Norway',
      imageUrl: 'assets/images/bergen_campus.jpg',
      heroImageUrl: 'assets/images/bergen_hero.jpg',
      benefits: [
        'Stunning coastal views',
        'Strong maritime focus',
        'Vibrant cultural scene',
        'UNESCO World Heritage nearby',
      ],
      weather: WeatherData(
        temperature: 6.2,
        condition: 'Rainy',
        icon: '🌧️',
        humidity: 85,
        windSpeed: 15.8,
      ),
      stats: CampusStats(
        studentCount: 3200,
        activeEvents: 18,
        availableJobs: 8,
        marketplaceItems: 67,
      ),
    ),
    CampusModel(
      id: 'trondheim',
      name: 'Trondheim',
      description: 'Historic and innovative campus',
      location: 'Trondheim, Norway',
      imageUrl: 'assets/images/trondheim_campus.jpg',
      heroImageUrl: 'assets/images/trondheim_hero.jpg',
      benefits: [
        'Rich history and culture',
        'Innovation hub',
        'Tech partnerships',
        'Student-friendly city',
      ],
      weather: WeatherData(
        temperature: 4.8,
        condition: 'Partly Cloudy',
        icon: '⛅',
        humidity: 72,
        windSpeed: 8.9,
      ),
      stats: CampusStats(
        studentCount: 2800,
        activeEvents: 12,
        availableJobs: 15,
        marketplaceItems: 43,
      ),
    ),
    CampusModel(
      id: 'stavanger',
      name: 'Stavanger',
      description: 'Energy capital campus',
      location: 'Stavanger, Norway',
      imageUrl: 'assets/images/stavanger_campus.jpg',
      heroImageUrl: 'assets/images/stavanger_hero.jpg',
      benefits: [
        'Energy industry focus',
        'Modern facilities',
        'Strong industry connections',
        'Beautiful fjord region',
      ],
      weather: WeatherData(
        temperature: 7.3,
        condition: 'Sunny',
        icon: '☀️',
        humidity: 65,
        windSpeed: 11.2,
      ),
      stats: CampusStats(
        studentCount: 2100,
        activeEvents: 9,
        availableJobs: 12,
        marketplaceItems: 38,
      ),
    ),
  ];

  static CampusModel? getCampusById(String id) {
    try {
      return campuses.firstWhere((campus) => campus.id == id);
    } catch (e) {
      return null;
    }
  }

  static CampusModel get defaultCampus => campuses.first;
}
