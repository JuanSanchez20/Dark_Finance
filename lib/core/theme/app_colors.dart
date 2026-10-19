import 'package:flutter/material.dart';

/// Paleta de la app. Cualquier color nuevo se declara aquí, no en los widgets.
class AppColors {
  AppColors._();

  static const background = Color(0xFF000000);
  static const surface = Color(0xFF0D0D0D);
  static const surfaceAlt = Color(0xFF151515);
  static const line = Color(0xFF232323);

  static const text = Color(0xFFFAFAFA);
  static const muted = Color(0xFF8C8C8C);
  static const faint = Color(0xFF5A5A5A);

  static const income = Color(0xFF5EEAA0);
  static const warning = Color(0xFFF5B14C);
  static const danger = Color(0xFFF2766B);

  /// Tonos en escala de grises para distinguir las porciones del presupuesto.
  static const bucketShades = [
    Color(0xFFFAFAFA),
    Color(0xFFBDBDBD),
    Color(0xFF8A8A8A),
    Color(0xFF5E5E5E),
  ];
}
