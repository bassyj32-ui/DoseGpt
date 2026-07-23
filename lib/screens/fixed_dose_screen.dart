import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/app_theme.dart';
import '../widgets/primary_button.dart';
import '../widgets/disclaimer_line.dart';
import '../models/drug.dart';
import '../models/illness.dart';

/// Simple screen for fixed-dose drugs that require no weight/age input.
/// Just displays the dose information card.
class FixedDoseScreen extends StatelessWidget {
  final Drug drug;
  final Illness illness;

  const FixedDoseScreen({
    super.key,
    required this.drug,
    required this.illness,
  });

  @override
  Widget build(BuildContext context) {
    final doseText = drug.doseDisplayEn ?? 'No dose information available.';
    final sourceText = drug.sourceName.isNotEmpty
        ? drug.sourceName
        : 'Standard treatment guideline';

    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        backgroundColor: AppTheme.lightSurface,
        appBar: AppBar(
          title: Text(illness.nameEn),
          backgroundColor: AppTheme.lightSurface,
          foregroundColor: AppTheme.lightInk,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(0.5),
            child: Container(color: AppTheme.lightDivider, height: 0.5),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drug name
              Center(
                child: Text(
                  drug.drugNameEn,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightInkMuted,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Dose card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.lightSurface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppTheme.lightShadowCard,
                ),
                child: Column(
                  children: [
                    SelectableText(
                      doseText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.lightNavActive,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: doseText));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Copied to clipboard'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy, size: 16),
                        label: const Text('Copy'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.lightNavActive,
                          side: BorderSide(
                              color:
                                  AppTheme.lightNavActive.withValues(alpha: 0.3)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Safety warning
              if (drug.safetyWarning != null &&
                  drug.safetyWarning!.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.lightAccent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppTheme.lightAccent.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          size: 18, color: AppTheme.lightAccent),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          drug.safetyWarning!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.lightInk,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // Notes
              if (drug.notes != null && drug.notes!.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.lightCardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.lightDivider),
                  ),
                  child: Text(
                    drug.notes!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.lightInkMuted,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // Referral trigger
              if (drug.referralTriggerText != null &&
                  drug.referralTriggerText!.isNotEmpty) ...[
                _WarningBanner(
                  icon: Icons.local_hospital,
                  message: drug.referralTriggerText!,
                  color: AppTheme.lightAccent,
                ),
                const SizedBox(height: 8),
              ],

              // Food requirement
              if (drug.foodRequirement != null &&
                  drug.foodRequirement!.isNotEmpty) ...[
                _WarningBanner(
                  icon: Icons.restaurant,
                  message: drug.foodRequirement!,
                  color: AppTheme.accentGold,
                ),
                const SizedBox(height: 8),
              ],

              const SizedBox(height: 16),

              // Source
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: AppTheme.lightShadowCard,
                ),
                child: Row(
                  children: [
                    Icon(Icons.article_outlined,
                        size: 16, color: AppTheme.lightInkSubtle),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Source: $sourceText',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.lightInkMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              PrimaryButton(
                label: 'Back to Conditions',
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
              ),

              const SizedBox(height: 16),
              const DisclaimerLine(),
            ],
          ),
        ),
      ),
    );
  }
}

class _WarningBanner extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color color;

  const _WarningBanner({
    required this.icon,
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.lightInk,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
