// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'periods_dao.dart';

// ignore_for_file: type=lint
mixin _$PeriodsDaoMixin on DatabaseAccessor<AppDatabase> {
  $MonthlyPeriodsTable get monthlyPeriods => attachedDatabase.monthlyPeriods;
  PeriodsDaoManager get managers => PeriodsDaoManager(this);
}

class PeriodsDaoManager {
  final _$PeriodsDaoMixin _db;
  PeriodsDaoManager(this._db);
  $$MonthlyPeriodsTableTableManager get monthlyPeriods =>
      $$MonthlyPeriodsTableTableManager(
        _db.attachedDatabase,
        _db.monthlyPeriods,
      );
}
