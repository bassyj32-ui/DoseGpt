import 'package:flutter/material.dart';
import '../widgets/app_theme.dart';
import '../widgets/dose_card.dart';
import '../models/illness.dart';
import '../services/data_loader.dart';
import 'weight_entry_screen.dart';

/// Home screen content — scrollable list of illness cards,
/// ordered by display_order (clinical burden/danger).
/// No Scaffold wrapper — rendered inside MainShell.
class HomeScreen extends StatelessWidget {
  final ClinicalData data;

  const HomeScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final illnesses = List<Illness>.from(data.illnesses)
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    return ListView.separated(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      itemCount: illnesses.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: AppTheme.spacingSm),
      itemBuilder: (context, index) {
        final illness = illnesses[index];
        return DoseCard(
          label: illness.nameEn,
          urgentAccent: illness.urgentAccent,
          isRecommended: true,
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
    );
  }
}
