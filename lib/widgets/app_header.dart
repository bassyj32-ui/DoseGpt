import 'package:flutter/material.dart';

/// Reusable screen header with title and optional back button.
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;

  const AppHeader({
    super.key,
    required this.title,
    this.showBack = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
