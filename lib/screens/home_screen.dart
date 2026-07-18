import 'package:flutter/material.dart';
import '../widgets/app_theme.dart';
import '../widgets/dose_card.dart';
import '../models/illness.dart';
import '../services/data_loader.dart';
import 'weight_entry_screen.dart';

/// Home screen — Spotify-inspired layout with horizontal scrolling
/// card rows, time-based greeting, and a clean dark aesthetic.
class HomeScreen extends StatelessWidget {
  final ClinicalData data;

  const HomeScreen({super.key, required this.data});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final illnesses = List<Illness>.from(data.illnesses)
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    final mid = (illnesses.length / 2).ceil();
    final topRow = illnesses.take(mid).toList();
    final bottomRow = illnesses.skip(mid).toList();

    return CustomScrollView(
      slivers: [
        // -- Greeting header --
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.inkMuted,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 1),
                const Text(
                  'Common Conditions',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.ink,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
        ),

        // -- First row --
        _buildRow(topRow, data),

        // -- Second row header --
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 28, 16, 8),
            child: Text(
              'More Conditions',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.ink.withValues(alpha: 0.9),
                height: 1.15,
              ),
            ),
          ),
        ),

        // -- Second row --
        _buildRow(bottomRow, data),

        // Bottom padding for nav bar
        const SliverToBoxAdapter(
          child: SizedBox(height: 24),
        ),
      ],
    );
  }

  Widget _buildRow(List<Illness> illnesses, ClinicalData data) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 150,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: illnesses.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final illness = illnesses[index];
            return DoseCard(
              label: illness.nameEn,
              size: 150,
              imagePath: 'assets/images/conditions/${illness.id}.jpg',
              fallbackGradient: AppTheme.conditionGradients[illness.id] ??
                  [AppTheme.surfaceCard, AppTheme.surfaceCard],
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => WeightEntryScreen(
                      data: data,
                      illnessId: illness.id,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
