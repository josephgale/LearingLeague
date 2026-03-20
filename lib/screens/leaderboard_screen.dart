import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/profile.dart';
import '../providers/app_providers.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events),
            onPressed: () {},
          ),
        ],
      ),
      body: leaderboardAsync.when(
        data: (users) => users.isEmpty
            ? const _EmptyLeaderboard()
            : CustomScrollView(
                slivers: [
                  // Top 3 podium
                  if (users.length >= 3)
                    SliverToBoxAdapter(
                      child: _Podium(top3: users.take(3).toList()),
                    ),
                  // Rest of the list
                  SliverPadding(
                    padding: const EdgeInsets.all(12),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final rank = users.length >= 3 ? index + 4 : index + 1;
                          final userIndex =
                              users.length >= 3 ? index + 3 : index;
                          if (userIndex >= users.length) return null;
                          return _LeaderboardTile(
                            user: users[userIndex],
                            rank: rank,
                          );
                        },
                        childCount:
                            users.length >= 3 ? users.length - 3 : users.length,
                      ),
                    ),
                  ),
                ],
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _Podium extends StatelessWidget {
  final List<UserProfile> top3;
  const _Podium({required this.top3});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.amber.withValues(alpha: 0.15),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd place
          _PodiumSpot(user: top3[1], rank: 2, height: 80),
          const SizedBox(width: 12),
          // 1st place
          _PodiumSpot(user: top3[0], rank: 1, height: 110),
          const SizedBox(width: 12),
          // 3rd place
          _PodiumSpot(user: top3[2], rank: 3, height: 60),
        ],
      ),
    );
  }
}

class _PodiumSpot extends StatelessWidget {
  final UserProfile user;
  final int rank;
  final double height;

  const _PodiumSpot({
    required this.user,
    required this.rank,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [Colors.amber, Colors.grey[400]!, Colors.brown[400]!];
    final color = colors[rank - 1];
    final medals = ['', '1st', '2nd', '3rd'];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: rank == 1 ? 36 : 28,
          backgroundColor: color.withValues(alpha: 0.3),
          child: Text(
            user.username[0].toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: rank == 1 ? 28 : 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          user.displayLabel,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '${user.xp} XP',
          style: TextStyle(color: Colors.grey[500], fontSize: 12),
        ),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Center(
            child: Text(
              medals[rank],
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final UserProfile user;
  final int rank;

  const _LeaderboardTile({required this.user, required this.rank});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: SizedBox(
          width: 40,
          child: Center(
            child: Text(
              '#$rank',
              style: TextStyle(
                color: Colors.grey[500],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(user.displayLabel),
        subtitle: Text('Level ${user.level}'),
        trailing: Text(
          '${user.xp} XP',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.amber,
          ),
        ),
      ),
    );
  }
}

class _EmptyLeaderboard extends StatelessWidget {
  const _EmptyLeaderboard();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events_outlined, size: 64, color: Colors.grey[700]),
          const SizedBox(height: 16),
          Text(
            'No hunters on the board yet',
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to claim a route!',
            style: TextStyle(color: Colors.grey[700], fontSize: 13),
          ),
        ],
      ),
    );
  }
}
