import 'package:flutter/material.dart';

import 'app_routes.dart';

/// Opción del menú lateral. Si [route] es null, la pantalla aún no existe
/// y el menú muestra "próximamente".
class AppDestination {
  const AppDestination(this.label, this.icon, {this.route});

  final String label;
  final IconData icon;
  final String? route;
}

/// Opciones del menú lateral. Para agregar o quitar una, edita solo esta lista.
const appDestinations = [
  AppDestination('Resumen', Icons.grid_view_rounded, route: AppRoutes.home),
  AppDestination('Ingresos', Icons.south_west_rounded, route: AppRoutes.incomes),
  AppDestination('Movimientos', Icons.receipt_long_outlined),
  AppDestination('Presupuesto', Icons.pie_chart_outline_rounded),
  AppDestination('Metas', Icons.flag_outlined),
  AppDestination('Categorías', Icons.label_outline_rounded, route: AppRoutes.categories),
  AppDestination('Ajustes', Icons.settings_outlined, route: AppRoutes.settings),
];
