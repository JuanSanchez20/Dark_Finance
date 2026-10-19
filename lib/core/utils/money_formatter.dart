/// Formatea un monto como "$1.284,50" (miles con punto, decimales con coma).
String formatMoney(double value, {bool showSign = false}) {
  final negative = value < 0;
  final parts = value.abs().toStringAsFixed(2).split('.');
  final integer = parts[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => '.',
  );
  final sign = negative ? '-' : (showSign ? '+' : '');
  return '$sign\$$integer,${parts[1]}';
}
