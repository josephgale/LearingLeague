import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../config/constants.dart';
import '../config/theme.dart';
import '../models/provider.dart';
import '../providers/app_providers.dart';
import '../widgets/filter_bar.dart';
import '../widgets/provider_card.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final _mapController = MapController();
  FraudProvider? _selectedProvider;

  @override
  Widget build(BuildContext context) {
    final providersAsync = ref.watch(providersProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(
                AppConstants.defaultLat,
                AppConstants.defaultLng,
              ),
              initialZoom: AppConstants.defaultZoom,
              onTap: (_, __) => setState(() => _selectedProvider = null),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://api.mapbox.com/styles/v1/mapbox/dark-v11/tiles/{z}/{x}/{y}?access_token=${AppConstants.mapboxAccessToken}',
                userAgentPackageName: 'com.learingleague.app',
              ),
              providersAsync.when(
                data: (providers) => MarkerLayer(
                  markers: providers
                      .where((p) => p.latitude != null && p.longitude != null)
                      .map((p) => _buildMarker(p))
                      .toList(),
                ),
                loading: () => const MarkerLayer(markers: []),
                error: (_, __) => const MarkerLayer(markers: []),
              ),
            ],
          ),

          // Filter bar at top
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(child: FilterBar()),
          ),

          // Selected provider card at bottom
          if (_selectedProvider != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: ProviderCard(
                provider: _selectedProvider!,
                onClose: () => setState(() => _selectedProvider = null),
              ),
            ),

          // Stats overlay
          Positioned(
            bottom: _selectedProvider != null ? 200 : 16,
            right: 16,
            child: providersAsync.when(
              data: (providers) => _buildStatsChip(providers.length),
              loading: () => _buildStatsChip(0),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  Marker _buildMarker(FraudProvider provider) {
    final color = _pinColor(provider);
    return Marker(
      point: LatLng(provider.latitude!, provider.longitude!),
      width: 32,
      height: 32,
      child: GestureDetector(
        onTap: () => setState(() => _selectedProvider = provider),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: Text(
              provider.fraudScore.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _pinColor(FraudProvider provider) {
    if (provider.isUserSubmitted) return AppTheme.pinUserSubmitted;
    return AppTheme.fraudScoreColor(provider.fraudScore);
  }

  Widget _buildStatsChip(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$count leads',
        style: const TextStyle(color: Colors.white70, fontSize: 12),
      ),
    );
  }
}
