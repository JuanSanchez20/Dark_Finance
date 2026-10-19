/// Un ingreso único registrado (venta, trabajo extra, regalo...). Solo vale para su mes.
class IncomeEntry {
  const IncomeEntry({
    required this.id,
    required this.amount,
    required this.source,
    required this.date,
  });

  final int id;
  final double amount;

  /// De dónde viene ("Arreglé una computadora", "Venta de celular"...).
  final String source;
  final DateTime date;
}

/// Datos que el usuario escribe al registrar un ingreso único.
class NewIncome {
  const NewIncome({
    required this.amount,
    required this.source,
    required this.date,
  });

  final double amount;
  final String source;
  final DateTime date;
}
