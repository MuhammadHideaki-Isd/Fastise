import 'package:flutter/material.dart';

import '../features/fasting/application/fasting_controller.dart';
import '../features/fasting/application/fasting_scope.dart';
import '../features/history/presentation/history_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/progress/presentation/progress_screen.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

class FastiseApp extends StatelessWidget {
  const FastiseApp({super.key, required this.controller});

  final FastingController controller;

  @override
  Widget build(BuildContext context) {
    return FastingScope(
      controller: controller,
      child: MaterialApp(
        title: 'Fasting Tracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const AppShell(),
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  static const _profileIndex = 3;

  @override
  Widget build(BuildContext context) {
    final isFasting = FastingScope.of(context).isFasting;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomeScreen(
            onProfileTap: () => setState(() => _selectedIndex = _profileIndex),
          ),
          const ProgressScreen(),
          const HistoryScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() => _selectedIndex = index);
          },
          destinations: [
            NavigationDestination(
              icon: Badge(
                isLabelVisible: isFasting && _selectedIndex != 0,
                backgroundColor: AppColors.primary,
                smallSize: 8,
                child: const Icon(Icons.timer_outlined),
              ),
              selectedIcon: const Icon(Icons.timer),
              label: 'Home',
            ),
            const NavigationDestination(
              icon: Icon(Icons.insights_outlined),
              selectedIcon: Icon(Icons.insights),
              label: 'Progress',
            ),
            const NavigationDestination(
              icon: Icon(Icons.history_outlined),
              selectedIcon: Icon(Icons.history),
              label: 'History',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
