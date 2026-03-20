import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../models/provider.dart';
import '../models/route.dart';
import '../models/profile.dart';

// ── Core service ────────────────────────────────────────

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService(Supabase.instance.client);
});

// ── Auth state ──────────────────────────────────────────

final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

final currentUserProvider = Provider<User?>((ref) {
  return Supabase.instance.client.auth.currentUser;
});

final currentProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  final service = ref.read(supabaseServiceProvider);
  return service.getProfile(user.id);
});

// ── Providers (megabase) ────────────────────────────────

final selectedStateFilter = StateProvider<String?>((ref) => null);
final selectedCategoryFilter = StateProvider<ProviderCategory?>((ref) => null);
final minFraudScoreFilter = StateProvider<int?>((ref) => null);

final providersProvider = FutureProvider<List<FraudProvider>>((ref) async {
  final service = ref.read(supabaseServiceProvider);
  final state = ref.watch(selectedStateFilter);
  final category = ref.watch(selectedCategoryFilter);
  final minScore = ref.watch(minFraudScoreFilter);
  return service.getProviders(
    state: state,
    category: category,
    minFraudScore: minScore,
  );
});

// ── Routes ──────────────────────────────────────────────

final routesProvider = FutureProvider<List<InvestigationRoute>>((ref) async {
  final service = ref.read(supabaseServiceProvider);
  final state = ref.watch(selectedStateFilter);
  return service.getRoutes(state: state);
});

// ── Leaderboard ─────────────────────────────────────────

final leaderboardProvider = FutureProvider<List<UserProfile>>((ref) async {
  final service = ref.read(supabaseServiceProvider);
  return service.getLeaderboard();
});

// ── Map state ───────────────────────────────────────────

final selectedProviderIdProvider = StateProvider<String?>((ref) => null);

// ── Navigation ──────────────────────────────────────────

final selectedTabProvider = StateProvider<int>((ref) => 0);
