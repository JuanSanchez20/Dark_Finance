/// Ingreso fijo que se suma al sueldo todos los meses mientras esté activo
/// (bono, transporte incluido...). No tiene fecha.
class RecurringIncome {
  const RecurringIncome({
    required this.id,
    required this.name,
    required this.amount,
    required this.isActive,
  });

  final int id;
  final String name;
  final double amount;
  final bool isActive;
}

/// Datos que el usuario escribe al crear o editar un ingreso fijo.
class RecurringIncomeDraft {
  const RecurringIncomeDraft({required this.name, required this.amount});

  final String name;
  final double amount;
}
