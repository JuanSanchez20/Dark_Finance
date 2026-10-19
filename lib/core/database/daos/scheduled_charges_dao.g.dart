// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scheduled_charges_dao.dart';

// ignore_for_file: type=lint
mixin _$ScheduledChargesDaoMixin on DatabaseAccessor<AppDatabase> {
  $ScheduledChargesTable get scheduledCharges =>
      attachedDatabase.scheduledCharges;
  ScheduledChargesDaoManager get managers => ScheduledChargesDaoManager(this);
}

class ScheduledChargesDaoManager {
  final _$ScheduledChargesDaoMixin _db;
  ScheduledChargesDaoManager(this._db);
  $$ScheduledChargesTableTableManager get scheduledCharges =>
      $$ScheduledChargesTableTableManager(
        _db.attachedDatabase,
        _db.scheduledCharges,
      );
}
