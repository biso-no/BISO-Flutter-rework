import 'dart:convert';

class StopPlaceModel {
  final String stopPlaceId;
  final String? name;
  final bool enabled;
  final String campusId;

  StopPlaceModel({
    required this.stopPlaceId,
    required this.campusId,
    this.name,
    this.enabled = true,
  });

  factory StopPlaceModel.fromMap(Map<String, dynamic> map) {
    return StopPlaceModel(
      stopPlaceId: map['stopPlaceId'] as String,
      name: map['name'] as String?,
      enabled: (map['enabled'] as bool?) ?? true,
      campusId: map['campus_id'] as String,
    );
  }
}

class EnturEstimatedCall {
  final bool realtime;
  final DateTime aimedDepartureTime;
  final DateTime expectedDepartureTime;
  final String destination;
  final String lineId;
  final String lineName;
  final String transportMode; // e.g. 'bus', 'metro'
  final String quayId;

  EnturEstimatedCall({
    required this.realtime,
    required this.aimedDepartureTime,
    required this.expectedDepartureTime,
    required this.destination,
    required this.lineId,
    required this.lineName,
    required this.transportMode,
    required this.quayId,
  });

  factory EnturEstimatedCall.fromMap(Map<String, dynamic> map) {
    return EnturEstimatedCall(
      realtime: (map['realtime'] as bool?) ?? false,
      aimedDepartureTime: DateTime.parse(map['aimedDepartureTime'] as String),
      expectedDepartureTime: DateTime.parse(map['expectedDepartureTime'] as String),
      destination: (map['destinationDisplay']?['frontText'] as String?) ?? '',
      quayId: (map['quay']?['id'] as String?) ?? '',
      lineId: (map['serviceJourney']?['journeyPattern']?['line']?['id'] as String?) ?? '',
      lineName: (map['serviceJourney']?['journeyPattern']?['line']?['name'] as String?) ?? '',
      transportMode: (map['serviceJourney']?['journeyPattern']?['line']?['transportMode'] as String?)?.toLowerCase() ?? '',
    );
  }
}

class EnturDepartureBoard {
  final String stopPlaceId;
  final String stopPlaceName;
  final DateTime updatedAt;
  final List<EnturEstimatedCall> calls;

  EnturDepartureBoard({
    required this.stopPlaceId,
    required this.stopPlaceName,
    required this.updatedAt,
    required this.calls,
  });

  factory EnturDepartureBoard.fromDocument(Map<String, dynamic> map) {
    final String? callsRaw = map['estimatedCalls'] as String?;
    List<dynamic> callsJson = <dynamic>[];
    if (callsRaw != null && callsRaw.isNotEmpty) {
      try {
        callsJson = json.decode(callsRaw) as List<dynamic>;
      } catch (_) {
        callsJson = <dynamic>[];
      }
    }

    return EnturDepartureBoard(
      stopPlaceId: map['stopPlaceId'] as String,
      stopPlaceName: (map['stopPlaceName'] as String?) ?? '',
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      calls: callsJson
          .whereType<Map<String, dynamic>>()
          .map((m) => EnturEstimatedCall.fromMap(m))
          .toList(),
    );
  }
}

String sanitizeDocumentId(String input) {
  final buffer = StringBuffer();
  for (final codeUnit in input.codeUnits) {
    final ch = String.fromCharCode(codeUnit);
    final isAlnum =
        (codeUnit >= 48 && codeUnit <= 57) || // 0-9
        (codeUnit >= 65 && codeUnit <= 90) || // A-Z
        (codeUnit >= 97 && codeUnit <= 122); // a-z
    if (isAlnum) buffer.write(ch);
  }
  return buffer.toString();
}



