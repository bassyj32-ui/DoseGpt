import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../widgets/app_theme.dart';
import '../services/data_loader.dart';
import 'drug_list_screen.dart';

/// A selection screen for fluid management options.
///
/// The 'Maintenance Fluids & Others' illness acts as a mini-category
/// with three distinct clinical pathways:
///   1. Maintenance IV Fluids (Holliday-Segar 4-2-1 rule)
///   2. IV Bolus (Shock / Severe Dehydration)
///   3. Dehydration Deficit Replacement
///
/// Each option navigates to the same [DrugListScreen] with the
/// corresponding fluid drug id.
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
          icon: const Icon(PhosphorIconsBold.arrowLeft, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Row(
          children: [
            SizedBox(width: 4),
            Icon(PhosphorIconsDuotone.drop, color: AppTheme.primary, size: 24),
            SizedBox(width: 12),
            Text(
              'Maintenance Fluids & Others',
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
            icon: PhosphorIconsDuotone.drop,
            title: 'Maintenance IV Fluids',
            subtitle: 'Holliday-Segar 4-2-1 rule: calculate daily & hourly rates',
            color: const Color(0xFF1976D2),
            drugId: 'iv_fluids_maintenance',
            onTap: (id) => _navigate(context, id),
          ),
          const SizedBox(height: 12),
          _FluidOptionTile(
            icon: PhosphorIconsDuotone.heartbeat,
            title: 'IV Bolus — Shock / Severe Dehydration',
            subtitle: '20 mL/kg isotonic crystalloid, reassess, repeat PRN',
            color: const Color(0xFFD32F2F),
            drugId: 'iv_fluids_shock',
            onTap: (id) => _navigate(context, id),
          ),
          const SizedBox(height: 12),
          _FluidOptionTile(
            icon: PhosphorIconsDuotone.thermometerHot,
            title: 'Dehydration Deficit Replacement',
            subtitle: 'Estimate deficit, give 50% in 8h + 50% over 16h',
            color: const Color(0xFFFBC02D),
            drugId: 'iv_fluids_dehydration',
            onTap: (id) => _navigate(context, id),
          ),
        ],
      ),
    );
  }

  void _navigate(BuildContext context, String drugId) {
    final illnessId = 'fluids';
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DrugListScreen(
          data: data,
          illnessId: illnessId,
          // DrugListScreen will show all drugs for this illness;
          // the three fluid drug entries are associated with 'fluids'.
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
  final String drugId;
  final ValueChanged<String> onTap;

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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: PhosphorIcon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 14),
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
                PhosphorIconsRegular.caretRight,
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
