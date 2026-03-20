import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/provider.dart';
import '../providers/app_providers.dart';

class FilterBar extends ConsumerWidget {
  const FilterBar({super.key});

  static const _states = [
    'CA', 'MN', 'TX', 'FL', 'NY', 'OH', 'PA', 'IL', 'GA', 'NC',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedState = ref.watch(selectedStateFilter);
    final selectedCategory = ref.watch(selectedCategoryFilter);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // State filter
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _filterChip(
                  label: 'All States',
                  selected: selectedState == null,
                  onTap: () =>
                      ref.read(selectedStateFilter.notifier).state = null,
                ),
                ..._states.map(
                  (s) => _filterChip(
                    label: s,
                    selected: selectedState == s,
                    onTap: () =>
                        ref.read(selectedStateFilter.notifier).state = s,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          // Category filter
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _filterChip(
                  label: 'All Types',
                  selected: selectedCategory == null,
                  onTap: () =>
                      ref.read(selectedCategoryFilter.notifier).state = null,
                ),
                ...ProviderCategory.values
                    .where((c) => c != ProviderCategory.other)
                    .map(
                      (c) => _filterChip(
                        label: c.label,
                        selected: selectedCategory == c,
                        onTap: () => ref
                            .read(selectedCategoryFilter.notifier)
                            .state = c,
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: selected,
        onSelected: (_) => onTap(),
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
