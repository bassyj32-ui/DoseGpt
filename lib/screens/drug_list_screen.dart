import 'package:flutter/material.dart';
import '../widgets/app_theme.dart';
import '../models/drug.dart';
import '../models/illness.dart';
import '../services/data_loader.dart';
import 'formulation_screen.dart';

/// Screen 2 of the dosing flow.
/// Shows a list of drugs available for the selected illness.
/// If only 1 drug exists, auto-navigates to FormulationScreen.
class DrugListScreen extends StatelessWidget {
  final ClinicalData data;
  final String illnessId;

  const DrugListScreen({
    super.key,
    required this.data,
    required this.illnessId,
  });

  void _handleDrugTap(BuildContext context, Drug drug, Illness illness) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FormulationScreen(
          data: data,
          drug: drug,
          illness: illness,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final illness = data.getIllness(illnessId);
    final drugs = data.getDrugsForIllness(illnessId);
    final illnessName = illness?.nameEn ?? 'Select Drug';

    // If only 1 drug, skip this screen entirely
    if (drugs.length == 1) {
      // Navigate immediately via post-frame callback
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          _handleDrugTap(context, drugs.first, illness!);
        }
      });
      // Return a loading/empty shell for this frame
      return Theme(
        data: AppTheme.lightTheme,
        child: Scaffold(
          backgroundColor: AppTheme.lightSurface,
          appBar: _buildAppBar(context, illnessName),
          body: const SizedBox.shrink(),
        ),
      );
    }

    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        backgroundColor: AppTheme.lightSurface,
        appBar: _buildAppBar(context, illnessName),
        body: ListView.separated(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          itemCount: drugs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final drug = drugs[index];
            return _DrugCard(
              drug: drug,
              onTap: () => _handleDrugTap(context, drug, illness!),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, String title) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(56),
      child: AppBar(
        title: Text(title),
        backgroundColor: AppTheme.lightSurface,
        foregroundColor: AppTheme.lightInk,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(color: AppTheme.lightDivider, height: 0.5),
        ),
      ),
    );
  }
}

class _DrugCard extends StatelessWidget {
  final Drug drug;
  final VoidCallback onTap;

  const _DrugCard({required this.drug, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: AppTheme.lightCardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.lightShadowCard,
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            // Radio indicator circle
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.lightInkSubtle,
                  width: 2,
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Drug name
            Expanded(
              child: Text(
                drug.drugNameEn,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightInk,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Chevron
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '\u203A',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                  color: AppTheme.lightInkSubtle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
