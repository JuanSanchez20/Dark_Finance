import 'package:drift/drift.dart';

import 'bucket_definitions_table.dart';

/// defaultBucketId: porción a la que suele pertenecer la categoría
/// (referencia por id a `BucketDefinitions`; null = ninguna en particular).
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get icon => text()();
  TextColumn get color => text()();
  IntColumn get defaultBucketId =>
      integer().nullable().references(BucketDefinitions, #id)();
  BoolColumn get isFixed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
