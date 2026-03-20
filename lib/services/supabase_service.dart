import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/provider.dart';
import '../models/route.dart';
import '../models/investigation.dart';
import '../models/profile.dart';
import '../models/report.dart';

class SupabaseService {
  final SupabaseClient _client;

  SupabaseService(this._client);

  SupabaseClient get client => _client;
  String? get currentUserId => _client.auth.currentUser?.id;

  // ── Auth ──────────────────────────────────────────────

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    return _client.auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() => _client.auth.signOut();

  // ── Providers (Megabase) ──────────────────────────────

  Future<List<FraudProvider>> getProviders({
    String? state,
    ProviderCategory? category,
    int? minFraudScore,
    int limit = 500,
    int offset = 0,
  }) async {
    var query = _client.from('providers').select();

    if (state != null) query = query.eq('state', state);
    if (category != null) query = query.eq('category', category.dbValue);
    if (minFraudScore != null) {
      query = query.gte('fraud_score', minFraudScore);
    }

    final data = await query
        .order('fraud_score', ascending: false)
        .range(offset, offset + limit - 1);

    return (data as List).map((e) => FraudProvider.fromJson(e)).toList();
  }

  Future<FraudProvider> getProvider(String id) async {
    final data =
        await _client.from('providers').select().eq('id', id).single();
    return FraudProvider.fromJson(data);
  }

  Future<FraudProvider> submitProvider(Map<String, dynamic> provider) async {
    final data = await _client
        .from('providers')
        .insert({
          ...provider,
          'is_user_submitted': true,
          'submitted_by': currentUserId,
        })
        .select()
        .single();
    return FraudProvider.fromJson(data);
  }

  // ── Routes ────────────────────────────────────────────

  Future<List<InvestigationRoute>> getRoutes({String? state}) async {
    var query = _client.from('routes').select();
    if (state != null) query = query.eq('state', state);

    final data = await query.order('active_claimants', ascending: false);
    return (data as List).map((e) => InvestigationRoute.fromJson(e)).toList();
  }

  Future<InvestigationRoute> getRoute(String id) async {
    final data = await _client.from('routes').select().eq('id', id).single();
    return InvestigationRoute.fromJson(data);
  }

  Future<List<RouteClaim>> getRouteClaims(String routeId) async {
    final data = await _client
        .from('route_claims')
        .select('*, profiles(*)')
        .eq('route_id', routeId)
        .eq('status', 'active');
    return (data as List).map((e) => RouteClaim.fromJson(e)).toList();
  }

  Future<RouteClaim> claimRoute(String routeId) async {
    final data = await _client
        .from('route_claims')
        .insert({
          'route_id': routeId,
          'user_id': currentUserId,
        })
        .select()
        .single();
    return RouteClaim.fromJson(data);
  }

  Future<void> updateClaimStatus(String claimId, ClaimStatus status) async {
    await _client
        .from('route_claims')
        .update({'status': status.name})
        .eq('id', claimId);
  }

  // ── Investigations ────────────────────────────────────

  Future<List<Investigation>> getInvestigations({
    String? providerId,
    String? routeId,
    String? userId,
  }) async {
    var query = _client.from('investigations').select();
    if (providerId != null) query = query.eq('provider_id', providerId);
    if (routeId != null) query = query.eq('route_id', routeId);
    if (userId != null) query = query.eq('user_id', userId);

    final data = await query.order('updated_at', ascending: false);
    return (data as List).map((e) => Investigation.fromJson(e)).toList();
  }

  Future<Investigation> createInvestigation({
    required String providerId,
    String? routeId,
  }) async {
    final data = await _client
        .from('investigations')
        .insert({
          'provider_id': providerId,
          'user_id': currentUserId,
          'route_id': routeId,
        })
        .select()
        .single();
    return Investigation.fromJson(data);
  }

  Future<Investigation> updateInvestigation(
    String id, {
    InvestigationStatus? status,
    String? notes,
    List<Map<String, dynamic>>? checklist,
  }) async {
    final updates = <String, dynamic>{};
    if (status != null) updates['status'] = status.dbValue;
    if (notes != null) updates['notes'] = notes;
    if (checklist != null) updates['checklist'] = checklist;

    final data = await _client
        .from('investigations')
        .update(updates)
        .eq('id', id)
        .select()
        .single();
    return Investigation.fromJson(data);
  }

  // ── Evidence ──────────────────────────────────────────

  Future<List<Evidence>> getEvidence(String investigationId) async {
    final data = await _client
        .from('evidence')
        .select()
        .eq('investigation_id', investigationId)
        .order('created_at', ascending: false);
    return (data as List).map((e) => Evidence.fromJson(e)).toList();
  }

  Future<Evidence> addEvidence(Map<String, dynamic> evidence) async {
    final data = await _client
        .from('evidence')
        .insert({...evidence, 'user_id': currentUserId})
        .select()
        .single();
    return Evidence.fromJson(data);
  }

  Future<String> uploadFile(String bucket, String path, List<int> bytes) async {
    await _client.storage.from(bucket).uploadBinary(path, bytes);
    return _client.storage.from(bucket).getPublicUrl(path);
  }

  // ── Reports ───────────────────────────────────────────

  Future<List<FraudReport>> getReports({String? userId}) async {
    var query = _client.from('reports').select();
    if (userId != null) query = query.eq('user_id', userId);

    final data = await query.order('created_at', ascending: false);
    return (data as List).map((e) => FraudReport.fromJson(e)).toList();
  }

  Future<FraudReport> createReport(Map<String, dynamic> report) async {
    final data = await _client
        .from('reports')
        .insert({...report, 'user_id': currentUserId})
        .select()
        .single();
    return FraudReport.fromJson(data);
  }

  Future<FraudReport> updateReportStatus(
      String id, ReportStatus status) async {
    final updates = <String, dynamic>{'status': status.dbValue};
    if (status == ReportStatus.submitted) {
      updates['submitted_at'] = DateTime.now().toIso8601String();
    }
    final data = await _client
        .from('reports')
        .update(updates)
        .eq('id', id)
        .select()
        .single();
    return FraudReport.fromJson(data);
  }

  // ── Profiles & Leaderboard ────────────────────────────

  Future<UserProfile> getProfile(String userId) async {
    final data =
        await _client.from('profiles').select().eq('id', userId).single();
    return UserProfile.fromJson(data);
  }

  Future<UserProfile> updateProfile(Map<String, dynamic> updates) async {
    final data = await _client
        .from('profiles')
        .update(updates)
        .eq('id', currentUserId!)
        .select()
        .single();
    return UserProfile.fromJson(data);
  }

  Future<List<UserProfile>> getLeaderboard({
    String scope = 'national',
    int limit = 100,
  }) async {
    final data = await _client
        .from('profiles')
        .select()
        .order('xp', ascending: false)
        .limit(limit);
    return (data as List).map((e) => UserProfile.fromJson(e)).toList();
  }

  Future<List<XpEvent>> getXpHistory(String userId, {int limit = 50}) async {
    final data = await _client
        .from('xp_events')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(limit);
    return (data as List).map((e) => XpEvent.fromJson(e)).toList();
  }
}
