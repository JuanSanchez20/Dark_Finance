import '../../../core/database/app_database.dart';
import '../../../core/database/tables/enums.dart';
import '../../budget/data/budget_periods_gateway.dart';
import '../../budget/domain/budget_bucket.dart';
import '../domain/home_summary.dart';
import '../domain/income_source.dart';
import '../domain/recent_transaction.dart';
import 'home_summary_repository.dart';

/// Arma el Resumen con los datos reales de la base local.
class DriftHomeSummaryRepository implements HomeSummaryRepository {
  DriftHomeSummaryRepository(this._db, this._periods);

  static const _recentLimit = 10;

  final AppDatabase _db;
  final BudgetPeriodsGateway _periods;

  @override
  Future<HomeSummary> load() async {
    final period = await _periods.ensureCurrent();
    final buckets = await _periods.bucketsWithSpent(period.id);
    final transactions = await _db.transactionsDao.byPeriod(period.id); // más nuevas primero
    final extraIncome = await _periods.extraIncomeTotal(period.id);
    final today = _periods.now;

    return HomeSummary(
      totalIncome: period.income + extraIncome,
      buckets: buckets,
      incomeSources: _incomeSources(period.income, transactions),
      recentTransactions: await _recentExpenses(buckets, transactions),
      daysElapsed: today.day,
      daysInMonth: DateTime(today.year, today.month + 1, 0).day,
    );
  }

  /// Sueldo base + cada origen de ingreso extra (los repetidos se suman).
  List<IncomeSource> _incomeSources(double baseIncome, List<Transaction> transactions) {
    final totals = <String, double>{};
    for (final t in transactions.where((t) => t.type == TransactionType.income)) {
      totals[t.description] = (totals[t.description] ?? 0) + t.amount;
    }
    return [
      if (baseIncome > 0) IncomeSource(label: 'Sueldo base', amount: baseIncome),
      for (final entry in totals.entries)
        IncomeSource(label: entry.key, amount: entry.value),
    ];
  }

  Future<List<RecentTransaction>> _recentExpenses(
    List<BudgetBucket> buckets,
    List<Transaction> transactions,
  ) async {
    final categories = {
      for (final c in await _db.categoriesDao.allCategories()) c.id: c.name,
    };
    final bucketNames = {for (final b in buckets) b.id: b.name};

    return [
      for (final t in transactions
          .where((t) => t.type != TransactionType.income)
          .take(_recentLimit))
        RecentTransaction(
          id: t.id,
          amount: t.amount,
          description: t.description,
          merchant: t.merchant,
          bucketName: bucketNames[t.bucketId] ?? 'Sin porción',
          categoryName: categories[t.categoryId] ?? 'Sin categoría',
          date: t.transactionDate,
        ),
    ];
  }
}
