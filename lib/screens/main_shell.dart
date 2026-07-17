import 'package:flutter/material.dart';
import '../widgets/app_theme.dart';
import '../services/data_loader.dart';
import 'home_screen.dart';
import 'reference_screen.dart';

/// Main navigation shell with persistent bottom nav bar.
/// Provides the Scaffold, AppBar, and BottomNavigationBar.
/// Contains Home and Reference tabs.
class MainShell extends StatefulWidget {
  final ClinicalData data;

  const MainShell({super.key, required this.data});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const _titles = ['DoseGPT', 'Reference'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: Text(
          _titles[_currentIndex],
          style: AppTheme.screenTitle,
        ),
        centerTitle: false,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(data: widget.data),
          const ReferenceScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books_outlined),
            activeIcon: Icon(Icons.library_books),
            label: 'Reference',
          ),
        ],
      ),
    );
  }
}
