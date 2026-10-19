import 'package:drift/drift.dart' show Value;

// `hide`: Drift genera su propia clase RecurringIncome (la fila de la tabla);
// aquí se usa la del dominio.
import '../../../core/database/app_database.dart' hide RecurringIncome;
import '../../../core/errors/invalid_input_exception.dart';
import '../../budget/data/budget_periods_gateway.dart';
import '../domain/recurring_income.dart';
import 'recurring_income_repository.dart';

class DriftRecurringIncomeRepository implements RecurringIncomeRepository {
  DriftRecurringIncomeRepository(this._db, this._periods);

  static const _maxNameLength = 40;

  final AppDatabase _db;
  final BudgetPeriodsGateway _periods;

  @override
  Future<List<RecurringIncome>> list() async {
    final rows = await _db.recurringIncomesDao.all();
    return [
      for (final r in rows)
        RecurringIncome(
          id: r.id,
          name: r.name,
          amount: r.amount,
          isActive: r.isActive,
        ),
    ];
  }

  @override
  Future<void> create(RecurringIncomeDraft draft) async {
    final name = await _validated(draft);
    await _db.recurringIncomesDao.insertIncome(
      RecurringIncomesCompanion.insert(name: name, amount: draft.amount),
    );
    await _periods.ensureCurrent(); // lo aplica a este mes
  }

  @override
  Future<void> update(int id, RecurringIncomeDraft draft) async {
    final name = await _validated(draft, ignoringId: id);
    final period = await _periods.ensureCurrent();
    await _db.transaction(() async {
      await _db.recurringIncomesDao.updateFields(
        id,
        RecurringIncomesCompanion(name: Value(name), amount: Value(draft.amount)),
      );
      await _db.transactionsDao.updateRecurringInPeriod(
        id,
        period.id,
        description: name,
        amount: draft.amount,
      );
    });
  }

  @override
  Future<void> setActive(int id, {required bool isActive}) async {
    final period = await _periods.ensureCurrent();
    await _db.transaction(() async {
      await _db.recurringIncomesDao.updateFields(
        id,
        RecurringIncomesCompanion(isActive: Value(isActive)),
      );
      if (!isActive) {
        await _db.transactionsDao.deleteRecurringInPeriod(id, period.id);
      }
    });
    if (isActive) await _periods.ensureCurrent(); // vuelve a aplicarlo a este mes
  }

  @override
  Future<void> delete(int id) async {
    final period = await _periods.ensureCurrent();
    await _db.transaction(() async {
      await _db.transactionsDao.deleteRecurringInPeriod(id, period.id);
      await _db.transactionsDao.detachRecurring(id); // los meses pasados se conservan
      await _db.recurringIncomesDao.deleteIncome(id);
    });
  }

  /// Nombre limpio, o `InvalidInputException` si algo no es válido.
  Future<String> _validated(RecurringIncomeDraft draft, {int? ignoringId}) async {
    final name = draft.name.trim();
    if (draft.amount <= 0) {
      throw const InvalidInputException('Escribe un monto mayor a 0');
    }
    if (name.isEmpty) {
      throw const InvalidInputException('Indica de dónde viene el ingreso');
    }
    if (name.length > _maxNameLength) {
      throw const InvalidInputException('El nombre es muy largo (máximo 40 letras)');
    }
    final existing = await _db.recurringIncomesDao.all();
    final repeated = existing.any(
      (r) => r.id != ignoringId && r.name.toLowerCase() == name.toLowerCase(),
    );
    if (repeated) {
      throw const InvalidInputException('Ya tienes un ingreso fijo con ese nombre');
    }
    return name;
  }
}
