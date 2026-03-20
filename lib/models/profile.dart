class UserProfile {
  final String id;
  final String username;
  final String? displayName;
  final String? avatarUrl;
  final String? bio;
  final int xp;
  final int level;
  final int streakDays;
  final DateTime? lastActiveAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.username,
    this.displayName,
    this.avatarUrl,
    this.bio,
    this.xp = 0,
    this.level = 1,
    this.streakDays = 0,
    this.lastActiveAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      username: json['username'] as String,
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      xp: json['xp'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      streakDays: json['streak_days'] as int? ?? 0,
      lastActiveAt: json['last_active_at'] != null
          ? DateTime.parse(json['last_active_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'username': username,
        'display_name': displayName,
        'avatar_url': avatarUrl,
        'bio': bio,
      };

  String get displayLabel => displayName ?? username;

  int get xpToNextLevel => ((level + 1) * (level + 1)) * 100 - xp;

  double get levelProgress {
    final currentLevelXp = (level * level) * 100;
    final nextLevelXp = ((level + 1) * (level + 1)) * 100;
    final range = nextLevelXp - currentLevelXp;
    if (range <= 0) return 0;
    return (xp - currentLevelXp) / range;
  }
}

class XpEvent {
  final String id;
  final String userId;
  final String action;
  final int xpAmount;
  final String? referenceId;
  final String? referenceType;
  final DateTime createdAt;

  const XpEvent({
    required this.id,
    required this.userId,
    required this.action,
    required this.xpAmount,
    this.referenceId,
    this.referenceType,
    required this.createdAt,
  });

  factory XpEvent.fromJson(Map<String, dynamic> json) {
    return XpEvent(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      action: json['action'] as String,
      xpAmount: json['xp_amount'] as int,
      referenceId: json['reference_id'] as String?,
      referenceType: json['reference_type'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  String get actionLabel => switch (action) {
        'route_claim' => 'Claimed a route',
        'evidence_upload' => 'Uploaded evidence',
        'report_submitted' => 'Submitted report',
        'media_pickup' => 'Media pickup bonus',
        'daily_login' => 'Daily login',
        _ => action,
      };
}
