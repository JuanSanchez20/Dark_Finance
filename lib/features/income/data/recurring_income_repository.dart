import '../domain/recurring_income.dart';

/// Contrato para los ingresos fijos mensuales.
///
/// Regla de cambios: cualquier cambio (crear, editar, activar, desactivar,
/// eliminar) rige desde el mes actual; los meses pasados no se tocan.
/// Las escrituras lanzan `InvalidInputException` si el dato no es válido.
abstract class RecurringIncomeRepository {
  Future<List<RecurringIncome>> list();

  Future<void> create(RecurringIncomeDraft draft);

  Future<void> update(int id, RecurringIncomeDraft draft);

  Future<void> setActive(int id, {required bool isActive});

  Future<void> delete(int id);
}
