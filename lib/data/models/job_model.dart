import 'package:equatable/equatable.dart';

class JobModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String department;
  final String departmentId;
  final String? departmentLogo;
  final String campusId;
  final String type; // 'volunteer', 'paid', 'internship', 'part_time', 'full_time'
  final String category; // 'event_help', 'marketing', 'tech', 'administration', etc.
  final List<String> requirements;
  final List<String> responsibilities;
  final List<String> skills; // Required skills
  final String? salary; // For paid positions
  final String? timeCommitment; // e.g., "5 hours/week", "One-time event"
  final DateTime startDate;
  final String url;
  final DateTime? endDate;
  final DateTime applicationDeadline;
  final String applicationMethod; // 'internal', 'external', 'email'
  final String? applicationUrl;
  final String? applicationEmail;
  final String contactPersonName;
  final String? contactPersonEmail;
  final String? contactPersonPhone;
  final int maxApplicants;
  final int currentApplicants;
  final String status; // 'open', 'closed', 'filled', 'cancelled'
  final bool isUrgent;
  final bool isFeatured;
  final List<String> benefits; // What volunteers get
  final Map<String, dynamic> metadata; // Additional job-specific data
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const JobModel({
    required this.id,
    required this.title,
    required this.description,
    required this.department,
    required this.departmentId,
    this.departmentLogo,
    required this.campusId,
    this.type = 'volunteer',
    required this.category,
    this.requirements = const [],
    this.responsibilities = const [],
    this.skills = const [],
    this.salary,
    this.timeCommitment,
    required this.startDate,
    required this.url,
    this.endDate,
    required this.applicationDeadline,
    this.applicationMethod = 'internal',
    this.applicationUrl,
    this.applicationEmail,
    required this.contactPersonName,
    this.contactPersonEmail,
    this.contactPersonPhone,
    this.maxApplicants = 0,
    this.currentApplicants = 0,
    this.status = 'open',
    this.isUrgent = false,
    this.isFeatured = false,
    this.benefits = const [],
    this.metadata = const {},
    this.createdAt,
    this.updatedAt,
  });

  // Create from the Appwrite Function jobs payload (WordPress-backed)
  factory JobModel.fromFunctionJob(Map<String, dynamic> map, {required String campusId}) {
    // Transformed function returns: id, title, description (cleaned), campus (array), type (array), interests (array), expiry_date, url
    final typeList = map['type'] as List<dynamic>? ?? [];
    final interestsList = map['interests'] as List<dynamic>? ?? [];
    final campusList = map['campus'] as List<dynamic>? ?? [];
    
    // Extract department from type array or use first item
    final department = typeList.isNotEmpty ? _decodeHtmlEntities(typeList.first.toString()) : 'BISO';
    
    return JobModel(
      id: (map['id'] ?? '').toString(),
      title: _decodeHtmlEntities((map['title'] ?? '').toString()),
      description: _decodeHtmlEntities((map['description'] ?? '').toString()),
      department: department,
      departmentId: '',
      departmentLogo: null,
      campusId: campusId,
      type: 'volunteer',
      category: typeList.isNotEmpty ? _decodeHtmlEntities(typeList.first.toString()) : 'general',
      requirements: List<String>.from(interestsList.map((e) => _decodeHtmlEntities(e.toString()))),
      responsibilities: const <String>[],
      skills: List<String>.from(typeList.map((e) => _decodeHtmlEntities(e.toString()))),
      salary: null,
      timeCommitment: null,
      startDate: DateTime.now(),
      endDate: null,
      url: map['url']?.toString() ?? '',
      applicationDeadline: DateTime.tryParse((map['expiry_date'] ?? '').toString()) ?? DateTime.now().add(const Duration(days: 14)),
      applicationMethod: 'external',
      applicationUrl: map['url']?.toString(),
      applicationEmail: null,
      contactPersonName: department,
      contactPersonEmail: null,
      contactPersonPhone: null,
      maxApplicants: 0,
      currentApplicants: 0,
      status: 'open',
      isUrgent: false,
      isFeatured: false,
      benefits: const <String>[],
      metadata: <String, dynamic>{
        'campusNames': campusList,
        'type': typeList,
        'interests': interestsList,
      },
      createdAt: null,
      updatedAt: null,
    );
  }


  factory JobModel.fromMap(Map<String, dynamic> map) {
    return JobModel(
      id: map['\$id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      department: map['department'] ?? '',
      departmentId: map['department_id'] ?? '',
      departmentLogo: map['department_logo'],
      campusId: map['campus_id'] ?? '',
      type: map['type'] ?? 'volunteer',
      category: map['category'] ?? '',
      requirements: List<String>.from(map['requirements'] ?? []),
      responsibilities: List<String>.from(map['responsibilities'] ?? []),
      skills: List<String>.from(map['skills'] ?? []),
      salary: map['salary'],
      timeCommitment: map['time_commitment'],
      startDate: DateTime.parse(map['start_date']),
      url: map['url']?.toString() ?? '',
      endDate: map['end_date'] != null ? DateTime.parse(map['end_date']) : null,
      applicationDeadline: DateTime.parse(map['application_deadline']),
      applicationMethod: map['application_method'] ?? 'internal',
      applicationUrl: map['application_url'],
      applicationEmail: map['application_email'],
      contactPersonName: map['contact_person_name'] ?? '',
      contactPersonEmail: map['contact_person_email'],
      contactPersonPhone: map['contact_person_phone'],
      maxApplicants: map['max_applicants'] ?? 0,
      currentApplicants: map['current_applicants'] ?? 0,
      status: map['status'] ?? 'open',
      isUrgent: map['is_urgent'] ?? false,
      isFeatured: map['is_featured'] ?? false,
      benefits: List<String>.from(map['benefits'] ?? []),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
      createdAt: map['\$createdAt'] != null ? DateTime.parse(map['\$createdAt']) : null,
      updatedAt: map['\$updatedAt'] != null ? DateTime.parse(map['\$updatedAt']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'department': department,
      'department_id': departmentId,
      'department_logo': departmentLogo,
      'campus_id': campusId,
      'type': type,
      'category': category,
      'requirements': requirements,
      'responsibilities': responsibilities,
      'skills': skills,
      'salary': salary,
      'time_commitment': timeCommitment,
      'start_date': startDate.toIso8601String(),
      'url': url,
      'end_date': endDate?.toIso8601String(),
      'application_deadline': applicationDeadline.toIso8601String(),
      'application_method': applicationMethod,
      'application_url': applicationUrl,
      'application_email': applicationEmail,
      'contact_person_name': contactPersonName,
      'contact_person_email': contactPersonEmail,
      'contact_person_phone': contactPersonPhone,
      'max_applicants': maxApplicants,
      'current_applicants': currentApplicants,
      'status': status,
      'is_urgent': isUrgent,
      'is_featured': isFeatured,
      'benefits': benefits,
      'metadata': metadata,
    };
  }

  JobModel copyWith({
    String? id,
    String? title,
    String? description,
    String? department,
    String? departmentId,
    String? departmentLogo,
    String? campusId,
    String? type,
    String? category,
    List<String>? requirements,
    List<String>? responsibilities,
    List<String>? skills,
    String? salary,
    String? timeCommitment,
    DateTime? startDate,
    String? url,
    DateTime? endDate,
    DateTime? applicationDeadline,
    String? applicationMethod,
    String? applicationUrl,
    String? applicationEmail,
    String? contactPersonName,
    String? contactPersonEmail,
    String? contactPersonPhone,
    int? maxApplicants,
    int? currentApplicants,
    String? status,
    bool? isUrgent,
    bool? isFeatured,
    List<String>? benefits,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JobModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      department: department ?? this.department,
      departmentId: departmentId ?? this.departmentId,
      departmentLogo: departmentLogo ?? this.departmentLogo,
      campusId: campusId ?? this.campusId,
      type: type ?? this.type,
      category: category ?? this.category,
      requirements: requirements ?? this.requirements,
      responsibilities: responsibilities ?? this.responsibilities,
      skills: skills ?? this.skills,
      salary: salary ?? this.salary,
      timeCommitment: timeCommitment ?? this.timeCommitment,
      startDate: startDate ?? this.startDate,
      url: url ?? this.url,
      endDate: endDate ?? this.endDate,
      applicationDeadline: applicationDeadline ?? this.applicationDeadline,
      applicationMethod: applicationMethod ?? this.applicationMethod,
      applicationUrl: applicationUrl ?? this.applicationUrl,
      applicationEmail: applicationEmail ?? this.applicationEmail,
      contactPersonName: contactPersonName ?? this.contactPersonName,
      contactPersonEmail: contactPersonEmail ?? this.contactPersonEmail,
      contactPersonPhone: contactPersonPhone ?? this.contactPersonPhone,
      maxApplicants: maxApplicants ?? this.maxApplicants,
      currentApplicants: currentApplicants ?? this.currentApplicants,
      status: status ?? this.status,
      isUrgent: isUrgent ?? this.isUrgent,
      isFeatured: isFeatured ?? this.isFeatured,
      benefits: benefits ?? this.benefits,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isOpen => status == 'open';
  bool get isClosed => status == 'closed';
  bool get isFilled => status == 'filled';
  bool get isCancelled => status == 'cancelled';
  bool get canApply => isOpen && (maxApplicants == 0 || currentApplicants < maxApplicants) && 
                      applicationDeadline.isAfter(DateTime.now());
  bool get isPaid => type == 'paid' || type == 'internship' || type == 'part_time' || type == 'full_time';
  String get displayType {
    switch (type) {
      case 'volunteer': return 'Volunteer';
      case 'paid': return 'Paid Position';
      case 'internship': return 'Internship';
      case 'part_time': return 'Part Time';
      case 'full_time': return 'Full Time';
      default: return type;
    }
  }

  @override
  List<Object?> get props => [
    id, title, description, department, departmentId, departmentLogo,
    campusId, type, category, requirements, responsibilities, skills,
    salary, timeCommitment, startDate, endDate, applicationDeadline,
    applicationMethod, applicationUrl, applicationEmail, contactPersonName,
    contactPersonEmail, contactPersonPhone, maxApplicants, currentApplicants,
    status, isUrgent, isFeatured, benefits, metadata, createdAt, updatedAt,
  ];

  /// Decode HTML entities from WordPress content
  static String _decodeHtmlEntities(String text) {
    if (text.isEmpty) return text;
    
    return text
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&#x27;', "'")
        .replaceAll('&apos;', "'")
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&mdash;', '—')
        .replaceAll('&ndash;', '–')
        .replaceAll('&ldquo;', '"')
        .replaceAll('&rdquo;', '"')
        .replaceAll('&lsquo;', ''')
        .replaceAll('&rsquo;', ''')
        .replaceAll('&hellip;', '…')
        .replaceAll('&copy;', '©')
        .replaceAll('&reg;', '®')
        .replaceAll('&trade;', '™');
  }
}