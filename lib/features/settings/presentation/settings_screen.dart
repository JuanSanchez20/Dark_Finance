import 'package:flutter/material.dart';

import '../../../shared/navigation/app_routes.dart';
import '../../../shared/widgets/app_drawer.dart';

/// Pantalla de Ajustes. Por ahora vacía: el sueldo se define en Ingresos.
/// Cada ajuste futuro será una sección con su propio widget en este `ListView`.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      drawer: const AppDrawer(currentRoute: AppRoutes.settings),
      body: Center(
        child: Text('Aún no hay ajustes', style: textTheme.bodySmall),
      ),
    );
  }
}
