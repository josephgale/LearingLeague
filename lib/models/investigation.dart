enum InvestigationStatus {
  notInvestigated,
  redFlag,
  seemsLegit,
  inconclusive;

  String get label => switch (this) {
        notInvestigated => 'Not Investigated',
        redFlag => 'Red Flag',
        seemsLegit => 'Seems Legit',
        inconclusive => 'Inconclusive',
      };

  String get dbValue => switch (this) {
        notInvestigated => 'not_investigated',
        redFlag => 'red_flag',
        seemsLegit => 'seems_legit',
        inconclusive => 'inconclusive',
      };

  static InvestigationStatus fromDb(String value) => switch (value) {
        'red_flag' => redFlag,
        'seems_legit' => seemsLegit,
        'inconclusive' => inconclusive,
        _ => notInvestigated,
      };
}

class Investigation {
  final String id;
  final String providerId;
  final String userId;
  final String? routeId;
  final InvestigationStatus status;
  final String? notes;
  final List<Map<String, dynamic>> checklist;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Investigation({
    required this.id,
    required this.providerId,
    required this.userId,
    this.routeId,
    this.status = InvestigationStatus.notInvestigated,
    this.notes,
    this.checklist = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Investigation.fromJson(Map<String, dynamic> json) {
    return Investigation(
      id: json['id'] as String,
      providerId: json['provider_id'] as String,
      userId: json['user_id'] as String,
      routeId: json['route_id'] as String?,
      status: InvestigationStatus.fromDb(json['status'] as String),
      notes: json['notes'] as String?,
      checklist: (json['checklist'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'provider_id': providerId,
        'user_id': userId,
        'route_id': routeId,
        'status': status.dbValue,
        'notes': notes,
        'checklist': checklist,
      };
}

enum EvidenceType {
  photo,
  video,
  document,
  note;

  String get label => switch (this) {
        photo => 'Photo',
        video => 'Video',
        document => 'Document',
        note => 'Note',
      };

  static EvidenceType fromDb(String value) => switch (value) {
        'photo' => photo,
        'video' => video,
        'document' => document,
        _ => note,
      };
}

class Evidence {
  final String id;
  final String investigationId;
  final String userId;
  final EvidenceType type;
  final String? fileUrl;
  final String? thumbnailUrl;
  final String? caption;
  final double? latitude;
  final double? longitude;
  final DateTime? capturedAt;
  final DateTime createdAt;

  const Evidence({
    required this.id,
    required this.investigationId,
    required this.userId,
    required this.type,
    this.fileUrl,
    this.thumbnailUrl,
    this.caption,
    this.latitude,
    this.longitude,
    this.capturedAt,
    required this.createdAt,
  });

  factory Evidence.fromJson(Map<String, dynamic> json) {
    return Evidence(
      id: json['id'] as String,
      investigationId: json['investigation_id'] as String,
      userId: json['user_id'] as String,
      type: EvidenceType.fromDb(json['type'] as String),
      fileUrl: json['file_url'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      caption: json['caption'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      capturedAt: json['captured_at'] != null
          ? DateTime.parse(json['captured_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'investigation_id': investigationId,
        'user_id': userId,
        'type': type.name,
        'file_url': fileUrl,
        'thumbnail_url': thumbnailUrl,
        'caption': caption,
        'latitude': latitude,
        'longitude': longitude,
        'captured_at': capturedAt?.toIso8601String(),
      };
}
