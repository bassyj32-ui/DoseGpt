import 'package:flutter/material.dart';
import '../widgets/app_theme.dart';
import '../services/data_loader.dart';
import 'home_screen.dart';
import 'reference_screen.dart';

/// Main Navigation Shell — Light Mode
///
/// Apple Health-inspired:
///   - Pure white scaffold background
///   - "DoseGPT" header text only (no icons)
///   - Thin hairline divider below header
///   - Clean bottom nav bar with green/grey tabs
class MainShell extends StatefulWidget {
  final ClinicalData data;

  const MainShell({super.key, required this.data});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        backgroundColor: AppTheme.lightSurface,
        body: SafeArea(
          child: Column(
            children: [
              // ── Header ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'DoseGPT',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.lightInk,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ),

              // ── Hairline divider ───────────────────────────
              Container(
                margin: const EdgeInsets.only(top: 12),
                height: 0.5,
                color: AppTheme.lightDivider,
              ),

              // ── Body (Home / Reference) ───────────────────
              Expanded(
                child: IndexedStack(
                  index: _currentIndex,
                  children: [
                    HomeScreen(data: widget.data),
                    const ReferenceScreen(),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: AppTheme.lightDivider,
                width: 0.5,
              ),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            backgroundColor: AppTheme.lightSurface,
            selectedItemColor: AppTheme.lightNavActive,
            unselectedItemColor: AppTheme.lightNavInactive,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            selectedLabelStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.2,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined, size: 22),
                activeIcon: Icon(Icons.home, size: 22),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.library_books_outlined, size: 22),
                activeIcon: Icon(Icons.library_books, size: 22),
                label: 'Reference',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
