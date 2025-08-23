import 'package:equatable/equatable.dart';
import 'department_board_model.dart';

class CampusDataModel extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? location;
  final List<String> businessBenefits;
  final List<String> studentBenefits;
  final List<String> careerAdvantages;
  final List<String> socialNetwork;
  final List<String> safety;
  final List<DepartmentBoardModel> departmentBoard;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CampusDataModel({
    required this.id,
    required this.name,
    this.description,
    this.location,
    this.businessBenefits = const [],
    this.studentBenefits = const [],
    this.careerAdvantages = const [],
    this.socialNetwork = const [],
    this.safety = const [],
    this.departmentBoard = const [],
    this.createdAt,
    this.updatedAt,
  });

  /// Helper method to extract location string from various formats
  static String? _extractLocationString(dynamic locationData) {
    if (locationData == null) return null;
    
    if (locationData is String) {
      // Handle stringified JSON containing address/email
      final trimmed = locationData.trim();
      if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
        try {
          // Use basic decode via dart:convert without importing here to avoid dependency
          // We'll parse in CampusModel where dart:convert is already used; here, fallback
          // Keep raw string as-is; actual decoding handled in service/model consumer
          // But attempt lightweight parse pattern
          final addressMatch = RegExp(r'"address"\s*:\s*"([^"]+)"').firstMatch(trimmed);
          if (addressMatch != null) {
            return addressMatch.group(1);
          }
        } catch (_) {
          // ignore and fall through
        }
      }
      return locationData;
    }
    
    if (locationData is Map<String, dynamic>) {
      // Extract address from the location object
      return locationData['address'];
    }
    
    // Fallback for any other type
    return locationData.toString();
  }

  factory CampusDataModel.fromMap(Map<String, dynamic> map) {
    return CampusDataModel(
      id: map['\$id'] ?? map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'],
      location: _extractLocationString(map['location']),
      businessBenefits: _parseStringList(map['businessBenefits']),
      studentBenefits: _parseStringList(map['studentBenefits']),
      careerAdvantages: _parseStringList(map['careerAdvantages']),
      socialNetwork: _parseStringList(map['socialNetwork']),
      safety: _parseStringList(map['safety']),
      departmentBoard: _parseDepartmentBoard(map['departmentBoard']),
      createdAt: map['\$createdAt'] != null
          ? DateTime.parse(map['\$createdAt'])
          : null,
      updatedAt: map['\$updatedAt'] != null
          ? DateTime.parse(map['\$updatedAt'])
          : null,
    );
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    if (value is String) {
      // Handle JSON string format
      try {
        final decoded = value
            .replaceAll('[', '')
            .replaceAll(']', '')
            .replaceAll('"', '')
            .split(',')
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .toList();
        return decoded;
      } catch (e) {
        return [value];
      }
    }
    return [];
  }

  static List<DepartmentBoardModel> _parseDepartmentBoard(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value
          .map((item) => DepartmentBoardModel.fromMap(
              item is Map<String, dynamic> ? item : {}))
          .toList();
    }
    return [];
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'location': location,
      'businessBenefits': businessBenefits,
      'studentBenefits': studentBenefits,
      'careerAdvantages': careerAdvantages,
      'socialNetwork': socialNetwork,
      'safety': safety,
    };
  }

  CampusDataModel copyWith({
    String? id,
    String? name,
    String? description,
    String? location,
    List<String>? businessBenefits,
    List<String>? studentBenefits,
    List<String>? careerAdvantages,
    List<String>? socialNetwork,
    List<String>? safety,
    List<DepartmentBoardModel>? departmentBoard,
  }) {
    return CampusDataModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      businessBenefits: businessBenefits ?? this.businessBenefits,
      studentBenefits: studentBenefits ?? this.studentBenefits,
      careerAdvantages: careerAdvantages ?? this.careerAdvantages,
      socialNetwork: socialNetwork ?? this.socialNetwork,
      safety: safety ?? this.safety,
      departmentBoard: departmentBoard ?? this.departmentBoard,
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
        businessBenefits,
        studentBenefits,
        careerAdvantages,
        socialNetwork,
        safety,
        departmentBoard,
        createdAt,
        updatedAt,
      ];
}