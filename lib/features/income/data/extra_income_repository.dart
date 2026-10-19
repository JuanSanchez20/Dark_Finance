import '../domain/income_entry.dart';

/// Contrato para los ingresos únicos (solo valen para el mes en que se registran).
abstract class ExtraIncomeRepository {
  /// Ingresos únicos del mes actual, del más nuevo al más antiguo.
  Future<List<IncomeEntry>> listThisMonth();

  /// Orígenes usados antes, para sugerirlos al registrar uno nuevo.
  Future<List<String>> knownSources();

  /// Lanza `InvalidInputException` si el monto, el origen o la fecha no son válidos.
  Future<void> add(NewIncome income);

  Future<void> delete(int id);
}
