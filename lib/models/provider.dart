enum ProviderCategory {
  hospice,
  childcare,
  autismCenter,
  homeHealth,
  nursingHome,
  substanceAbuse,
  groupHome,
  other;

  String get label => switch (this) {
        hospice => 'Hospice',
        childcare => 'Childcare',
        autismCenter => 'Autism Center',
        homeHealth => 'Home Health',
        nursingHome => 'Nursing Home',
        substanceAbuse => 'Substance Abuse',
        groupHome => 'Group Home',
        other => 'Other',
      };

  String get dbValue => switch (this) {
        hospice => 'hospice',
        childcare => 'childcare',
        autismCenter => 'autism_center',
        homeHealth => 'home_health',
        nursingHome => 'nursing_home',
        substanceAbuse => 'substance_abuse',
        groupHome => 'group_home',
        other => 'other',
      };

  static ProviderCategory fromDb(String value) => switch (value) {
        'hospice' => hospice,
        'childcare' => childcare,
        'autism_center' => autismCenter,
        'home_health' => homeHealth,
        'nursing_home' => nursingHome,
        'substance_abuse' => substanceAbuse,
        'group_home' => groupHome,
        _ => other,
      };
}

class FraudProvider {
  final String id;
  final String name;
  final ProviderCategory category;
  final String? address;
  final String? city;
  final String state;
  final String? zip;
  final String? county;
  final double? latitude;
  final double? longitude;
  final String? phone;
  final String? licenseNumber;
  final String? licenseStatus;
  final String? fundingSource;
  final double? fundingAmount;
  final String? ownerName;
  final String? registeredAgent;
  final DateTime? registrationDate;
  final int fraudScore;
  final List<Map<String, dynamic>> fraudFactors;
  final String sourceName;
  final String? sourceUrl;
  final DateTime sourceRetrievedAt;
  final bool isUserSubmitted;
  final String? submittedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FraudProvider({
    required this.id,
    required this.name,
    required this.category,
    this.address,
    this.city,
    required this.state,
    this.zip,
    this.county,
    this.latitude,
    this.longitude,
    this.phone,
    this.licenseNumber,
    this.licenseStatus,
    this.fundingSource,
    this.fundingAmount,
    this.ownerName,
    this.registeredAgent,
    this.registrationDate,
    this.fraudScore = 0,
    this.fraudFactors = const [],
    required this.sourceName,
    this.sourceUrl,
    required this.sourceRetrievedAt,
    this.isUserSubmitted = false,
    this.submittedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FraudProvider.fromJson(Map<String, dynamic> json) {
    return FraudProvider(
      id: json['id'] as String,
      name: json['name'] as String,
      category: ProviderCategory.fromDb(json['category'] as String),
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String,
      zip: json['zip'] as String?,
      county: json['county'] as String?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      phone: json['phone'] as String?,
      licenseNumber: json['license_number'] as String?,
      licenseStatus: json['license_status'] as String?,
      fundingSource: json['funding_source'] as String?,
      fundingAmount: (json['funding_amount'] as num?)?.toDouble(),
      ownerName: json['owner_name'] as String?,
      registeredAgent: json['registered_agent'] as String?,
      registrationDate: json['registration_date'] != null
          ? DateTime.parse(json['registration_date'] as String)
          : null,
      fraudScore: json['fraud_score'] as int? ?? 0,
      fraudFactors: (json['fraud_factors'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>() ??
          [],
      sourceName: json['source_name'] as String,
      sourceUrl: json['source_url'] as String?,
      sourceRetrievedAt:
          DateTime.parse(json['source_retrieved_at'] as String),
      isUserSubmitted: json['is_user_submitted'] as bool? ?? false,
      submittedBy: json['submitted_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category.dbValue,
        'address': address,
        'city': city,
        'state': state,
        'zip': zip,
        'county': county,
        'latitude': latitude,
        'longitude': longitude,
        'phone': phone,
        'license_number': licenseNumber,
        'license_status': licenseStatus,
        'funding_source': fundingSource,
        'funding_amount': fundingAmount,
        'owner_name': ownerName,
        'registered_agent': registeredAgent,
        'registration_date': registrationDate?.toIso8601String(),
        'fraud_score': fraudScore,
        'fraud_factors': fraudFactors,
        'source_name': sourceName,
        'source_url': sourceUrl,
        'source_retrieved_at': sourceRetrievedAt.toIso8601String(),
        'is_user_submitted': isUserSubmitted,
        'submitted_by': submittedBy,
      };

  String get fullAddress =>
      [address, city, state, zip].where((s) => s != null).join(', ');

  String get fraudScoreLabel => switch (fraudScore) {
        >= 80 => 'Critical',
        >= 60 => 'High',
        >= 40 => 'Medium',
        >= 20 => 'Low',
        _ => 'Minimal',
      };
}
