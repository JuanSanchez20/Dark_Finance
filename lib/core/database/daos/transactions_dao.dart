import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/enums.dart';
import '../tables/transactions_table.dart';

part 'transactions_dao.g.dart';

@DriftAccessor(tables: [Transactions])
class TransactionsDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionsDaoMixin {
  TransactionsDao(super.db);

  Future<List<Transaction>> byPeriod(int periodId) =>
      (select(transactions)
            ..where((t) => t.periodId.equals(periodId))
            ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
          .get();

  Stream<List<Transaction>> watchByPeriod(int periodId) =>
      (select(transactions)
            ..where((t) => t.periodId.equals(periodId))
            ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
          .watch();

  Future<double> totalSpentByPeriod(int periodId) async {
    final rows = await byPeriod(periodId);
    return rows
        .where((t) => t.type == TransactionType.expense)
        .fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  /// Todos los ingresos registrados (de cualquier mes), del más nuevo al más antiguo.
  Future<List<Transaction>> allIncomes() =>
      (select(transactions)
            ..where((t) => t.type.equalsValue(TransactionType.income))
            ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
          .get();

  /// Cuántos movimientos usan una categoría (para no borrarla si está en uso).
  Future<int> countByCategory(int categoryId) async {
    final rows = await (select(transactions)
          ..where((t) => t.categoryId.equals(categoryId)))
        .get();
    return rows.length;
  }

  /// Ids de los ingresos fijos que ya tienen su movimiento en el periodo.
  Future<Set<int>> recurringIdsInPeriod(int periodId) async {
    final rows = await (select(transactions)
          ..where((t) =>
              t.periodId.equals(periodId) & t.recurringIncomeId.isNotNull()))
        .get();
    return {for (final t in rows) t.recurringIncomeId!};
  }

  /// Actualiza el movimiento que un ingreso fijo generó en un periodo.
  Future<void> updateRecurringInPeriod(
    int recurringId,
    int periodId, {
    required String description,
    required double amount,
  }) =>
      (update(transactions)
            ..where((t) =>
                t.recurringIncomeId.equals(recurringId) &
                t.periodId.equals(periodId)))
          .write(TransactionsCompanion(
        description: Value(description),
        amount: Value(amount),
      ));

  Future<void> deleteRecurringInPeriod(int recurringId, int periodId) =>
      (delete(transactions)
            ..where((t) =>
                t.recurringIncomeId.equals(recurringId) &
                t.periodId.equals(periodId)))
          .go();

  /// Suelta el enlace con un ingreso fijo (se usa antes de borrarlo, para que
  /// los meses pasados conserven sus movimientos).
  Future<void> detachRecurring(int recurringId) =>
      (update(transactions)..where((t) => t.recurringIncomeId.equals(recurringId)))
          .write(const TransactionsCompanion(recurringIncomeId: Value(null)));

  Future<int> insertTransaction(TransactionsCompanion entry) =>
      into(transactions).insert(entry);

  Future<bool> updateTransaction(Transaction entry) =>
      update(transactions).replace(entry);

  Future<int> deleteTransaction(int id) =>
      (delete(transactions)..where((t) => t.id.equals(id))).go();
}
