/// Una porción del ingreso en un mes concreto (reparto 50/25/15/10).
class BudgetBucket {
  const BudgetBucket({
    required this.id,
    required this.definitionId,
    required this.name,
    required this.description,
    required this.percent,
    required this.spent,
  });

  /// Id de la porción dentro de ese mes (los gastos se enlazan a este id).
  final int id;

  /// Id de la porción "permanente" (Obligatorios, Gustos...). Es el mismo todos los meses.
  final int definitionId;
  final String name;
  final String description;
  final int percent;
  final double spent;

  /// Lo que le corresponde a la porción sobre el ingreso total del mes.
  double allocated(double income) => income * percent / 100;

  double remaining(double income) => allocated(income) - spent;

  double usedRatio(double income) {
    final total = allocated(income);
    return total == 0 ? 0 : spent / total;
  }
}
