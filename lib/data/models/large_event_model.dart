import 'package:flutter/material.dart';
import 'dart:convert';

import '../../core/utils/color_utils.dart';

/// Types of content that can be showcased in the hero carousel
enum ShowcaseType {
  largeEvent,     // Traditional large events (default)
  webshopProduct, // Featured webshop products
  externalEvent,  // TicketCo or other external events
  jobOpportunity, // Featured job opportunities
  announcement,   // General announcements
}

extension ShowcaseTypeX on ShowcaseType {
  static ShowcaseType parse(dynamic value) {
    final s = (value ?? '').toString().toLowerCase();
    switch (s) {
      case 'webshopproduct':
      case 'webshop_product':
      case 'webshop-product':
      case 'product':
        return ShowcaseType.webshopProduct;
      case 'externalevent':
      case 'external_event':
      case 'external-event':
      case 'ticketco':
        return ShowcaseType.externalEvent;
      case 'jobopportunity':
      case 'job_opportunity':
      case 'job-opportunity':
      case 'job':
        return ShowcaseType.jobOpportunity;
      case 'announcement':
        return ShowcaseType.announcement;
      case 'largeevent':
      case 'large_event':
      case 'large-event':
      case 'event':
      default:
        return ShowcaseType.largeEvent;
    }
  }

  String get value {
    switch (this) {
      case ShowcaseType.webshopProduct:
        return 'webshopProduct';
      case ShowcaseType.externalEvent:
        return 'externalEvent';
      case ShowcaseType.jobOpportunity:
        return 'jobOpportunity';
      case ShowcaseType.announcement:
        return 'announcement';
      case ShowcaseType.largeEvent:
        return 'largeEvent';
    }
  }
}

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

  // Showcase system
  final ShowcaseType showcaseType; // Type of content being showcased
  final Map<String, dynamic> contentMetadata; // Flexible data for different types
  final String? externalUrl; // CTA URL for external links
  final String? ctaText; // Custom call-to-action text

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
    this.showcaseType = ShowcaseType.largeEvent,
    this.contentMetadata = const {},
    this.externalUrl,
    this.ctaText,
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

  // Convenience getters for different showcase types
  String? get productId => contentMetadata['productId'];
  String? get jobId => contentMetadata['jobId'];  
  String? get ticketcoEventId => contentMetadata['ticketcoEventId'];
  String? get ticketcoOrgId => contentMetadata['ticketcoOrgId'];
  String? get announcementContent => contentMetadata['content'];
  
  // Get the effective CTA text based on showcase type
  String get effectiveCtaText {
    if (ctaText?.isNotEmpty == true) return ctaText!;
    
    switch (showcaseType) {
      case ShowcaseType.webshopProduct:
        return 'Shop Now';
      case ShowcaseType.externalEvent:
        return 'Get Tickets';
      case ShowcaseType.jobOpportunity:
        return 'Apply Now';
      case ShowcaseType.announcement:
        return 'Learn More';
      case ShowcaseType.largeEvent:
        return 'View Event';
    }
  }

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

    // Parse contentMetadata
    Map<String, dynamic> contentMetadata = {};
    dynamic rawMetadata = map['contentMetadata'];
    if (rawMetadata is String && rawMetadata.isNotEmpty) {
      try {
        contentMetadata = Map<String, dynamic>.from(json.decode(rawMetadata));
      } catch (_) {
        contentMetadata = {};
      }
    } else if (rawMetadata is Map<String, dynamic>) {
      contentMetadata = rawMetadata;
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
      showcaseType: ShowcaseTypeX.parse(map['showcaseType']),
      contentMetadata: contentMetadata,
      externalUrl: map['externalUrl'],
      ctaText: map['ctaText'],
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
      id:
          map['id']?.toString() ??
          map['\$id']?.toString() ??
          UniqueKey().toString(),
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
