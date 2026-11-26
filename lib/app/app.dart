import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
        title: 'Fastise',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.dark,
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
    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalInset = screenWidth < 360 ? 8.0 : 16.0;
    final bottomInset = screenWidth < 360 ? 6.0 : 12.0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayStyle,
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            HomeScreen(
              onProfileTap: () =>
                  setState(() => _selectedIndex = _profileIndex),
            ),
            const ProgressScreen(),
            const HistoryScreen(),
            const ProfileScreen(),
          ],
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalInset,
              4,
              horizontalInset,
              bottomInset,
            ),
            child: Align(
              heightFactor: 1,
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: AppColors.borderHighlight),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.38),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(26),
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
                          selectedIcon: const Icon(Icons.timer_rounded),
                          label: 'Home',
                        ),
                        const NavigationDestination(
                          icon: Icon(Icons.insights_outlined),
                          selectedIcon: Icon(Icons.insights_rounded),
                          label: 'Progress',
                        ),
                        const NavigationDestination(
                          icon: Icon(Icons.history_outlined),
                          selectedIcon: Icon(Icons.history_rounded),
                          label: 'History',
                        ),
                        const NavigationDestination(
                          icon: Icon(Icons.person_outline_rounded),
                          selectedIcon: Icon(Icons.person_rounded),
                          label: 'Profile',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
