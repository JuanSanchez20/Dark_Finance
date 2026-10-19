import 'package:drift/drift.dart';

import 'bucket_definitions_table.dart';
import 'categories_table.dart';

/// Regla que mapea un patrón de comercio a una porción/categoría.
/// merchantPattern se compara con contains (insensible a mayúsculas).
/// Ejemplo: 'TROLE' → porción Obligatorios / categoría Transporte
class MerchantRules extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get merchantPattern => text()();
  IntColumn get categoryId =>
      integer().nullable().references(Categories, #id)();
  IntColumn get bucketDefinitionId =>
      integer().references(BucketDefinitions, #id)();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
