import 'package:flutter/material.dart';
import '../widgets/app_theme.dart';
import '../services/data_loader.dart';
import 'home_screen.dart';
import 'reference_screen.dart';

/// Main Navigation Shell
///
/// Clean, minimal shell with a subtle top bar and soft bottom navigation.
/// The app bar blends into the background — no elevation, no dividing lines.
/// The bottom nav uses 11px labels with gentle icon outlines.
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
    return Scaffold(
      backgroundColor: AppTheme.surface,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'DoseGPT',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.ink,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_outlined, size: 22),
            onPressed: () {},
            tooltip: 'Search',
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(data: widget.data),
          const ReferenceScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppTheme.borderHairline.withValues(alpha: 0.4),
              width: 0.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: AppTheme.surface,
          selectedItemColor: AppTheme.ink,
          unselectedItemColor: AppTheme.inkSubtle,
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
    );
  }
}
