import 'package:flutter/material.dart';
import '../widgets/app_theme.dart';
import '../widgets/dose_card.dart';
import '../models/illness.dart';
import '../services/data_loader.dart';
import 'weight_entry_screen.dart';

/// Home screen — Spotify-inspired layout with section headers,
/// breathing space between cards, and a clean dark aesthetic.
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
            opacity: const AlwaysStoppedAnimation(0.12),
          ),
        ),

        // Dark overlay for readability
        Positioned.fill(
          child: Container(
            color: AppTheme.surface.withValues(alpha: 0.88),
          ),
        ),

        // Content
        CustomScrollView(
          slivers: [
            // -- Greeting section --
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppTheme.spacingMd,
                  AppTheme.spacingSm,
                  AppTheme.spacingMd,
                  AppTheme.spacingSm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good morning',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.inkMuted,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Common Conditions',
                      style: AppTheme.sectionTitle,
                    ),
                  ],
                ),
              ),
            ),

            // -- Top conditions: 2-column grid --
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

            // -- Quick stats / info banner --
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.spacingMd,
                  AppTheme.spacingLg,
                  AppTheme.spacingMd,
                  0,
                ),
                child: Container(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primary.withValues(alpha: 0.15),
                        AppTheme.primary.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    border: Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                        ),
                        child: const Icon(
                          Icons.medical_information_outlined,
                          color: AppTheme.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Pediatric Dosing Guide',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.ink,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${illnesses.length} conditions · Tap any card to calculate a dose',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.inkMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
