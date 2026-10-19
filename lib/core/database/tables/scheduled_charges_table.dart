import 'package:drift/drift.dart';

import 'bucket_definitions_table.dart';
import 'categories_table.dart';

/// Cobro recurrente esperado en un día fijo del mes (gym, suscripciones, etc.).
/// La app notifica al usuario ese día si no detectó el cobro.
class ScheduledCharges extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  RealColumn get amountHint => real().nullable()();
  IntColumn get dayOfMonth => integer()();
  IntColumn get categoryId =>
      integer().nullable().references(Categories, #id)();
  IntColumn get bucketDefinitionId =>
      integer().references(BucketDefinitions, #id)();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
