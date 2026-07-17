import 'package:flutter/material.dart';
import '../widgets/app_theme.dart';
import '../widgets/primary_button.dart';
import '../widgets/out_of_range_view.dart';
import '../models/illness.dart';
import '../models/drug.dart';
import '../services/data_loader.dart';
import '../services/dose_calculator.dart';

/// Age + Weight entry screen.
/// Collects age (years + months), weight (kg), selects a drug,
/// and optionally a concentration, then calculates the dose.
class WeightEntryScreen extends StatefulWidget {
  final ClinicalData data;
  final String illnessId;

  const WeightEntryScreen({
    super.key,
    required this.data,
    required this.illnessId,
  });

  @override
  State<WeightEntryScreen> createState() => _WeightEntryScreenState();
}

class _WeightEntryScreenState extends State<WeightEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();

  int _years = 0;
  int _months = 0;
  String? _selectedDrugId;
  int _selectedConcentrationIndex = 0;
  bool _isCalculating = false;

  // UI state
  bool? _isNeonate;
  String? _neonatalMessage;
  List<Drug> _availableDrugs = [];

  Illness? get _illness => widget.data.getIllness(widget.illnessId);

  @override
  void initState() {
    super.initState();
    // Load available drugs for this illness
    _availableDrugs = widget.data.getDrugsForIllness(widget.illnessId);
    if (_availableDrugs.isNotEmpty) {
      _selectedDrugId = _availableDrugs.first.id;
      // Check if the first drug passes age gates
      _updateDrugOptions();
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  /// Get total age in months.
  int get _totalMonths => _years * 12 + _months;

  /// Get weight in kg (null if empty or invalid).
  double? get _weightKg {
    final text = _weightController.text.trim();
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }

  /// Filter drugs based on age, and update selected drug if needed.
  void _updateDrugOptions() {
    final totalMonths = _totalMonths;

    // Check neonatal gate first
    if (totalMonths > 0 && DoseCalculator.isNeonate(totalMonths)) {
      setState(() {
        _isNeonate = true;
        _neonatalMessage =
            'This app is not designed for newborns. Please refer to a physician immediately.';
        _availableDrugs = [];
        _selectedDrugId = null;
      });
      return;
    }

    setState(() {
      _isNeonate = false;
      _neonatalMessage = null;
    });

    // Filter drugs by valid_age_range
    final filtered = widget.data.getDrugsForIllness(widget.illnessId).where((drug) {
      // For neonate drugs, we already handled above
      // Check age range if age has been entered
      if (totalMonths > 0) {
        return DoseCalculator.isAgeInRange(drug, totalMonths);
      }
      // If no age entered yet, show all drugs (will filter on submit)
      return true;
    }).toList();

    setState(() {
      _availableDrugs = filtered;
      if (_availableDrugs.isNotEmpty) {
        if (!_availableDrugs.any((d) => d.id == _selectedDrugId)) {
          _selectedDrugId = _availableDrugs.first.id;
        }
      } else {
        _selectedDrugId = null;
      }
    });
  }

  String? _validateWeight(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter the child\'s weight';
    }
    final kg = double.tryParse(value.trim());
    if (kg == null || kg <= 0) {
      return 'Please enter a valid weight';
    }
    if (kg > 120) {
      return 'Please enter a realistic weight';
    }
    return null;
  }

  void _onAgeChanged() {
    if (_totalMonths > 0) {
      _updateDrugOptions();
    }
  }

  Future<void> _calculate() async {
    if (!_formKey.currentState!.validate()) return;

    final weight = _weightKg;
    if (weight == null) return;

    final totalMonths = _totalMonths;

    // Neonatal gate (shouldn't reach here, but double-check)
    if (totalMonths > 0 && DoseCalculator.isNeonate(totalMonths)) {
      setState(() {
        _isNeonate = true;
        _neonatalMessage =
            'This app is not designed for newborns. Please refer to a physician immediately.';
      });
      return;
    }

    if (_selectedDrugId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No suitable drug available for this age.')),
      );
      return;
    }

    final drug = widget.data.getDrug(_selectedDrugId!);
    if (drug == null) return;

    // Age gate for the selected drug
    if (totalMonths > 0 && !DoseCalculator.isAgeInRange(drug, totalMonths)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This drug is not suitable for the patient\'s age.'),
        ),
      );
      return;
    }

    setState(() => _isCalculating = true);

    // Calculate
    final result = DoseCalculator.calculate(
      drug: drug,
      weightKg: weight,
      ageMonths: totalMonths,
      concentrationIndex: _selectedConcentrationIndex,
    );

    setState(() => _isCalculating = false);

    // Navigate to result screen
    if (mounted) {
      Navigator.of(context).pushNamed(
        '/result',
        arguments: {
          'drug': drug,
          'result': result,
          'weightKg': weight,
          'ageMonths': totalMonths,
          'illnessName': _illness?.nameEn ?? '',
        },
      );
    }
  }

  Drug? get _selectedDrug =>
      _selectedDrugId != null ? widget.data.getDrug(_selectedDrugId!) : null;

  @override
  Widget build(BuildContext context) {
    final illness = _illness;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: Text(illness?.nameEn ?? 'Dose Calculation'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -- Neonatal gate message --
              if (_isNeonate == true && _neonatalMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                  child: OutOfRangeView(message: _neonatalMessage!),
                ),

              // -- Age input: Years + Months --
              const Text('Patient Age', style: AppTheme.cardLabel),
              const SizedBox(height: AppTheme.spacingSm),
              Row(
                children: [
                  // Years
                  Expanded(
                    child: _AgeStepper(
                      label: 'Years',
                      value: _years,
                      min: 0,
                      max: 18,
                      onChanged: (v) {
                        setState(() => _years = v);
                        _onAgeChanged();
                      },
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  // Months
                  Expanded(
                    child: _AgeStepper(
                      label: 'Months',
                      value: _months,
                      min: 0,
                      max: 11,
                      onChanged: (v) {
                        setState(() => _months = v);
                        _onAgeChanged();
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppTheme.spacingLg),

              // -- Weight input --
              const Text('Weight (kg)', style: AppTheme.cardLabel),
              const SizedBox(height: AppTheme.spacingSm),
              TextFormField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  hintText: 'e.g. 12.5',
                  suffixText: 'kg',
                ),
                validator: _validateWeight,
              ),

              const SizedBox(height: AppTheme.spacingLg),

              // -- Drug selection (filtered by age) --
              const Text('Select Drug', style: AppTheme.cardLabel),
              const SizedBox(height: AppTheme.spacingSm),

              if (_availableDrugs.isEmpty && _isNeonate != true)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
                  child: Text(
                    'No suitable drugs available for this age.',
                    style: AppTheme.formulaSource,
                  ),
                ),

              ..._availableDrugs.map((drug) {
                final isSelected = drug.id == _selectedDrugId;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDrugId = drug.id;
                        _selectedConcentrationIndex = 0;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(AppTheme.spacingMd),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primary.withValues(alpha: 0.08)
                            : AppTheme.surfaceCard,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primary
                              : AppTheme.borderHairline,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      drug.drugNameEn,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.ink,
                                      ),
                                    ),
                                    if (drug.isRecommended)
                                      const Padding(
                                        padding: EdgeInsets.only(left: 8),
                                        child: _RecommendedBadge(),
                                      ),
                                  ],
                                ),
                                if (drug.notes != null && drug.notes!.contains('VERIFY'))
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      drug.notes!,
                                      style: AppTheme.formulaSource,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: isSelected
                                ? AppTheme.primary
                                : AppTheme.inkMuted,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              // -- Concentration selection --
              if (_selectedDrug != null &&
                  _selectedDrug!.concentrations != null &&
                  _selectedDrug!.concentrations!.length > 1) ...[
                const SizedBox(height: AppTheme.spacingMd),
                const Text('Concentration', style: AppTheme.cardLabel),
                const SizedBox(height: AppTheme.spacingSm),
                Wrap(
                  spacing: AppTheme.spacingSm,
                  runSpacing: AppTheme.spacingSm,
                  children: List.generate(
                    _selectedDrug!.concentrations!.length,
                    (index) {
                      final conc = _selectedDrug!.concentrations![index];
                      final isSelected = index == _selectedConcentrationIndex;
                      return ChoiceChip(
                        label: Text(conc.labelEn),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedConcentrationIndex = index);
                          }
                        },
                        selectedColor: AppTheme.primary.withValues(alpha: 0.15),
                        backgroundColor: AppTheme.surfaceCard,
                        labelStyle: TextStyle(
                          color: isSelected ? AppTheme.primary : AppTheme.ink,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                        side: BorderSide(
                          color: isSelected ? AppTheme.primary : AppTheme.borderHairline,
                        ),
                      );
                    },
                  ),
                ),
              ],

              const SizedBox(height: AppTheme.spacingLg),

              // Calculate button — only show when NOT in neonatal block
              if (_isNeonate != true)
                PrimaryButton(
                  label: 'Calculate Dose',
                  isLoading: _isCalculating,
                  onPressed: _calculate,
                ),

              const SizedBox(height: AppTheme.spacingMd),
            ],
          ),
        ),
      ),
    );
  }
}

/// A stepper widget for age input (years or months).
class _AgeStepper extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _AgeStepper({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingSm),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(
        children: [
          Text(label, style: AppTheme.formulaSource),
          const SizedBox(height: AppTheme.spacingXs),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: value > min ? () => onChanged(value - 1) : null,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: value > min
                        ? AppTheme.primary.withValues(alpha: 0.1)
                        : AppTheme.borderHairline,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: const Icon(Icons.remove, size: 20, color: AppTheme.ink),
                ),
              ),
              SizedBox(
                width: 48,
                child: Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.ink,
                  ),
                ),
              ),
              GestureDetector(
                onTap: value < max ? () => onChanged(value + 1) : null,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: value < max
                        ? AppTheme.primary.withValues(alpha: 0.1)
                        : AppTheme.borderHairline,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: const Icon(Icons.add, size: 20, color: AppTheme.ink),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecommendedBadge extends StatelessWidget {
  const _RecommendedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.accentGold.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'Recommended',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppTheme.accentGold,
        ),
      ),
    );
  }
}
