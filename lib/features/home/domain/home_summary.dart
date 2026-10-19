import '../../budget/domain/budget_bucket.dart';
import 'income_source.dart';
import 'recent_transaction.dart';

/// Todo lo que necesita la pantalla de Resumen.
class HomeSummary {
  const HomeSummary({
    required this.totalIncome,
    required this.buckets,
    required this.incomeSources,
    required this.recentTransactions,
    required this.daysElapsed,
    required this.daysInMonth,
  });

  /// Sueldo base + ingresos fijos + ingresos únicos del mes: todo se reparte en 50/25/15/10.
  final double totalIncome;
  final List<BudgetBucket> buckets;
  final List<IncomeSource> incomeSources;
  final List<RecentTransaction> recentTransactions;
  final int daysElapsed;
  final int daysInMonth;

  double get totalSpent => buckets.fold(0, (sum, b) => sum + b.spent);
  double get available => totalIncome - totalSpent;

  /// Qué parte del ingreso total ya se gastó (0 si aún no hay ingresos).
  double get spentRatio => totalIncome == 0 ? 0 : totalSpent / totalIncome;
}
