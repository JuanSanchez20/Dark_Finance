import 'package:drift/drift.dart' show Value;

import '../../../core/database/app_database.dart';
import '../../../core/database/tables/enums.dart';
import '../../../core/errors/invalid_input_exception.dart';
import '../../budget/data/budget_periods_gateway.dart';
import '../domain/income_entry.dart';
import 'extra_income_repository.dart';

/// Guarda los ingresos únicos como movimientos de tipo 'income'.
class DriftExtraIncomeRepository implements ExtraIncomeRepository {
  DriftExtraIncomeRepository(this._db, this._periods);

  final AppDatabase _db;
  final BudgetPeriodsGateway _periods;

  bool _isOneTime(Transaction t) =>
      t.type == TransactionType.income && t.recurringIncomeId == null;

  @override
  Future<List<IncomeEntry>> listThisMonth() async {
    final period = await _periods.ensureCurrent();
    final rows = await _db.transactionsDao.byPeriod(period.id); // más nuevas primero
    return [
      for (final t in rows.where(_isOneTime))
        IncomeEntry(
          id: t.id,
          amount: t.amount,
          source: t.description,
          date: t.transactionDate,
        ),
    ];
  }

  @override
  Future<List<String>> knownSources() async {
    final incomes = await _db.transactionsDao.allIncomes();
    return {for (final t in incomes.where(_isOneTime)) t.description}.toList();
  }

  @override
  Future<void> add(NewIncome income) async {
    final source = income.source.trim();
    if (income.amount <= 0) {
      throw const InvalidInputException('Escribe un monto mayor a 0');
    }
    if (source.isEmpty) {
      throw const InvalidInputException('Indica de dónde viene el ingreso');
    }
    final today = _periods.now;
    if (income.date.year != today.year || income.date.month != today.month) {
      throw const InvalidInputException('La fecha debe ser de este mes');
    }

    final period = await _periods.ensureCurrent();
    await _db.transactionsDao.insertTransaction(
      TransactionsCompanion.insert(
        periodId: period.id,
        amount: income.amount,
        description: source,
        transactionDate: income.date,
        type: const Value(TransactionType.income),
      ),
    );
  }

  @override
  Future<void> delete(int id) async {
    await _db.transactionsDao.deleteTransaction(id);
  }
}
