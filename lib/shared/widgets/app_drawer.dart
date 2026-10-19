import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../navigation/app_destinations.dart';
import '../navigation/app_navigation.dart';

/// Menú lateral (hamburguesa). Solo dibuja; qué opciones hay lo define
/// `app_destinations.dart` y cómo se navega, `app_navigation.dart`.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, required this.currentRoute});

  /// Ruta de la pantalla donde está el menú (para resaltar su opción).
  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Drawer(
      width: 300,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dark Finance', style: textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text('Control personal', style: textTheme.bodySmall),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              for (final destination in appDestinations)
                _DrawerTile(
                  destination: destination,
                  selected: destination.route == currentRoute,
                  onTap: () => navigateToDestination(
                    context,
                    destination,
                    currentRoute: currentRoute,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final AppDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.text : AppColors.muted;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: selected ? AppColors.surfaceAlt : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Row(
              children: [
                Icon(destination.icon, size: 22, color: color),
                const SizedBox(width: 14),
                Text(
                  destination.label,
                  style: TextStyle(
                    fontSize: 15,
                    color: color,
                    fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
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
