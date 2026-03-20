import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/constants.dart';
import '../providers/app_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return const _SignInPrompt();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final service = ref.read(supabaseServiceProvider);
              await service.signOut();
            },
          ),
        ],
      ),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) return const _SignInPrompt();
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Avatar & name
                CircleAvatar(
                  radius: 48,
                  backgroundColor:
                      Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                  child: Text(
                    profile.username[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 36,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  profile.displayLabel,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  '@${profile.username}',
                  style: TextStyle(color: Colors.grey[500]),
                ),

                const SizedBox(height: 24),

                // XP & Level card
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _StatColumn(
                                label: 'Level', value: '${profile.level}'),
                            _StatColumn(
                                label: 'XP', value: '${profile.xp}'),
                            _StatColumn(
                                label: 'Streak',
                                value: '${profile.streakDays}d'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // XP progress bar
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Level ${profile.level}',
                                  style: TextStyle(
                                      color: Colors.grey[500], fontSize: 12),
                                ),
                                Text(
                                  'Level ${profile.level + 1}',
                                  style: TextStyle(
                                      color: Colors.grey[500], fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: profile.levelProgress,
                                minHeight: 10,
                                backgroundColor: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${profile.xpToNextLevel} XP to next level',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // XP breakdown
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'How to earn XP',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        _XpRow('Claim a route',
                            '+${AppConstants.xpRouteClaim} XP'),
                        _XpRow('Upload 5+ evidence',
                            '+${AppConstants.xpEvidenceUpload} XP'),
                        _XpRow('Submit report to agency',
                            '+${AppConstants.xpReportSubmitted} XP'),
                        _XpRow('Media pickup bonus',
                            '+${AppConstants.xpMediaPickup} XP'),
                        _XpRow(
                            'Daily login', '+${AppConstants.xpDailyLogin} XP'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  const _StatColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.amber,
          ),
        ),
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
      ],
    );
  }
}

class _XpRow extends StatelessWidget {
  final String action;
  final String xp;
  const _XpRow(this.action, this.xp);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(action, style: TextStyle(color: Colors.grey[400])),
          Text(xp,
              style: const TextStyle(
                  color: Colors.amber, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _SignInPrompt extends StatelessWidget {
  const _SignInPrompt();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outline, size: 64, color: Colors.grey[700]),
            const SizedBox(height: 16),
            Text('Sign in to start hunting',
                style: TextStyle(color: Colors.grey[500], fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to auth screen
              },
              child: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}
