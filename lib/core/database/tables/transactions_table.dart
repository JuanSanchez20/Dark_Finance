import 'package:drift/drift.dart';

import 'buckets_table.dart';
import 'categories_table.dart';
import 'enums.dart';
import 'monthly_periods_table.dart';
import 'recurring_incomes_table.dart';

/// Un movimiento de dinero (gasto, ingreso o aporte a una meta).
/// - bucketId: porción del mes a la que se cargó el gasto (los ingresos no lo usan).
/// - recurringIncomeId: ingreso fijo que lo generó, si fue así.
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get periodId => integer().references(MonthlyPeriods, #id)();
  IntColumn get categoryId =>
      integer().nullable().references(Categories, #id)();
  IntColumn get bucketId => integer().nullable().references(Buckets, #id)();
  IntColumn get recurringIncomeId =>
      integer().nullable().references(RecurringIncomes, #id)();
  RealColumn get amount => real()();
  TextColumn get type =>
      textEnum<TransactionType>().withDefault(const Constant('expense'))();
  TextColumn get description => text()();
  TextColumn get merchant => text().nullable()();
  TextColumn get source =>
      textEnum<TransactionSource>().withDefault(const Constant('manual'))();
  DateTimeColumn get transactionDate => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
