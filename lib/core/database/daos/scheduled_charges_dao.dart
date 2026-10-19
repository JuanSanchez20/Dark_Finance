import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/scheduled_charges_table.dart';

part 'scheduled_charges_dao.g.dart';

@DriftAccessor(tables: [ScheduledCharges])
class ScheduledChargesDao extends DatabaseAccessor<AppDatabase>
    with _$ScheduledChargesDaoMixin {
  ScheduledChargesDao(super.db);

  Future<List<ScheduledCharge>> allActive() =>
      (select(scheduledCharges)..where((t) => t.isActive.equals(true))).get();

  /// Retorna cobros programados para el día [day] del mes.
  Future<List<ScheduledCharge>> forDay(int day) =>
      (select(scheduledCharges)
            ..where((t) => t.dayOfMonth.equals(day) & t.isActive.equals(true)))
          .get();

  Future<int> insertCharge(ScheduledChargesCompanion entry) =>
      into(scheduledCharges).insert(entry);

  Future<bool> updateCharge(ScheduledCharge entry) =>
      update(scheduledCharges).replace(entry);

  Future<int> deleteCharge(int id) =>
      (delete(scheduledCharges)..where((t) => t.id.equals(id))).go();
}
