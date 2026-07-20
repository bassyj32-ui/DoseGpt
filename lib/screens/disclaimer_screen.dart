import 'package:flutter/material.dart';
import '../widgets/app_theme.dart';
import '../services/preferences_service.dart';

/// First-launch disclaimer — light theme.
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
    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        backgroundColor: AppTheme.lightSurface,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.lightNavActive.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.medical_services_outlined,
                    color: AppTheme.lightNavActive,
                    size: 40,
                  ),
                ),

                const SizedBox(height: 24),

                // Title
                const Text(
                  'DoseGPT',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.lightInk,
                  ),
                ),

                const SizedBox(height: 16),

                // Disclaimer text
                const Text(
                  'DoseGPT assists dosing calculations. It does not replace clinical judgment. Always verify the patient\'s diagnosis and contraindications before administering.',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.lightInkMuted,
                    height: 1.55,
                  ),
                  textAlign: TextAlign.center,
                ),

                const Spacer(flex: 2),

                // Continue button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.lightNavActive,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppTheme.lightNavActive.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                      textStyle: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
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
      ),
    );
  }
}
