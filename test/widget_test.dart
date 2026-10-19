import 'package:dark_finance/app.dart';
import 'package:dark_finance/features/budget/domain/budget_bucket.dart';
import 'package:dark_finance/features/budget/domain/bucket_option.dart';
import 'package:dark_finance/features/categories/data/categories_repository.dart';
import 'package:dark_finance/features/categories/domain/category_item.dart';
import 'package:dark_finance/features/home/data/home_summary_repository.dart';
import 'package:dark_finance/features/home/domain/home_summary.dart';
import 'package:dark_finance/features/income/data/extra_income_repository.dart';
import 'package:dark_finance/features/income/data/income_repository.dart';
import 'package:dark_finance/features/income/data/recurring_income_repository.dart';
import 'package:dark_finance/features/income/domain/income_change.dart';
import 'package:dark_finance/features/income/domain/income_entry.dart';
import 'package:dark_finance/features/income/domain/recurring_income.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _EmptyHome implements HomeSummaryRepository {
  @override
  Future<HomeSummary> load() async => const HomeSummary(
        totalIncome: 0,
        incomeSources: [],
        daysElapsed: 1,
        daysInMonth: 31,
        recentTransactions: [],
        buckets: [
          BudgetBucket(
            id: 1,
            definitionId: 1,
            name: 'Gastos Obligatorios',
            description: '',
            percent: 50,
            spent: 0,
          ),
        ],
      );
}

class _FakeIncome implements IncomeRepository {
  double? saved;
  bool fail = false;

  @override
  Future<IncomeOverview> overview() async =>
      IncomeOverview(currentIncome: saved ?? 0, hasTransactions: false);

  @override
  Future<IncomeChangeResult> setIncome(double amount, {required IncomeEffect effect}) async {
    if (fail) throw Exception('falla simulada');
    saved = amount;
    return IncomeChangeResult(effect: effect, overspends: const []);
  }
}

class _NoFixedIncome implements RecurringIncomeRepository {
  @override
  Future<List<RecurringIncome>> list() async => [];
  @override
  Future<void> create(RecurringIncomeDraft draft) async {}
  @override
  Future<void> update(int id, RecurringIncomeDraft draft) async {}
  @override
  Future<void> setActive(int id, {required bool isActive}) async {}
  @override
  Future<void> delete(int id) async {}
}

class _NoExtraIncome implements ExtraIncomeRepository {
  @override
  Future<List<IncomeEntry>> listThisMonth() async => [];
  @override
  Future<List<String>> knownSources() async => [];
  @override
  Future<void> add(NewIncome income) async {}
  @override
  Future<void> delete(int id) async {}
}

class _NoCategories implements CategoriesRepository {
  @override
  Future<List<CategoryItem>> list() async => [];
  @override
  Future<List<BucketOption>> bucketOptions() async => [];
  @override
  Future<void> create(CategoryDraft draft) async {}
  @override
  Future<void> update(int id, CategoryDraft draft) async {}
  @override
  Future<void> delete(int id) async {}
}

DarkFinanceApp _app(IncomeRepository income) => DarkFinanceApp(
      homeRepository: _EmptyHome(),
      incomeRepository: income,
      recurringIncomeRepository: _NoFixedIncome(),
      extraIncomeRepository: _NoExtraIncome(),
      categoriesRepository: _NoCategories(),
    );

Future<void> _defineSalary(WidgetTester tester) async {
  await tester.tap(find.text('Definir sueldo'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField), '1200');
  await tester.tap(find.text('Guardar'));
  // pumpAndSettle dejaría pasar los 4 s del aviso y lo cerraría.
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pump(const Duration(milliseconds: 600));
}

void main() {
  testWidgets('Resumen vacío lleva a Ingresos y el sueldo se define con aviso', (tester) async {
    final income = _FakeIncome();
    await tester.pumpWidget(_app(income));
    await tester.pumpAndSettle();

    expect(find.text('Define tu sueldo mensual'), findsOneWidget);
    await tester.tap(find.text('Ir a Ingresos'));
    await tester.pumpAndSettle();
    expect(find.text('Sin definir'), findsOneWidget);

    await _defineSalary(tester);
    expect(income.saved, 1200);
    expect(find.text('Sueldo definido'), findsOneWidget);
  });

  testWidgets('si falla guardar el sueldo, avisa del error', (tester) async {
    final income = _FakeIncome()..fail = true;
    await tester.pumpWidget(_app(income));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ir a Ingresos'));
    await tester.pumpAndSettle();

    await _defineSalary(tester);
    expect(find.text('Error en la definición del sueldo'), findsOneWidget);
  });

  testWidgets('el menú lateral abre Ajustes, que está vacío', (tester) async {
    await tester.pumpWidget(_app(_FakeIncome()));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ajustes'));
    await tester.pumpAndSettle();

    expect(find.text('Aún no hay ajustes'), findsOneWidget);
  });
}
