import 'package:drift/drift.dart';

class MonthlyPeriods extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get year => integer()();
  IntColumn get month => integer()();
  RealColumn get income => real()();
  IntColumn get cutoffDay => integer().withDefault(const Constant(1))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {year, month},
      ];
}
