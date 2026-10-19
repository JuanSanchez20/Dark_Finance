/// Convierte lo que escribe el usuario en un monto: "1200", "1200.50",
/// "1200,50" o "1.200,50". Devuelve null si no es un número válido.
double? parseMoney(String input) {
  var text = input.replaceAll(RegExp(r'[\s$]'), '');
  if (text.isEmpty) return null;

  if (text.contains(',')) {
    // Con coma, el punto es separador de miles y la coma el decimal.
    text = text.replaceAll('.', '').replaceAll(',', '.');
  }
  final value = double.tryParse(text);
  if (value == null || value.isNaN || value.isInfinite || value < 0) return null;
  return value;
}
