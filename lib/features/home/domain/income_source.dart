/// De dónde viene una parte del ingreso del mes (sueldo base, venta, bono...).
class IncomeSource {
  const IncomeSource({required this.label, required this.amount});

  final String label;
  final double amount;
}
