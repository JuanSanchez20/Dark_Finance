import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/recurring_incomes_table.dart';

part 'recurring_incomes_dao.g.dart';

@DriftAccessor(tables: [RecurringIncomes])
class RecurringIncomesDao extends DatabaseAccessor<AppDatabase>
    with _$RecurringIncomesDaoMixin {
  RecurringIncomesDao(super.db);

  Future<List<RecurringIncome>> all() =>
      (select(recurringIncomes)
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .get();

  Future<List<RecurringIncome>> active() =>
      (select(recurringIncomes)..where((t) => t.isActive.equals(true))).get();

  Future<RecurringIncome?> byId(int id) =>
      (select(recurringIncomes)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertIncome(RecurringIncomesCompanion entry) =>
      into(recurringIncomes).insert(entry);

  Future<void> updateFields(int id, RecurringIncomesCompanion changes) =>
      (update(recurringIncomes)..where((t) => t.id.equals(id))).write(changes);

  Future<int> deleteIncome(int id) =>
      (delete(recurringIncomes)..where((t) => t.id.equals(id))).go();
}
