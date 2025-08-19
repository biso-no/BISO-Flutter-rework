class DepartmentModel {
  final String id;
  final String name;
  final String campusId;
  final String? logo;
  final bool active;
  final String? type;
  final String? description;

  DepartmentModel({
    required this.id,
    required this.name,
    required this.campusId,
    required this.active,
    this.logo,
    this.type,
    this.description,
  });

  factory DepartmentModel.fromMap(Map<String, dynamic> map) {
    return DepartmentModel(
      id: (map['\$id'] ?? map['Id'] ?? '').toString(),
      name: (map['Name'] ?? map['name'] ?? '').toString(),
      campusId: (map['campus_id'] ?? '').toString(),
      active: (map['active'] is bool)
          ? map['active'] as bool
          : (map['active']?.toString() == 'true'),
      logo: (map['logo']?.toString().isNotEmpty ?? false)
          ? map['logo'].toString()
          : null,
      type: (map['type']?.toString().isNotEmpty ?? false)
          ? map['type'].toString()
          : null,
      description: (map['description']?.toString().isNotEmpty ?? false)
          ? map['description'].toString()
          : null,
    );
  }
}
