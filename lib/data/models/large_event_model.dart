import 'package:flutter/material.dart';
import 'dart:convert';

import '../../core/utils/color_utils.dart';

class LargeEventModel {
  final String id;
  final String slug;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final bool heroOverrideEnabled; // Global toggle for replacing home hero
  final int priority; // Higher wins when multiple events active

  // Theming
  final String? primaryColorHex;
  final String? secondaryColorHex;
  final String? textColorHex;
  final List<String>? gradientHex;
  final String? logoUrl; // Prefer storing full URL in DB
  final String? backgroundImageUrl; // Prefer full URL for simplicity

  // Per-campus configuration
  final Map<String, LargeEventCampusConfig> campusConfigs; // key: campusId

  const LargeEventModel({
    required this.id,
    required this.slug,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.heroOverrideEnabled,
    required this.priority,
    required this.campusConfigs,
    this.primaryColorHex,
    this.secondaryColorHex,
    this.textColorHex,
    this.gradientHex,
    this.logoUrl,
    this.backgroundImageUrl,
  });

  Color get primaryColor => parseHexColor(primaryColorHex ?? '#3DA9E0');
  Color get secondaryColor => parseHexColor(secondaryColorHex ?? '#7B68EE');
  Color get textColor => parseHexColor(textColorHex ?? '#FFFFFF');
  List<Color> get gradientColors => (gradientHex ?? ['#3DA9E0', '#7BC8E8'])
      .map(parseHexColor)
      .toList(growable: false);

  bool isActiveForCampus(String campusId, DateTime now) {
    if (!isActive) return false;
    if (now.isBefore(startDate) || now.isAfter(endDate)) return false;
    final campus = campusConfigs[campusId.toLowerCase()];
    if (campus == null) return false;
    return campus.isActive;
  }

  LargeEventCampusConfig? campusConfig(String campusId) =>
      campusConfigs[campusId.toLowerCase()];

  factory LargeEventModel.fromMap(Map<String, dynamic> map) {
    final campusMap = <String, LargeEventCampusConfig>{};
    dynamic rawCampusList = map['campusConfigs'];
    if (rawCampusList is String && rawCampusList.isNotEmpty) {
      try {
        rawCampusList = json.decode(rawCampusList);
      } catch (_) {
        rawCampusList = null;
      }
    }
    rawCampusList = rawCampusList as List<dynamic>?;
    if (rawCampusList != null) {
      for (final item in rawCampusList) {
        if (item is Map<String, dynamic>) {
          final cfg = LargeEventCampusConfig.fromMap(item);
          campusMap[cfg.campusId.toLowerCase()] = cfg;
        }
      }
    }

    return LargeEventModel(
      id: map['\$id'] ?? map['id'] ?? '',
      slug: map['slug'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      startDate: DateTime.tryParse(map['startDate'] ?? '') ?? DateTime.now(),
      endDate:
          DateTime.tryParse(map['endDate'] ?? '') ?? DateTime.now().toUtc(),
      isActive: map['isActive'] ?? false,
      heroOverrideEnabled: map['heroOverrideEnabled'] ?? false,
      priority: map['priority'] is int
          ? map['priority'] as int
          : int.tryParse('${map['priority']}') ?? 0,
      primaryColorHex: map['primaryColorHex'],
      secondaryColorHex: map['secondaryColorHex'],
      textColorHex: map['textColorHex'],
      gradientHex: (map['gradientHex'] as List?)?.cast<String>(),
      logoUrl: map['logoUrl'],
      backgroundImageUrl: map['backgroundImageUrl'],
      campusConfigs: campusMap,
    );
  }
}

class LargeEventCampusConfig {
  final String campusId; // e.g. 'oslo', 'bergen'
  final bool isActive; // Whether event is promoted for campus
  final bool heroOverrideEnabled; // Allow override only for this campus

  // Ticketing model
  final LargeEventTicketingModel ticketingModel;
  final String? allAccessPassUrl; // For all-access model
  final List<LargeEventScheduleItem> schedule; // For per-event model

  // Optional CTA links
  final String? infoUrl;
  final String? ticketPortalUrl; // TicketCo org/event listing

  const LargeEventCampusConfig({
    required this.campusId,
    required this.isActive,
    required this.heroOverrideEnabled,
    required this.ticketingModel,
    required this.schedule,
    this.allAccessPassUrl,
    this.infoUrl,
    this.ticketPortalUrl,
  });

  factory LargeEventCampusConfig.fromMap(Map<String, dynamic> map) {
    return LargeEventCampusConfig(
      campusId: (map['campusId'] ?? '').toString(),
      isActive: map['isActive'] ?? false,
      heroOverrideEnabled: map['heroOverrideEnabled'] ?? false,
      ticketingModel: LargeEventTicketingModelX.parse(map['ticketingModel']),
      allAccessPassUrl: map['allAccessPassUrl'],
      infoUrl: map['infoUrl'],
      ticketPortalUrl: map['ticketPortalUrl'],
      schedule: ((map['schedule'] as List?) ?? [])
          .whereType<Map<String, dynamic>>()
          .map(LargeEventScheduleItem.fromMap)
          .toList(growable: false),
    );
  }
}

class LargeEventScheduleItem {
  final String id;
  final String title;
  final String? subtitle;
  final DateTime startTime;
  final DateTime? endTime;
  final String? location;
  final String? coverImageUrl;
  final String? ticketUrl; // Deep link to TicketCo event if desired

  const LargeEventScheduleItem({
    required this.id,
    required this.title,
    required this.startTime,
    this.endTime,
    this.subtitle,
    this.location,
    this.coverImageUrl,
    this.ticketUrl,
  });

  factory LargeEventScheduleItem.fromMap(Map<String, dynamic> map) {
    return LargeEventScheduleItem(
      id: map['id']?.toString() ?? map['\$id']?.toString() ?? UniqueKey().toString(),
      title: map['title'] ?? '',
      subtitle: map['subtitle'],
      startTime: DateTime.tryParse(map['startTime'] ?? '') ?? DateTime.now(),
      endTime: DateTime.tryParse(map['endTime'] ?? ''),
      location: map['location'],
      coverImageUrl: map['coverImageUrl'],
      ticketUrl: map['ticketUrl'],
    );
  }
}

enum LargeEventTicketingModel { perEvent, allAccess }

extension LargeEventTicketingModelX on LargeEventTicketingModel {
  static LargeEventTicketingModel parse(dynamic value) {
    final s = (value ?? '').toString().toLowerCase();
    switch (s) {
      case 'allaccess':
      case 'all_access':
      case 'all-access':
        return LargeEventTicketingModel.allAccess;
      case 'perevent':
      case 'per_event':
      case 'per-event':
      default:
        return LargeEventTicketingModel.perEvent;
    }
  }
}


