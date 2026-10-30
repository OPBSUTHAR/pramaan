import 'package:flutter/material.dart';

import 'core/l10n/l10n.dart';
import 'core/theme/app_colors.dart';
import 'features/emergency/presentation/emergency_screen.dart';
import 'features/history/presentation/history_screen.dart';
import 'features/learn/presentation/learn_screen.dart';
import 'features/scan/presentation/scan_screen.dart';
import 'features/upi/presentation/upi_screen.dart';

/// The five places a user ever needs to be.
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  static const List<Widget> _tabs = [
    ScanScreen(),
    UpiScreen(),
    LearnScreen(),
    EmergencyScreen(),
    HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.inkLine)),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (value) => setState(() => _index = value),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.shield_outlined),
              selectedIcon: const Icon(Icons.shield),
              label: context.t('nav.scan'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.qr_code_scanner_outlined),
              selectedIcon: const Icon(Icons.qr_code_scanner),
              label: context.t('nav.upi'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.menu_book_outlined),
              selectedIcon: const Icon(Icons.menu_book),
              label: context.t('nav.learn'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.sos_outlined),
              selectedIcon: const Icon(Icons.sos),
              label: context.t('nav.emergency'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.history_outlined),
              selectedIcon: const Icon(Icons.history),
              label: context.t('nav.history'),
            ),
          ],
        ),
      ),
    );
  }
}
