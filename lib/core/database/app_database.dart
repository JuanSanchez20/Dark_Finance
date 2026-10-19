import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'daos/bucket_definitions_dao.dart';
import 'daos/buckets_dao.dart';
import 'daos/categories_dao.dart';
import 'daos/goals_dao.dart';
import 'daos/merchant_rules_dao.dart';
import 'daos/periods_dao.dart';
import 'daos/recurring_incomes_dao.dart';
import 'daos/scheduled_charges_dao.dart';
import 'daos/transactions_dao.dart';
import 'seed/default_data.dart';
import 'tables/bucket_definitions_table.dart';
import 'tables/buckets_table.dart';
import 'tables/categories_table.dart';
import 'tables/enums.dart';
import 'tables/goals_table.dart';
import 'tables/merchant_rules_table.dart';
import 'tables/monthly_periods_table.dart';
import 'tables/recurring_incomes_table.dart';
import 'tables/scheduled_charges_table.dart';
import 'tables/transactions_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    MonthlyPeriods,
    BucketDefinitions,
    Buckets,
    Categories,
    Transactions,
    RecurringIncomes,
    Goals,
    MerchantRules,
    ScheduledCharges,
  ],
  daos: [
    PeriodsDao,
    BucketDefinitionsDao,
    BucketsDao,
    CategoriesDao,
    TransactionsDao,
    RecurringIncomesDao,
    GoalsDao,
    MerchantRulesDao,
    ScheduledChargesDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Para pruebas: recibe una conexión (por ejemplo en memoria) en lugar del archivo real.
  AppDatabase.forTesting(super.connection);

  /// Sube este número cada vez que cambies una tabla.
  ///
  /// MIENTRAS LA APP ESTÁ EN PRUEBAS: al subirlo, la base se borra y se vuelve a
  /// crear vacía (ver [migration]). Cuando haya datos reales que cuidar, esto debe
  /// cambiar por migraciones que conserven los datos.
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedBuckets();
          await _seedCategories();
        },
        onUpgrade: (m, from, to) async {
          // Fase de pruebas: se recrea todo desde cero.
          for (final table in allTables.toList().reversed) {
            await m.drop(table);
          }
          await m.createAll();
          await _seedBuckets();
          await _seedCategories();
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'dark_finance_db');
  }

  Future<void> _seedBuckets() async {
    await batch((b) {
      b.insertAll(bucketDefinitions, [
        for (var i = 0; i < defaultBuckets.length; i++)
          BucketDefinitionsCompanion.insert(
            key: defaultBuckets[i].key,
            name: defaultBuckets[i].name,
            description: defaultBuckets[i].description,
            defaultPercent: defaultBuckets[i].percent,
            sortOrder: i,
          ),
      ]);
    });
  }

  Future<void> _seedCategories() async {
    final idByKey = {
      for (final d in await bucketDefinitionsDao.all()) d.key: d.id,
    };
    await batch((b) {
      b.insertAll(categories, [
        for (final c in defaultCategories)
          CategoriesCompanion.insert(
            name: c.name,
            icon: c.icon,
            color: c.color,
            defaultBucketId: Value(idByKey[c.bucketKey]),
            isFixed: Value(c.isFixed),
          ),
      ]);
    });
  }
}
