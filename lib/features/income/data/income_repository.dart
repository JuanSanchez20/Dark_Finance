import '../domain/income_change.dart';

/// Contrato para consultar y cambiar el sueldo mensual.
abstract class IncomeRepository {
  Future<IncomeOverview> overview();

  Future<IncomeChangeResult> setIncome(
    double amount, {
    required IncomeEffect effect,
  });
}
