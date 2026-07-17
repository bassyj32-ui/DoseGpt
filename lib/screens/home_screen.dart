import 'package:flutter/material.dart';
import '../widgets/app_theme.dart';
import '../widgets/dose_card.dart';
import '../models/illness.dart';
import '../services/data_loader.dart';
import 'weight_entry_screen.dart';

/// Home screen — Spotify-style 2-column grid of condition cards
/// with baby photo background and search in app bar.
class HomeScreen extends StatelessWidget {
  final ClinicalData data;

  const HomeScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final illnesses = List<Illness>.from(data.illnesses)
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    return Stack(
      children: [
        // Baby photo background
        Positioned.fill(
          child: Image.asset(
            'assets/images/background/baby_photo.jpg',
            fit: BoxFit.cover,
            opacity: const AlwaysStoppedAnimation(0.15),
          ),
        ),

        // Dark overlay for readability
        Positioned.fill(
          child: Container(
            color: AppTheme.surface.withValues(alpha: 0.85),
          ),
        ),

        // Content
        CustomScrollView(
          slivers: [
            // Section title
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppTheme.spacingMd,
                  AppTheme.spacingSm,
                  AppTheme.spacingMd,
                  AppTheme.spacingMd,
                ),
                child: Text(
                  'Conditions',
                  style: AppTheme.sectionTitle,
                ),
              ),
            ),

            // 2-column grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppTheme.spacingMd,
                  crossAxisSpacing: AppTheme.spacingMd,
                  childAspectRatio: 1.0,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final illness = illnesses[index];
                    return DoseCard(
                      label: illness.nameEn,
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
                  childCount: illnesses.length,
                ),
              ),
            ),

            // Bottom padding for nav bar
            const SliverToBoxAdapter(
              child: SizedBox(height: AppTheme.spacingLg),
            ),
          ],
        ),
      ],
    );
  }
}
