import 'dart:ui';

/// Convierte "#FF6B6B" en un [Color]. Si el texto no es válido devuelve [fallback].
Color colorFromHex(String hex, {Color fallback = const Color(0xFF8C8C8C)}) {
  final clean = hex.replaceAll('#', '');
  if (clean.length != 6) return fallback;
  final value = int.tryParse(clean, radix: 16);
  return value == null ? fallback : Color(0xFF000000 | value);
}
