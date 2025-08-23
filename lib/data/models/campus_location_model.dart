import 'package:equatable/equatable.dart';

class CampusLocationModel extends Equatable {
  final String address;
  final String email;

  const CampusLocationModel({
    required this.address,
    required this.email,
  });

  factory CampusLocationModel.fromJson(Map<String, dynamic> json) {
    return CampusLocationModel(
      address: json['address'] ?? '',
      email: json['email'] ?? '',
    );
  }

  factory CampusLocationModel.fromString(String locationString) {
    try {
      // Remove any extra whitespace and parse the JSON string
      final cleanString = locationString.trim();
      if (cleanString.startsWith('{') && cleanString.endsWith('}')) {
        // Import dart:convert here to avoid circular dependencies
        final Map<String, dynamic> json = Map<String, dynamic>.from(
          // Basic JSON parsing without dart:convert
          _parseJsonString(cleanString),
        );
        return CampusLocationModel.fromJson(json);
      }
    } catch (e) {
      // If parsing fails, return default values
    }
    
    // Fallback to default values
    return const CampusLocationModel(
      address: '',
      email: '',
    );
  }

  // Simple JSON parser for basic string parsing
  static Map<String, dynamic> _parseJsonString(String jsonString) {
    final Map<String, dynamic> result = {};
    
    try {
      // Remove braces and split by comma
      final content = jsonString.substring(1, jsonString.length - 1);
      final pairs = content.split(',');
      
      for (final pair in pairs) {
        final colonIndex = pair.indexOf(':');
        if (colonIndex > 0) {
          final key = pair.substring(0, colonIndex).trim().replaceAll('"', '');
          final value = pair.substring(colonIndex + 1).trim().replaceAll('"', '');
          if (key.isNotEmpty && value.isNotEmpty) {
            result[key] = value;
          }
        }
      }
    } catch (e) {
      // Return empty map if parsing fails
    }
    
    return result;
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'email': email,
    };
  }

  @override
  List<Object?> get props => [address, email];
}
