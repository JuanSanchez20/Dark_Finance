import 'package:flutter/material.dart';

import 'app.dart';
import 'core/database/app_database.dart';
import 'features/budget/data/budget_periods_gateway.dart';
import 'features/categories/data/drift_categories_repository.dart';
import 'features/home/data/drift_home_summary_repository.dart';
import 'features/income/data/drift_extra_income_repository.dart';
import 'features/income/data/drift_income_repository.dart';
import 'features/income/data/drift_recurring_income_repository.dart';

/// Punto de entrada y único lugar donde se "enchufan" las piezas:
/// base de datos -> repositorios -> app.
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final database = AppDatabase();
  final periods = BudgetPeriodsGateway(database);

  runApp(DarkFinanceApp(
    homeRepository: DriftHomeSummaryRepository(database, periods),
    incomeRepository: DriftIncomeRepository(database, periods),
    recurringIncomeRepository: DriftRecurringIncomeRepository(database, periods),
    extraIncomeRepository: DriftExtraIncomeRepository(database, periods),
    categoriesRepository: DriftCategoriesRepository(database),
  ));
}
