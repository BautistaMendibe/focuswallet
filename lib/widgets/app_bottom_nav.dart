import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF009792),
      unselectedItemColor: Colors.grey,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.dashboard),
          label: loc.navDashboard,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.bar_chart),
          label: loc.navSummary,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.timer),
          label: loc.navBudget,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.settings),
          label: loc.navSettings,
        ),
      ],
    );
  }
} 