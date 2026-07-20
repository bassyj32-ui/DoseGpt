import 'package:flutter/material.dart';
import '../widgets/app_theme.dart';
import '../widgets/primary_button.dart';
import '../models/drug.dart';
import '../models/illness.dart';
import '../services/data_loader.dart';
import '../services/dose_calculator.dart';
import 'result_screen.dart';

/// Screen 4 of the dosing flow.
/// Weight on top, Age as simple text fields with quick-preset chips.
class PatientDetailsScreen extends StatefulWidget {
  final ClinicalData data;
  final Drug drug;
  final Illness illness;
  final int concentrationIndex;

  const PatientDetailsScreen({
    super.key,
    required this.data,
    required this.drug,
    required this.illness,
    required this.concentrationIndex,
  });

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  final _weightController = TextEditingController();
  final _yearsController = TextEditingController();
  final _monthsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isCalculating = false;

  // Quick age presets: label, years, months
  static const _quickAges = [
    ('0-6 mo', 0, 3),
    ('1 yr', 1, 0),
    ('2 yr', 2, 0),
    ('5 yr', 5, 0),
    ('10 yr', 10, 0),
  ];

  int get _years {
    final text = _yearsController.text.trim();
    return int.tryParse(text) ?? 0;
  }

  int get _months {
    final text = _monthsController.text.trim();
    return int.tryParse(text) ?? 0;
  }

  int get _totalMonths => _years * 12 + _months;

  double? get _weightKg {
    final text = _weightController.text.trim();
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }

  void _setAge(int years, int months) {
    _yearsController.text = years.toString();
    _monthsController.text = months.toString();
    setState(() {});
  }

  String? _validateWeight(String? value) {
    if (value == null || value.trim().isEmpty) return 'Enter weight';
    final kg = double.tryParse(value.trim());
    if (kg == null || kg <= 0) return 'Enter a valid weight';
    if (kg > 120) return 'Enter a realistic weight';
    return null;
  }

  Future<void> _calculate() async {
    if (!_formKey.currentState!.validate()) return;

    final weight = _weightKg;
    if (weight == null) return;

    final totalMonths = _totalMonths;

    // Neonatal check
    if (totalMonths > 0 && DoseCalculator.isNeonate(totalMonths)) {
      _showResult(
        DoseResult.outOfRange(
          'This app is not designed for newborns (under 1 month). '
          'Please refer to a physician immediately.',
        ),
      );
      return;
    }

    // Age range check
    if (!DoseCalculator.isAgeInRange(widget.drug, totalMonths)) {
      final msg = widget.drug.referralTriggerText ??
          'This drug is not suitable for the patient\'s age.';
      _showResult(DoseResult.outOfRange(msg));
      return;
    }

    // Weight range check
    if (!DoseCalculator.isWeightInRange(widget.drug, weight)) {
      final msg = widget.drug.referralTriggerText ??
          'This weight is outside the safe range. Please verify or refer.';
      _showResult(DoseResult.outOfRange(msg));
      return;
    }

    setState(() => _isCalculating = true);

    final result = DoseCalculator.calculate(
      drug: widget.drug,
      weightKg: weight,
      ageMonths: totalMonths,
      concentrationIndex: widget.concentrationIndex,
    );

    setState(() => _isCalculating = false);

    _showResult(result);
  }

  void _showResult(DoseResult result) {
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          drug: widget.drug,
          result: result,
          weightKg: _weightKg ?? 0,
          ageMonths: _totalMonths,
          illnessName: widget.illness.nameEn,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    _yearsController.dispose();
    _monthsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        backgroundColor: AppTheme.lightSurface,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: AppBar(
            title: const Text('Patient Details'),
            backgroundColor: AppTheme.lightSurface,
            foregroundColor: AppTheme.lightInk,
            elevation: 0,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(0.5),
              child: Container(color: AppTheme.lightDivider, height: 0.5),
            ),
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            children: [
              // ── Weight section (top) ──────────────────────────
              const Text(
                'Weight',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightInkMuted,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.lightDivider),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _weightController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.lightInk,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'e.g. 12.5',
                          hintStyle: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.lightInkSubtle,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        validator: _validateWeight,
                      ),
                    ),
                    const Text(
                      'kg',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.lightInkMuted,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ── Age section (bottom) ──────────────────────────
              const Text(
                'Age',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightInkMuted,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _AgeField(
                      controller: _yearsController,
                      label: 'years',
                      hint: '0',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _AgeField(
                      controller: _monthsController,
                      label: 'months',
                      hint: '0',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Quick age presets
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _quickAges.map((preset) {
                  final (label, years, months) = preset;
                  final isActive =
                      _years == years && _months == months;
                  return GestureDetector(
                    onTap: () => _setAge(years, months),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppTheme.lightNavActive
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isActive
                              ? AppTheme.lightNavActive
                              : AppTheme.lightDivider,
                        ),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isActive
                              ? Colors.white
                              : AppTheme.lightInk,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),

              // ── Continue button ───────────────────────────────
              PrimaryButton(
                label: 'Continue',
                isLoading: _isCalculating,
                onPressed: _calculate,
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Age Text Field
// ═══════════════════════════════════════════════════════════════
class _AgeField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;

  const _AgeField({
    required this.controller,
    required this.label,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.lightDivider),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppTheme.lightInk,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.lightInkSubtle,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppTheme.lightInkMuted,
            ),
          ),
        ],
      ),
    );
  }
}
