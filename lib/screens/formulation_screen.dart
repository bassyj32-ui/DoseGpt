import 'package:flutter/material.dart';
import '../widgets/app_theme.dart';
import '../models/drug.dart';
import '../models/illness.dart';
import '../services/data_loader.dart';
import 'patient_details_screen.dart';

/// Screen 3 of the dosing flow.
/// Shows available formulations (syrup/tablet strengths) for the selected drug.
/// Tapping a formulation instantly navigates to PatientDetailsScreen.
/// If only 1 formulation, auto-navigates.
class FormulationScreen extends StatefulWidget {
  final ClinicalData data;
  final Drug drug;
  final Illness illness;

  const FormulationScreen({
    super.key,
    required this.data,
    required this.drug,
    required this.illness,
  });

  @override
  State<FormulationScreen> createState() => _FormulationScreenState();
}

class _FormulationScreenState extends State<FormulationScreen> {
  bool _autoSkipped = false;

  @override
  void initState() {
    super.initState();
    final concentrations = widget.drug.concentrations ?? [];

    // If only 1 or none, skip to PatientDetails
    if (concentrations.length <= 1) {
      _autoSkipped = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _navigateToPatientDetails(0);
        }
      });
    }
  }

  void _navigateToPatientDetails(int concentrationIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PatientDetailsScreen(
          data: widget.data,
          drug: widget.drug,
          illness: widget.illness,
          concentrationIndex: concentrationIndex,
        ),
      ),
    );
  }

  String _formulationType(Concentration c) {
    if (c.volumeMl != null) return 'Syrup';
    return 'Tablet';
  }

  String _strengthText(Concentration c) {
    final parts = <String>[];
    if (c.strengthMg != null) parts.add('${c.strengthMg!.toInt()}mg');
    if (c.volumeMl != null) parts.add('per ${c.volumeMl!.toInt()}mL');
    return parts.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final concentrations = widget.drug.concentrations ?? [];

    if (_autoSkipped) {
      return Theme(
        data: AppTheme.lightTheme,
        child: Scaffold(
          backgroundColor: AppTheme.lightSurface,
          appBar: _buildAppBar(),
          body: const SizedBox.shrink(),
        ),
      );
    }

    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        backgroundColor: AppTheme.lightSurface,
        appBar: _buildAppBar(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section label
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 20, 24, 12),
              child: Text(
                'Select strength',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightInkMuted,
                ),
              ),
            ),

            // Formulation list
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: concentrations.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final conc = concentrations[index];
                  return _FormulationCard(
                    type: _formulationType(conc),
                    strength: _strengthText(conc),
                    onTap: () => _navigateToPatientDetails(index),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(56),
      child: AppBar(
        title: Text(widget.drug.drugNameEn),
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

class _FormulationCard extends StatelessWidget {
  final String type;
  final String strength;
  final VoidCallback onTap;

  const _FormulationCard({
    required this.type,
    required this.strength,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.lightCardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.lightShadowCard,
        ),
        child: Row(
          children: [
            // Chevron indicator (shows it's tappable)
            Text(
              '\u203A',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w300,
                color: AppTheme.lightInkSubtle,
              ),
            ),
            const SizedBox(width: 12),

            // Type + strength
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.lightInk,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    strength,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.lightInkMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
