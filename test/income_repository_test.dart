import 'package:dark_finance/core/database/app_database.dart' hide RecurringIncome;
import 'package:dark_finance/core/database/tables/enums.dart';
import 'package:dark_finance/core/errors/invalid_input_exception.dart';
import 'package:dark_finance/features/budget/data/budget_periods_gateway.dart';
import 'package:dark_finance/features/categories/data/drift_categories_repository.dart';
import 'package:dark_finance/features/categories/domain/category_item.dart';
import 'package:dark_finance/features/home/data/drift_home_summary_repository.dart';
import 'package:dark_finance/features/income/data/drift_extra_income_repository.dart';
import 'package:dark_finance/features/income/data/drift_income_repository.dart';
import 'package:dark_finance/features/income/data/drift_recurring_income_repository.dart';
import 'package:dark_finance/features/income/domain/income_change.dart';
import 'package:dark_finance/features/income/domain/income_entry.dart';
import 'package:dark_finance/features/income/domain/recurring_income.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late BudgetPeriodsGateway periods;
  late DriftIncomeRepository income;
  late DriftRecurringIncomeRepository fixed;
  late DriftExtraIncomeRepository oneTime;
  late DriftHomeSummaryRepository home;
  late DriftCategoriesRepository categories;
  var today = DateTime(2026, 10, 18);

  setUp(() {
    today = DateTime(2026, 10, 18);
    db = AppDatabase.forTesting(NativeDatabase.memory());
    periods = BudgetPeriodsGateway(db, now: () => today);
    income = DriftIncomeRepository(db, periods);
    fixed = DriftRecurringIncomeRepository(db, periods);
    oneTime = DriftExtraIncomeRepository(db, periods);
    home = DriftHomeSummaryRepository(db, periods);
    categories = DriftCategoriesRepository(db);
  });

  tearDown(() => db.close());

  /// Registra un gasto en la porción con esa `key` ('gustos', 'obligatorios'...).
  Future<void> addExpense(double amount, String bucketKey) async {
    final period = await periods.ensureCurrent();
    final definition =
        (await db.bucketDefinitionsDao.all()).firstWhere((d) => d.key == bucketKey);
    final bucket = (await db.bucketsDao.byPeriod(period.id))
        .firstWhere((b) => b.definitionId == definition.id);
    await db.transactionsDao.insertTransaction(
      TransactionsCompanion.insert(
        periodId: period.id,
        bucketId: Value(bucket.id),
        amount: amount,
        description: 'Prueba',
        transactionDate: today,
      ),
    );
  }

  group('sueldo', () {
    test('arranca en 0 y sin datos de ejemplo', () async {
      final summary = await home.load();
      expect(summary.totalIncome, 0);
      expect(summary.totalSpent, 0);
      expect(summary.recentTransactions, isEmpty);
      expect(summary.buckets.map((b) => b.percent), [50, 25, 15, 10]);
    });

    test('caso 1: sin gastos, el sueldo recalcula todas las porciones', () async {
      await income.setIncome(100, effect: IncomeEffect.thisMonth);
      var summary = await home.load();
      expect(summary.buckets.map((b) => b.allocated(summary.totalIncome)), [50, 25, 15, 10]);

      await income.setIncome(200, effect: IncomeEffect.thisMonth);
      summary = await home.load();
      expect(summary.buckets.map((b) => b.allocated(summary.totalIncome)), [100, 50, 30, 20]);
    });

    test('con gastos, la vista previa indica que hay que preguntar', () async {
      await income.setIncome(1000, effect: IncomeEffect.thisMonth);
      expect((await income.overview()).hasTransactions, isFalse);
      await addExpense(10, 'gustos');
      expect((await income.overview()).hasTransactions, isTrue);
    });

    test('caso 2: bajar el sueldo este mes avisa de las porciones excedidas', () async {
      await income.setIncome(1000, effect: IncomeEffect.thisMonth);
      await addExpense(90, 'gustos'); // tope actual: 100

      final result = await income.setIncome(500, effect: IncomeEffect.thisMonth); // tope: 50
      expect(result.overspends.length, 1);
      expect(result.overspends.first.bucketName, 'Gustos');
      expect(result.overspends.first.excess, closeTo(40, 0.001));
    });

    test('caso 2: subir el sueldo este mes no genera alertas', () async {
      await income.setIncome(1000, effect: IncomeEffect.thisMonth);
      await addExpense(90, 'gustos');
      final result = await income.setIncome(2000, effect: IncomeEffect.thisMonth);
      expect(result.overspends, isEmpty);
    });

    test('caso 2: cambio para el próximo mes no toca el mes actual y se aplica después', () async {
      await income.setIncome(1000, effect: IncomeEffect.thisMonth);
      await addExpense(10, 'gustos');
      await income.setIncome(1500, effect: IncomeEffect.nextMonth);

      final overview = await income.overview();
      expect(overview.currentIncome, 1000);
      expect(overview.pendingNextMonthIncome, 1500);

      today = DateTime(2026, 11, 2);
      final november = await home.load();
      expect(november.totalIncome, 1500);
      expect(november.totalSpent, 0);
    });

    test('el sueldo se mantiene en un mes nuevo hasta que se cambie', () async {
      await income.setIncome(1000, effect: IncomeEffect.thisMonth);
      today = DateTime(2026, 12, 1);
      expect((await home.load()).totalIncome, 1000);
    });
  });

  group('ingresos fijos (se suman cada mes)', () {
    const bonus = RecurringIncomeDraft(name: 'Transporte incluido', amount: 50);

    test('se suman al ingreso del mes y se reparten en 50/25/15/10', () async {
      await income.setIncome(100, effect: IncomeEffect.thisMonth);
      await fixed.create(bonus);

      final summary = await home.load();
      expect(summary.totalIncome, 150);
      expect(summary.buckets.map((b) => b.allocated(summary.totalIncome)), [75, 37.5, 22.5, 15]);
      expect(summary.incomeSources.map((s) => s.label), ['Sueldo base', 'Transporte incluido']);
    });

    test('se aplican solos en el mes siguiente, sin duplicarse', () async {
      await income.setIncome(100, effect: IncomeEffect.thisMonth);
      await fixed.create(bonus);
      await home.load();
      await home.load(); // cargar dos veces no debe duplicar

      today = DateTime(2026, 11, 3);
      final november = await home.load();
      expect(november.totalIncome, 150);

      today = DateTime(2026, 10, 20);
      expect((await home.load()).totalIncome, 150);
    });

    test('editar el monto rige desde este mes; los meses pasados no cambian', () async {
      await income.setIncome(100, effect: IncomeEffect.thisMonth);
      await fixed.create(bonus);
      today = DateTime(2026, 11, 3);
      await home.load();

      final id = (await fixed.list()).single.id;
      await fixed.update(id, const RecurringIncomeDraft(name: 'Transporte incluido', amount: 80));

      expect((await home.load()).totalIncome, 180);
      today = DateTime(2026, 10, 20);
      expect((await home.load()).totalIncome, 150);
    });

    test('desactivar lo quita de este mes y de los siguientes; activar lo devuelve', () async {
      await income.setIncome(100, effect: IncomeEffect.thisMonth);
      await fixed.create(bonus);
      final id = (await fixed.list()).single.id;

      await fixed.setActive(id, isActive: false);
      expect((await home.load()).totalIncome, 100);
      today = DateTime(2026, 11, 3);
      expect((await home.load()).totalIncome, 100);

      await fixed.setActive(id, isActive: true);
      expect((await home.load()).totalIncome, 150);
    });

    test('eliminar conserva el historial de meses pasados', () async {
      await income.setIncome(100, effect: IncomeEffect.thisMonth);
      await fixed.create(bonus);
      today = DateTime(2026, 11, 3);
      await home.load();

      await fixed.delete((await fixed.list()).single.id);
      expect((await home.load()).totalIncome, 100);
      today = DateTime(2026, 10, 20);
      expect((await home.load()).totalIncome, 150);
      expect(await fixed.list(), isEmpty);
    });

    test('no admite nombre repetido ni monto inválido', () async {
      await fixed.create(bonus);
      expect(() => fixed.create(bonus), throwsA(isA<InvalidInputException>()));
      expect(
        () => fixed.create(const RecurringIncomeDraft(name: 'X', amount: 0)),
        throwsA(isA<InvalidInputException>()),
      );
    });
  });

  group('ingresos únicos', () {
    test('suman solo a este mes y llevan fecha', () async {
      await income.setIncome(100, effect: IncomeEffect.thisMonth);
      await oneTime.add(NewIncome(amount: 50, source: 'Arreglé una computadora', date: DateTime(2026, 10, 10)));

      expect((await home.load()).totalIncome, 150);
      expect((await oneTime.listThisMonth()).single.source, 'Arreglé una computadora');

      today = DateTime(2026, 11, 3);
      expect((await home.load()).totalIncome, 100);
    });

    test('rechaza fechas de otro mes', () async {
      expect(
        () => oneTime.add(NewIncome(amount: 5, source: 'Venta', date: DateTime(2026, 9, 30))),
        throwsA(isA<InvalidInputException>()),
      );
    });
  });

  group('categorías (por id)', () {
    test('la porción habitual se guarda por id, no por nombre', () async {
      final options = await categories.bucketOptions();
      final gustos = options.firstWhere((o) => o.name == 'Gustos');

      await categories.create(CategoryDraft(
        name: 'Gimnasio',
        icon: 'G',
        colorHex: '#FF6B6B',
        defaultBucketId: gustos.id,
      ));
      final created = (await categories.list()).firstWhere((c) => c.name == 'Gimnasio');
      expect(created.defaultBucketId, gustos.id);
      expect(created.defaultBucketName, 'Gustos');
    });

    test('rechaza una porción inexistente y nombres repetidos', () async {
      expect(
        () => categories.create(const CategoryDraft(
            name: 'Nueva', icon: 'N', colorHex: '#FFFFFF', defaultBucketId: 9999)),
        throwsA(isA<InvalidInputException>()),
      );
      expect(
        () => categories.create(const CategoryDraft(
            name: 'comida', icon: 'N', colorHex: '#FFFFFF')),
        throwsA(isA<InvalidInputException>()),
      );
    });

    test('no se puede eliminar una categoría con movimientos', () async {
      final comida = (await categories.list()).firstWhere((c) => c.name == 'Comida');
      final period = await periods.ensureCurrent();
      await db.transactionsDao.insertTransaction(TransactionsCompanion.insert(
        periodId: period.id,
        categoryId: Value(comida.id),
        amount: 3,
        description: 'Café',
        transactionDate: today,
        type: const Value(TransactionType.expense),
      ));
      expect(() => categories.delete(comida.id), throwsA(isA<InvalidInputException>()));
    });
  });
}
