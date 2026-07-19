import 'package:flutter/material.dart';
import '../widgets/app_theme.dart';
import '../widgets/primary_button.dart';
import '../widgets/out_of_range_view.dart';
import '../models/illness.dart';
import '../models/drug.dart';
import '../services/data_loader.dart';
import '../services/dose_calculator.dart';

/// Age + Weight entry screen — light theme.
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
    _availableDrugs = widget.data.getDrugsForIllness(widget.illnessId);
    if (_availableDrugs.isNotEmpty) {
      _selectedDrugId = _availableDrugs.first.id;
      _updateDrugOptions();
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  int get _totalMonths => _years * 12 + _months;

  double? get _weightKg {
    final text = _weightController.text.trim();
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }

  void _updateDrugOptions() {
    final totalMonths = _totalMonths;

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

    final filtered = widget.data.getDrugsForIllness(widget.illnessId).where((drug) {
      if (totalMonths > 0) {
        return DoseCalculator.isAgeInRange(drug, totalMonths);
      }
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

    if (totalMonths > 0 && !DoseCalculator.isAgeInRange(drug, totalMonths)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This drug is not suitable for the patient\'s age.'),
        ),
      );
      return;
    }

    setState(() => _isCalculating = true);

    final result = DoseCalculator.calculate(
      drug: drug,
      weightKg: weight,
      ageMonths: totalMonths,
      concentrationIndex: _selectedConcentrationIndex,
    );

    setState(() => _isCalculating = false);

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

    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        backgroundColor: AppTheme.lightSurface,
        appBar: AppBar(
          title: Text(illness?.nameEn ?? 'Calculate Dose'),
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // -- Neonatal gate --
                if (_isNeonate == true && _neonatalMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: OutOfRangeView(message: _neonatalMessage!),
                  ),

                // -- Age section --
                _LightCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Patient Age',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.lightInkMuted)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
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
                          const SizedBox(width: 16),
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
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // -- Weight section --
                _LightCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Weight (kg)',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.lightInkMuted)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _weightController,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(
                          fontSize: 20,
                          color: AppTheme.lightInk,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText: 'e.g. 12.5',
                          hintStyle: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.lightInkSubtle,
                          ),
                          suffixText: 'kg',
                          suffixStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.lightInkMuted,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: AppTheme.lightDivider, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: AppTheme.lightDivider, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: AppTheme.lightNavActive, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                        validator: _validateWeight,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // -- Drug selection --
                _LightCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Select Drug',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.lightInkMuted)),
                      const SizedBox(height: 8),

                      if (_availableDrugs.isEmpty && _isNeonate != true)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            'No suitable drugs available for this age.',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.lightInkMuted,
                            ),
                          ),
                        ),

                      ..._availableDrugs.map((drug) {
                        final isSelected = drug.id == _selectedDrugId;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedDrugId = drug.id;
                                _selectedConcentrationIndex = 0;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.lightNavActive.withValues(alpha: 0.08)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.lightNavActive
                                      : AppTheme.lightDivider,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              drug.drugNameEn,
                                              style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w600,
                                                color: isSelected
                                                    ? AppTheme.lightNavActive
                                                    : AppTheme.lightInk,
                                              ),
                                            ),
                                            if (drug.isRecommended)
                                              const Padding(
                                                padding: EdgeInsets.only(left: 8),
                                                child: _RecommendedBadge(),
                                              ),
                                          ],
                                        ),
                                        if (drug.notes != null &&
                                            drug.notes!.contains('VERIFY'))
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4),
                                            child: Text(
                                              drug.notes!,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: AppTheme.lightInkMuted,
                                              ),
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
                                        ? AppTheme.lightNavActive
                                        : AppTheme.lightInkSubtle,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                // -- Concentration selection --
                if (_selectedDrug != null &&
                    _selectedDrug!.concentrations != null &&
                    _selectedDrug!.concentrations!.length > 1) ...[
                  const SizedBox(height: 16),
                  _LightCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Concentration',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.lightInkMuted)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(
                            _selectedDrug!.concentrations!.length,
                            (index) {
                              final conc =
                                  _selectedDrug!.concentrations![index];
                              final isSelected =
                                  index == _selectedConcentrationIndex;
                              return ChoiceChip(
                                label: Text(conc.labelEn),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() =>
                                        _selectedConcentrationIndex = index);
                                  }
                                },
                                selectedColor:
                                    AppTheme.lightNavActive.withValues(alpha: 0.15),
                                backgroundColor: Colors.white,
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? AppTheme.lightNavActive
                                      : AppTheme.lightInkMuted,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                                side: BorderSide(
                                  color: isSelected
                                      ? AppTheme.lightNavActive
                                      : AppTheme.lightDivider,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Calculate button
                if (_isNeonate != true)
                  PrimaryButton(
                    label: 'Calculate Dose',
                    isLoading: _isCalculating,
                    onPressed: _calculate,
                  ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Light card wrapper ─────────────────────────────────────────

class _LightCard extends StatelessWidget {
  final Widget child;
  const _LightCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lightCardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

// ── Age stepper ────────────────────────────────────────────────

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
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.lightInkMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
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
                        ? AppTheme.lightNavActive.withValues(alpha: 0.12)
                        : AppTheme.lightCardBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: value > min
                          ? AppTheme.lightNavActive.withValues(alpha: 0.3)
                          : AppTheme.lightDivider,
                    ),
                  ),
                  child: Icon(Icons.remove,
                      size: 20,
                      color: value > min
                          ? AppTheme.lightNavActive
                          : AppTheme.lightInkSubtle),
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
                    color: AppTheme.lightInk,
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
                        ? AppTheme.lightNavActive.withValues(alpha: 0.12)
                        : AppTheme.lightCardBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: value < max
                          ? AppTheme.lightNavActive.withValues(alpha: 0.3)
                          : AppTheme.lightDivider,
                    ),
                  ),
                  child: Icon(Icons.add,
                      size: 20,
                      color: value < max
                          ? AppTheme.lightNavActive
                          : AppTheme.lightInkSubtle),
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
        color: AppTheme.lightNavActive.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'Recommended',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppTheme.lightNavActive,
        ),
      ),
    );
  }
}
