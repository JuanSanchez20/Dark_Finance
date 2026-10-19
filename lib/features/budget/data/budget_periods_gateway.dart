import 'package:drift/drift.dart' show Value;

import '../../../core/database/app_database.dart';
import '../../../core/database/tables/enums.dart';
import '../domain/budget_bucket.dart';

/// Acceso compartido a los periodos mensuales y sus porciones.
///
/// Lo usan Resumen, Ingresos y Categorías: así las reglas "cómo se crea un mes"
/// y "cuánto se gastó en cada porción" viven en un solo lugar.
class BudgetPeriodsGateway {
  BudgetPeriodsGateway(this._db, {DateTime Function()? now})
      : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;

  DateTime get now => _now();

  /// Periodo del mes actual. Si no existe, lo crea con el último sueldo conocido
  /// (el sueldo se mantiene hasta que el usuario lo cambie; 0 si nunca lo definió).
  /// Además se asegura de que los ingresos fijos activos estén aplicados este mes.
  Future<MonthlyPeriod> ensureCurrent() async {
    final today = _now();
    var period = await _db.periodsDao.findByYearMonth(today.year, today.month);

    if (period == null) {
      final all = await _db.periodsDao.allPeriods(); // del más nuevo al más antiguo
      MonthlyPeriod? previous;
      for (final candidate in all) {
        if (_isBefore(candidate, today.year, today.month)) {
          previous = candidate;
          break;
        }
      }
      period = await _create(today.year, today.month, previous?.income ?? 0);
    }

    await _applyRecurringIncomes(period);
    return period;
  }

  /// Periodo del mes siguiente si ya tiene un sueldo pendiente, o null.
  Future<MonthlyPeriod?> findNext() {
    final next = _nextMonth(_now());
    return _db.periodsDao.findByYearMonth(next.year, next.month);
  }

  /// Guarda el sueldo que regirá desde el mes siguiente.
  Future<void> setNextMonthIncome(double income) async {
    final next = _nextMonth(_now());
    final existing = await _db.periodsDao.findByYearMonth(next.year, next.month);
    if (existing == null) {
      await _create(next.year, next.month, income);
    } else {
      await _db.periodsDao.updatePeriod(existing.copyWith(income: income));
    }
  }

  /// Porciones del periodo con lo gastado en cada una.
  Future<List<BudgetBucket>> bucketsWithSpent(int periodId) async {
    final definitions = {
      for (final d in await _db.bucketDefinitionsDao.all()) d.id: d,
    };
    final buckets = await _db.bucketsDao.byPeriod(periodId);
    final transactions = await _db.transactionsDao.byPeriod(periodId);

    final spentByBucket = <int, double>{};
    for (final t in transactions) {
      final bucketId = t.bucketId;
      if (bucketId == null || t.type == TransactionType.income) continue;
      spentByBucket[bucketId] = (spentByBucket[bucketId] ?? 0) + t.amount;
    }

    return [
      for (final b in buckets)
        BudgetBucket(
          id: b.id,
          definitionId: b.definitionId,
          name: definitions[b.definitionId]!.name,
          description: definitions[b.definitionId]!.description,
          percent: b.percent,
          spent: spentByBucket[b.id] ?? 0,
        ),
    ];
  }

  /// Suma de todos los ingresos extra del periodo (únicos y fijos), que se suman
  /// al sueldo y se reparten en 50/25/15/10.
  Future<double> extraIncomeTotal(int periodId) async {
    final transactions = await _db.transactionsDao.byPeriod(periodId);
    return transactions
        .where((t) => t.type == TransactionType.income)
        .fold<double>(0, (sum, t) => sum + t.amount);
  }

  Future<MonthlyPeriod> _create(int year, int month, double income) async {
    await _db.transaction(() async {
      final id = await _db.periodsDao.insertPeriod(
        MonthlyPeriodsCompanion.insert(year: year, month: month, income: income),
      );
      final definitions = await _db.bucketDefinitionsDao.all();
      await _db.bucketsDao.insertAll([
        for (final d in definitions)
          BucketsCompanion.insert(
            periodId: id,
            definitionId: d.id,
            percent: d.defaultPercent,
            sortOrder: Value(d.sortOrder),
          ),
      ]);
    });
    return (await _db.periodsDao.findByYearMonth(year, month))!;
  }

  /// Copia al periodo los ingresos fijos activos que aún no estén en él.
  Future<void> _applyRecurringIncomes(MonthlyPeriod period) async {
    final active = await _db.recurringIncomesDao.active();
    if (active.isEmpty) return;

    await _db.transaction(() async {
      final applied = await _db.transactionsDao.recurringIdsInPeriod(period.id);
      for (final income in active.where((r) => !applied.contains(r.id))) {
        await _db.transactionsDao.insertTransaction(
          TransactionsCompanion.insert(
            periodId: period.id,
            amount: income.amount,
            description: income.name,
            transactionDate: DateTime(period.year, period.month, 1),
            type: const Value(TransactionType.income),
            source: const Value(TransactionSource.recurring),
            recurringIncomeId: Value(income.id),
          ),
        );
      }
    });
  }

  bool _isBefore(MonthlyPeriod period, int year, int month) =>
      period.year < year || (period.year == year && period.month < month);

  ({int year, int month}) _nextMonth(DateTime date) => date.month == 12
      ? (year: date.year + 1, month: 1)
      : (year: date.year, month: date.month + 1);
}
