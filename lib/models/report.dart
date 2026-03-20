enum ReportStatus {
  draft,
  submitted,
  acknowledged,
  underReview,
  actionTaken,
  closed;

  String get label => switch (this) {
        draft => 'Draft',
        submitted => 'Submitted',
        acknowledged => 'Acknowledged',
        underReview => 'Under Review',
        actionTaken => 'Action Taken',
        closed => 'Closed',
      };

  String get dbValue => switch (this) {
        draft => 'draft',
        submitted => 'submitted',
        acknowledged => 'acknowledged',
        underReview => 'under_review',
        actionTaken => 'action_taken',
        closed => 'closed',
      };

  static ReportStatus fromDb(String value) => switch (value) {
        'submitted' => submitted,
        'acknowledged' => acknowledged,
        'under_review' => underReview,
        'action_taken' => actionTaken,
        'closed' => closed,
        _ => draft,
      };
}

enum ReportAgency {
  hhsOig,
  dojFca,
  stateAg,
  stateLicensing,
  other;

  String get label => switch (this) {
        hhsOig => 'HHS OIG Fraud Hotline',
        dojFca => 'DOJ False Claims Act (Qui Tam)',
        stateAg => 'State Attorney General',
        stateLicensing => 'State Licensing Board',
        other => 'Other Agency',
      };

  String get dbValue => switch (this) {
        hhsOig => 'hhs_oig',
        dojFca => 'doj_fca',
        stateAg => 'state_ag',
        stateLicensing => 'state_licensing',
        other => 'other',
      };

  static ReportAgency fromDb(String value) => switch (value) {
        'hhs_oig' => hhsOig,
        'doj_fca' => dojFca,
        'state_ag' => stateAg,
        'state_licensing' => stateLicensing,
        _ => other,
      };
}

class FraudReport {
  final String id;
  final String investigationId;
  final String userId;
  final ReportAgency agency;
  final String? agencyName;
  final ReportStatus status;
  final String? referenceNumber;
  final DateTime? submittedAt;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FraudReport({
    required this.id,
    required this.investigationId,
    required this.userId,
    required this.agency,
    this.agencyName,
    this.status = ReportStatus.draft,
    this.referenceNumber,
    this.submittedAt,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FraudReport.fromJson(Map<String, dynamic> json) {
    return FraudReport(
      id: json['id'] as String,
      investigationId: json['investigation_id'] as String,
      userId: json['user_id'] as String,
      agency: ReportAgency.fromDb(json['agency'] as String),
      agencyName: json['agency_name'] as String?,
      status: ReportStatus.fromDb(json['status'] as String),
      referenceNumber: json['reference_number'] as String?,
      submittedAt: json['submitted_at'] != null
          ? DateTime.parse(json['submitted_at'] as String)
          : null,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'investigation_id': investigationId,
        'user_id': userId,
        'agency': agency.dbValue,
        'agency_name': agencyName,
        'status': status.dbValue,
        'reference_number': referenceNumber,
        'submitted_at': submittedAt?.toIso8601String(),
        'notes': notes,
      };
}
