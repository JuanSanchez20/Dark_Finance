import 'package:drift/drift.dart';

/// Ingreso fijo que se suma cada mes mientras esté activo (bono, transporte...).
/// Cada mes se copia como un movimiento de tipo 'income' enlazado por
/// `Transactions.recurringIncomeId`, para que los meses pasados no cambien
/// cuando se edita el ingreso.
class RecurringIncomes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  RealColumn get amount => real()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
