import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quoteflow/core/localization/app_localizations.dart';
import 'package:quoteflow/core/theme/app_theme.dart';
import 'package:quoteflow/features/favorites/presentation/favorites_screen.dart';
import 'package:quoteflow/features/home/presentation/home_screen.dart';
import 'package:quoteflow/features/settings/presentation/settings_screen.dart';
import 'package:quoteflow/shared/providers/auth_provider.dart';
import 'package:quoteflow/shared/widgets/app_logo.dart';
import 'package:quoteflow/shared/widgets/app_surface.dart';

part 'shell_navigation_rail.dart';

enum AppShellDestination { home, favorites, settings }

class AppShell extends StatefulWidget {
  final AppShellDestination initialDestination;

  const AppShell({
    super.key,
    this.initialDestination = AppShellDestination.home,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late AppShellDestination _selectedDestination;

  @override
  void initState() {
    super.initState();
    _selectedDestination = widget.initialDestination;
  }

  @override
  void didUpdateWidget(covariant AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDestination != oldWidget.initialDestination) {
      _selectedDestination = widget.initialDestination;
    }
  }

  void _selectDestination(int index) {
    final destination = AppShellDestination.values[index];
    if (destination == _selectedDestination) return;
    setState(() => _selectedDestination = destination);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < AppBreakpoints.compact;
    final destinations = <_ShellDestination>[
      _ShellDestination(
        l10n.dailyInspiration,
        Icons.home_outlined,
        Icons.home_rounded,
      ),
      _ShellDestination(
        l10n.favorites,
        Icons.favorite_border_rounded,
        Icons.favorite_rounded,
      ),
      _ShellDestination(
        l10n.settings,
        Icons.settings_outlined,
        Icons.settings_rounded,
      ),
    ];
    final content = IndexedStack(
      index: _selectedDestination.index,
      children: const [HomeScreen(), FavoritesScreen(), SettingsScreen()],
    );

    return Scaffold(
      body: isCompact
          ? content
          : Row(
              children: [
                _ShellNavigationRail(
                  destinations: destinations,
                  selectedDestination: _selectedDestination,
                  extended: width >= AppBreakpoints.expanded,
                  onSelected: _selectDestination,
                ),
                Expanded(child: content),
              ],
            ),
      bottomNavigationBar: isCompact
          ? NavigationBar(
              selectedIndex: _selectedDestination.index,
              onDestinationSelected: _selectDestination,
              destinations: [
                for (final destination in destinations)
                  NavigationDestination(
                    icon: Icon(destination.icon),
                    selectedIcon: Icon(destination.selectedIcon),
                    label: destination.label,
                  ),
              ],
            )
          : null,
    );
  }
}
