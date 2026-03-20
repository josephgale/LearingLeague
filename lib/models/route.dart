class InvestigationRoute {
  final String id;
  final String name;
  final String? description;
  final String state;
  final String? region;
  final List<String> zipCodes;
  final Map<String, dynamic>? bounds;
  final int providerCount;
  final int activeClaimants;
  final DateTime createdAt;
  final DateTime updatedAt;

  const InvestigationRoute({
    required this.id,
    required this.name,
    this.description,
    required this.state,
    this.region,
    this.zipCodes = const [],
    this.bounds,
    this.providerCount = 0,
    this.activeClaimants = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InvestigationRoute.fromJson(Map<String, dynamic> json) {
    return InvestigationRoute(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      state: json['state'] as String,
      region: json['region'] as String?,
      zipCodes: (json['zip_codes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      bounds: json['bounds'] as Map<String, dynamic>?,
      providerCount: json['provider_count'] as int? ?? 0,
      activeClaimants: json['active_claimants'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'state': state,
        'region': region,
        'zip_codes': zipCodes,
        'bounds': bounds,
        'provider_count': providerCount,
      };
}

enum ClaimStatus {
  active,
  paused,
  completed,
  abandoned;

  String get label => switch (this) {
        active => 'Active',
        paused => 'Paused',
        completed => 'Completed',
        abandoned => 'Abandoned',
      };

  static ClaimStatus fromDb(String value) => switch (value) {
        'active' => active,
        'paused' => paused,
        'completed' => completed,
        _ => abandoned,
      };
}

class RouteClaim {
  final String id;
  final String routeId;
  final String userId;
  final ClaimStatus status;
  final DateTime claimedAt;
  final DateTime updatedAt;

  const RouteClaim({
    required this.id,
    required this.routeId,
    required this.userId,
    this.status = ClaimStatus.active,
    required this.claimedAt,
    required this.updatedAt,
  });

  factory RouteClaim.fromJson(Map<String, dynamic> json) {
    return RouteClaim(
      id: json['id'] as String,
      routeId: json['route_id'] as String,
      userId: json['user_id'] as String,
      status: ClaimStatus.fromDb(json['status'] as String),
      claimedAt: DateTime.parse(json['claimed_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
