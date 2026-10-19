import 'package:flutter/material.dart';

import 'app_destinations.dart';

/// Acción al tocar una opción del menú lateral: cierra el menú y abre la pantalla
/// (o avisa "próximamente" si aún no existe).
void navigateToDestination(
  BuildContext context,
  AppDestination destination, {
  required String currentRoute,
}) {
  final navigator = Navigator.of(context);
  final messenger = ScaffoldMessenger.of(context);
  navigator.pop(); // cierra el menú

  final route = destination.route;
  if (route == null) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('${destination.label}: próximamente')));
    return;
  }
  if (route == currentRoute) return;
  navigator.pushReplacementNamed(route);
}
