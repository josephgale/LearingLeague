import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/provider.dart';

class ProviderCard extends StatelessWidget {
  final FraudProvider provider;
  final VoidCallback? onClose;
  final VoidCallback? onTap;

  const ProviderCard({
    super.key,
    required this.provider,
    this.onClose,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Fraud score badge
                  _FraudScoreBadge(score: provider.fraudScore),
                  const SizedBox(width: 12),
                  // Name and category
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          provider.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          provider.category.label,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onClose != null)
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: onClose,
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Address
              if (provider.address != null)
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[500]),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        provider.fullAddress,
                        style: TextStyle(color: Colors.grey[400], fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 8),

              // Source info
              Row(
                children: [
                  Icon(Icons.source, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Source: ${provider.sourceName}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 11),
                    ),
                  ),
                  Text(
                    _formatDate(provider.sourceRetrievedAt),
                    style: TextStyle(color: Colors.grey[600], fontSize: 11),
                  ),
                ],
              ),

              // Fraud factors
              if (provider.fraudFactors.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: provider.fraudFactors
                      .take(3)
                      .map((f) => _FactorChip(
                            label: f['label'] as String? ?? 'Flag',
                          ))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}

class _FraudScoreBadge extends StatelessWidget {
  final int score;
  const _FraudScoreBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.fraudScoreColor(score);
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Center(
        child: Text(
          score.toString(),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}

class _FactorChip extends StatelessWidget {
  final String label;
  const _FactorChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.redAccent, fontSize: 11),
      ),
    );
  }
}
