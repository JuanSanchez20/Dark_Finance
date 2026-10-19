import '../../budget/domain/budget_bucket.dart';

/// Desde cuándo rige el nuevo sueldo.
enum IncomeEffect { thisMonth, nextMonth }

/// Estado del sueldo, para mostrarlo en Ajustes.
class IncomeOverview {
  const IncomeOverview({
    required this.currentIncome,
    required this.hasTransactions,
    this.pendingNextMonthIncome,
  });

  final double currentIncome;

  /// Sueldo ya programado para el mes siguiente (null si no hay cambio pendiente).
  final double? pendingNextMonthIncome;

  /// Si el mes actual ya tiene gastos registrados (define si hay que preguntar
  /// "¿este mes o el próximo?").
  final bool hasTransactions;
}

/// Una porción donde lo gastado supera lo que permite el nuevo sueldo.
class BucketOverspend {
  const BucketOverspend({required this.bucketName, required this.excess});

  final String bucketName;
  final double excess;
}

class IncomeChangeResult {
  const IncomeChangeResult({required this.effect, required this.overspends});

  final IncomeEffect effect;
  final List<BucketOverspend> overspends;
}

/// Porciones que quedan excedidas si el sueldo pasa a [income].
List<BucketOverspend> findOverspends(
  double income,
  List<BudgetBucket> buckets,
) {
  return [
    for (final bucket in buckets)
      if (bucket.spent - bucket.allocated(income) > 0.005)
        BucketOverspend(
          bucketName: bucket.name,
          excess: bucket.spent - bucket.allocated(income),
        ),
  ];
}
