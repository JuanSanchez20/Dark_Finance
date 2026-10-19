import 'package:drift/drift.dart';

/// Las porciones del presupuesto (Obligatorios, Inversión, Emergencia, Gustos).
/// Existen una sola vez; cada mes tiene sus propias filas en `Buckets` que
/// apuntan a estas por id. Así, renombrar una porción no rompe nada.
class BucketDefinitions extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Identificador estable ('obligatorios', 'gustos'...). Nunca cambia.
  TextColumn get key => text().unique()();
  TextColumn get name => text()();
  TextColumn get description => text()();

  /// Porcentaje con el que se crea la porción en cada mes nuevo.
  IntColumn get defaultPercent => integer()();
  IntColumn get sortOrder => integer()();
}
