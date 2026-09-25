part of 'app_shell.dart';

class _ShellDestination {
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const _ShellDestination(this.label, this.icon, this.selectedIcon);
}

class _ShellNavigationRail extends StatelessWidget {
  final List<_ShellDestination> destinations;
  final AppShellDestination selectedDestination;
  final bool extended;
  final ValueChanged<int> onSelected;

  const _ShellNavigationRail({
    required this.destinations,
    required this.selectedDestination,
    required this.extended,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return NavigationRail(
      selectedIndex: selectedDestination.index,
      onDestinationSelected: onSelected,
      labelType: extended
          ? NavigationRailLabelType.none
          : NavigationRailLabelType.all,
      leading: const _ShellProfile(),
      backgroundColor: colorScheme.surfaceContainerLow,
      indicatorColor: colorScheme.primaryContainer,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      selectedIconTheme: IconThemeData(
        color: colorScheme.primary,
        size: AppSizes.iconMd,
      ),
      unselectedIconTheme: IconThemeData(
        color: colorScheme.onSurfaceVariant,
        size: AppSizes.iconMd,
      ),
      selectedLabelTextStyle: textTheme.labelSmall?.copyWith(
        color: colorScheme.primary,
      ),
      unselectedLabelTextStyle: textTheme.labelSmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      destinations: [
        for (final destination in destinations)
          NavigationRailDestination(
            icon: Icon(destination.icon),
            selectedIcon: Icon(destination.selectedIcon),
            label: Text(destination.label),
          ),
      ],
    );
  }
}

class _ShellProfile extends StatelessWidget {
  const _ShellProfile();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final auth = context.watch<AuthProvider>();
    final name = auth.displayName.isNotEmpty ? auth.displayName : l10n.guest;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Semantics(
        container: true,
        label: '${l10n.profile}: $name',
        child: ExcludeSemantics(
          child: AppSurface(
            level: AppSurfaceLevel.outlined,
            size: AppSurfaceSize.compact,
            padding: const EdgeInsets.all(AppSpacing.xs),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppLogo(size: AppSizes.logoSm),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  name,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
