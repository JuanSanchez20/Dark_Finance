import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/categories/data/categories_repository.dart';
import 'features/categories/presentation/categories_screen.dart';
import 'features/home/data/home_summary_repository.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/income/data/extra_income_repository.dart';
import 'features/income/data/income_repository.dart';
import 'features/income/data/recurring_income_repository.dart';
import 'features/income/presentation/incomes_screen.dart';
import 'features/settings/presentation/settings_screen.dart';
import 'shared/navigation/app_routes.dart';

/// Raíz de la aplicación: tema y rutas. Recibe los repositorios ya construidos
/// (ver `main.dart`), así las pantallas nunca saben de dónde vienen los datos.
class DarkFinanceApp extends StatelessWidget {
  const DarkFinanceApp({
    super.key,
    required this.homeRepository,
    required this.incomeRepository,
    required this.recurringIncomeRepository,
    required this.extraIncomeRepository,
    required this.categoriesRepository,
  });

  final HomeSummaryRepository homeRepository;
  final IncomeRepository incomeRepository;
  final RecurringIncomeRepository recurringIncomeRepository;
  final ExtraIncomeRepository extraIncomeRepository;
  final CategoriesRepository categoriesRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dark Finance',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      initialRoute: AppRoutes.home,
      routes: {
        AppRoutes.home: (_) => HomeScreen(repository: homeRepository),
        AppRoutes.incomes: (_) => IncomesScreen(
              incomeRepository: incomeRepository,
              recurringIncomeRepository: recurringIncomeRepository,
              extraIncomeRepository: extraIncomeRepository,
            ),
        AppRoutes.categories: (_) =>
            CategoriesScreen(repository: categoriesRepository),
        AppRoutes.settings: (_) => const SettingsScreen(),
      },
    );
  }
}
