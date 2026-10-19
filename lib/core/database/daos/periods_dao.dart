import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/monthly_periods_table.dart';

part 'periods_dao.g.dart';

@DriftAccessor(tables: [MonthlyPeriods])
class PeriodsDao extends DatabaseAccessor<AppDatabase>
    with _$PeriodsDaoMixin {
  PeriodsDao(super.db);

  Future<MonthlyPeriod?> findByYearMonth(int year, int month) =>
      (select(monthlyPeriods)
            ..where((t) => t.year.equals(year) & t.month.equals(month)))
          .getSingleOrNull();

  Future<List<MonthlyPeriod>> allPeriods() =>
      (select(monthlyPeriods)
            ..orderBy([
              (t) => OrderingTerm.desc(t.year),
              (t) => OrderingTerm.desc(t.month),
            ]))
          .get();

  Future<int> insertPeriod(MonthlyPeriodsCompanion entry) =>
      into(monthlyPeriods).insert(entry);

  Future<bool> updatePeriod(MonthlyPeriod entry) =>
      update(monthlyPeriods).replace(entry);
}
