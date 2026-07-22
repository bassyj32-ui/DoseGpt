import 'package:flutter/material.dart';
import 'app_theme.dart';

/// A compact reference card showing normal pediatric vital sign ranges
/// by age group. Designed to be placed as a quick-reference info box
/// on the home screen or accessible from the pediatrics tab.
class VitalsReferenceCard extends StatefulWidget {
  const VitalsReferenceCard({super.key});

  @override
  State<VitalsReferenceCard> createState() => _VitalsReferenceCardState();
}

class _VitalsReferenceCardState extends State<VitalsReferenceCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _expandCtrl;
  late Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _expandCtrl = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnim = CurvedAnimation(
      parent: _expandCtrl,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _expandCtrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _expandCtrl.forward();
      } else {
        _expandCtrl.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.lightDivider.withValues(alpha: 0.5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Header — always visible ─────────────────────
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_border,
                      color: AppTheme.primary,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Normal Vital Signs (Pediatric)',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.lightInk,
                    ),
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: AppTheme.lightInkMuted,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Expanded vitals table ───────────────────────
          SizeTransition(
            sizeFactor: _expandAnim,
            axisAlignment: -1.0,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  _vitalsTable(),
                  const SizedBox(height: 8),
                  Text(
                    'Source: WHO IMCI / PALS / AAP guidelines.\n'
                    'Reference only — clinical judgment always takes priority.',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.lightInkMuted,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _vitalsTable() {
    const data = [
      _VitalRow('Newborn', '120-160', '30-60', 'III 60-90 / D 30-60', '36.5-37.5'),
      _VitalRow('Infant (1-12mo)', '100-140', '25-50', 'III 70-100 / D 50-70', '36.5-37.5'),
      _VitalRow('Toddler (1-3yr)', '90-120', '22-35', 'III 80-110 / D 50-70', '36.5-37.5'),
      _VitalRow('Preschool (3-5yr)', '80-110', '20-30', 'III 80-110 / D 55-70', '36.5-37.5'),
      _VitalRow('School (6-12yr)', '70-100', '16-25', 'III 90-120 / D 60-80', '36.5-37.5'),
      _VitalRow('Adolescent (13-18yr)', '60-90', '12-20', 'III 110-130 / D 65-85', '36.5-37.5'),
    ];

    return Table(
      border: TableBorder(
        horizontalInside: BorderSide(
          color: AppTheme.lightDivider.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      columnWidths: const {
        0: FlexColumnWidth(2.2),
        1: FlexColumnWidth(1.5),
        2: FlexColumnWidth(1.3),
        3: FlexColumnWidth(2.5),
        4: FlexColumnWidth(1.5),
      },
      children: [
        // Header row
        TableRow(
          children: [
            _headerCell('Age'),
            _headerCell('HR\n(/min)'),
            _headerCell('RR\n(/min)'),
            _headerCell('BP (mmHg)\nSystolic / Diastolic'),
            _headerCell('Temp\n(°C)'),
          ],
        ),
        // Data rows
        for (final row in data)
          TableRow(
            children: [
              _dataCell(row.age),
              _dataCell(row.hr),
              _dataCell(row.rr),
              _dataCell(row.bp),
              _dataCell(row.temp),
            ],
          ),
      ],
    );
  }

  Widget _headerCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: AppTheme.lightInkMuted,
          height: 1.3,
        ),
      ),
    );
  }

  Widget _dataCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          color: AppTheme.lightInk,
          height: 1.3,
        ),
      ),
    );
  }
}

class _VitalRow {
  final String age;
  final String hr;
  final String rr;
  final String bp;
  final String temp;

  const _VitalRow(this.age, this.hr, this.rr, this.bp, this.temp);
}
