import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../widgets/app_theme.dart';
import '../services/data_loader.dart';
import '../screens/drug_list_screen.dart';
import '../screens/formulation_screen.dart';

/// A selection screen for fluid management options.
///
/// Shows dedicated tiles for each fluid pathway
/// (Maintenance, Shock, Dehydration, Burn) and
/// navigates directly to the correct flow for each.
class FluidOptionsScreen extends StatelessWidget {
  final ClinicalData data;

  const FluidOptionsScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightSurface,
      appBar: AppBar(
        backgroundColor: AppTheme.lightSurface,
        foregroundColor: AppTheme.lightInk,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrow_left, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Row(
          children: [
            SizedBox(width: 4),
            Icon(LucideIcons.droplet, color: AppTheme.primary, size: 24),
            SizedBox(width: 12),
            Text(
              'IV Fluids',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.lightInk,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        children: [
          _FluidOptionTile(
            icon: LucideIcons.droplet,
            title: 'Maintenance IV Fluids',
            subtitle: 'Holliday-Segar 4-2-1 rule: calculates hourly & daily rates',
            color: const Color(0xFF1976D2),
            drugId: 'iv_fluids_maintenance',
            onTap: (id) => _navigateDirect(context, id),
          ),
          const SizedBox(height: 12),
          _FluidOptionTile(
            icon: LucideIcons.heart_pulse,
            title: 'IV Bolus — Shock / Severe Dehydration',
            subtitle: '20 mL/kg isotonic crystalloid — calculates exact bolus volume',
            color: const Color(0xFFD32F2F),
            drugId: 'iv_fluids_shock',
            onTap: (id) => _navigateDirect(context, id),
          ),
          const SizedBox(height: 12),
          _FluidOptionTile(
            icon: LucideIcons.thermometer,
            title: 'Dehydration Deficit Replacement',
            subtitle: 'Estimate deficit by % — gives actual ml needed',
            color: const Color(0xFFFBC02D),
            drugId: 'iv_fluids_dehydration',
            onTap: (id) => _navigateDirect(context, id),
          ),
          const SizedBox(height: 12),
          _FluidOptionTile(
            icon: LucideIcons.flame,
            title: 'Burn — Fluid Resuscitation',
            subtitle: 'Parkland formula: 4 ml/kg/%TBSA — with example & protocol',
            color: const Color(0xFFFF6F00),
            drugId: 'iv_fluids_burn',
            onTap: (id) => _navigateDirect(context, id),
          ),
          const SizedBox(height: 12),
          // Also offer "view all fluids" option
          _FluidOptionTile(
            icon: LucideIcons.list,
            title: 'All IV Fluid Options',
            subtitle: 'View full list of fluid pathways above',
            color: AppTheme.lightInkMuted,
            drugId: null,
            onTap: (id) => _navigateToList(context),
          ),
        ],
      ),
    );
  }

  /// Navigate directly to a specific fluid drug (bypass DrugListScreen).
  void _navigateDirect(BuildContext context, String? drugId) {
    if (drugId == null) return;
    final drug = data.getDrug(drugId);
    if (drug == null) return;
    final illness = data.getIllness('fluids');
    if (illness == null) return;
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

  /// Navigate to the full fluid drug list.
  void _navigateToList(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DrugListScreen(
          data: data,
          illnessId: 'fluids',
        ),
      ),
    );
  }
}

class _FluidOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String? drugId;
  final ValueChanged<String?> onTap;

  const _FluidOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.drugId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => onTap(drugId),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.lightCardBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: drugId != null ? AppTheme.primary : AppTheme.lightInkSubtle,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.lightInk,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.lightInkMuted,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                LucideIcons.chevron_right,
                color: AppTheme.lightInkSubtle,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
