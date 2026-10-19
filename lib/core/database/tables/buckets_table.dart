import 'package:drift/drift.dart';

import 'bucket_definitions_table.dart';
import 'monthly_periods_table.dart';

/// Una porción dentro de un mes concreto, con el porcentaje que tuvo ese mes.
class Buckets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get periodId => integer().references(MonthlyPeriods, #id)();
  IntColumn get definitionId => integer().references(BucketDefinitions, #id)();
  IntColumn get percent => integer()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  List<Set<Column>> get uniqueKeys => [
        {periodId, definitionId},
      ];
}
