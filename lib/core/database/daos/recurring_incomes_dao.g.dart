// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_incomes_dao.dart';

// ignore_for_file: type=lint
mixin _$RecurringIncomesDaoMixin on DatabaseAccessor<AppDatabase> {
  $RecurringIncomesTable get recurringIncomes =>
      attachedDatabase.recurringIncomes;
  RecurringIncomesDaoManager get managers => RecurringIncomesDaoManager(this);
}

class RecurringIncomesDaoManager {
  final _$RecurringIncomesDaoMixin _db;
  RecurringIncomesDaoManager(this._db);
  $$RecurringIncomesTableTableManager get recurringIncomes =>
      $$RecurringIncomesTableTableManager(
        _db.attachedDatabase,
        _db.recurringIncomes,
      );
}
