import '../../../core/database/app_database.dart';
import '../../../core/database/tables/enums.dart';
import '../../budget/data/budget_periods_gateway.dart';
import '../domain/income_change.dart';
import 'income_repository.dart';

/// Guarda el sueldo en la base local (tabla de periodos mensuales).
class DriftIncomeRepository implements IncomeRepository {
  DriftIncomeRepository(this._db, this._periods);

  final AppDatabase _db;
  final BudgetPeriodsGateway _periods;

  @override
  Future<IncomeOverview> overview() async {
    final current = await _periods.ensureCurrent();
    final next = await _periods.findNext();
    final transactions = await _db.transactionsDao.byPeriod(current.id);
    return IncomeOverview(
      currentIncome: current.income,
      pendingNextMonthIncome: next?.income,
      // Los ingresos extra no cuentan: "con registros" significa con gastos.
      hasTransactions: transactions.any((t) => t.type != TransactionType.income),
    );
  }

  @override
  Future<IncomeChangeResult> setIncome(
    double amount, {
    required IncomeEffect effect,
  }) async {
    if (effect == IncomeEffect.nextMonth) {
      await _periods.setNextMonthIncome(amount);
      return const IncomeChangeResult(
        effect: IncomeEffect.nextMonth,
        overspends: [],
      );
    }

    final current = await _periods.ensureCurrent();
    await _db.periodsDao.updatePeriod(current.copyWith(income: amount));
    final buckets = await _periods.bucketsWithSpent(current.id);
    final extraIncome = await _periods.extraIncomeTotal(current.id);
    return IncomeChangeResult(
      effect: IncomeEffect.thisMonth,
      overspends: findOverspends(amount + extraIncome, buckets),
    );
  }
}
