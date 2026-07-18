import 'package:flutter/material.dart';
import '../widgets/app_theme.dart';
import '../services/preferences_service.dart';

/// First-launch disclaimer — Spotify dark style.
class DisclaimerScreen extends StatefulWidget {
  final Widget Function() onDismissed;

  const DisclaimerScreen({super.key, required this.onDismissed});

  @override
  State<DisclaimerScreen> createState() => _DisclaimerScreenState();
}

class _DisclaimerScreenState extends State<DisclaimerScreen> {
  bool _isLoading = false;

  Future<void> _handleContinue() async {
    setState(() => _isLoading = true);
    await PreferencesService.setHasSeenDisclaimer(true);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => widget.onDismissed(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                ),
                child: const Icon(
                  Icons.medical_services_outlined,
                  color: AppTheme.primary,
                  size: 40,
                ),
              ),

              const SizedBox(height: AppTheme.spacingLg),

              // Title
              const Text(
                'DoseGPT',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.ink,
                ),
              ),

              const SizedBox(height: AppTheme.spacingMd),

              // Disclaimer text
              Text(
                'DoseGPT assists dosing calculations. It does not replace clinical judgment. Always verify the patient\'s diagnosis and contraindications before administering.',
                style: AppTheme.body,
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 2),

              // Continue button
              SizedBox(
                width: double.infinity,
                height: AppTheme.minTapHeight,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleContinue,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.ink,
                          ),
                        )
                      : const Text('I Understand / Continue'),
                ),
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
