import 'package:flutter/material.dart';
import '../widgets/app_theme.dart';
import '../widgets/primary_button.dart';
import '../models/drug.dart';
import '../models/illness.dart';
import '../services/data_loader.dart';
import 'patient_details_screen.dart';

/// Screen 3 of the dosing flow.
/// Shows available formulations (syrup/tablet strengths) for the selected drug.
/// If only 1 formulation, auto-navigates to PatientDetailsScreen.
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
  int? _selectedIndex;
  bool _autoSkipped = false;

  @override
  void initState() {
    super.initState();
    final concentrations = widget.drug.concentrations ?? [];
    
    // If only 1 formulation or none, skip to PatientDetails
    if (concentrations.length <= 1) {
      _autoSkipped = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _navigateToPatientDetails(concentrations.isEmpty ? 0 : 0);
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
          children: [
            // Section label
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 20, 24, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select strength',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightInkMuted,
                  ),
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
                  final isSelected = _selectedIndex == index;
                  return _FormulationCard(
                    type: _formulationType(conc),
                    strength: _strengthText(conc),
                    isSelected: isSelected,
                    onTap: () => setState(() => _selectedIndex = index),
                  );
                },
              ),
            ),

            // Continue button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: PrimaryButton(
                label: 'Continue',
                onPressed: _selectedIndex != null
                    ? () => _navigateToPatientDetails(_selectedIndex!)
                    : null,
              ),
            ),
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
  final bool isSelected;
  final VoidCallback onTap;

  const _FormulationCard({
    required this.type,
    required this.strength,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.lightNavActive.withValues(alpha: 0.06)
              : AppTheme.lightCardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppTheme.lightNavActive
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Radio circle
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? AppTheme.lightNavActive
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppTheme.lightNavActive
                      : AppTheme.lightInkSubtle,
                  width: isSelected ? 6 : 2,
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Type + strength
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppTheme.lightNavActive
                          : AppTheme.lightInk,
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
