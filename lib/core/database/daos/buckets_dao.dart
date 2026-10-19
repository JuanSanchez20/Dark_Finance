import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/buckets_table.dart';

part 'buckets_dao.g.dart';

@DriftAccessor(tables: [Buckets])
class BucketsDao extends DatabaseAccessor<AppDatabase>
    with _$BucketsDaoMixin {
  BucketsDao(super.db);

  Future<List<Bucket>> byPeriod(int periodId) =>
      (select(buckets)
            ..where((t) => t.periodId.equals(periodId))
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .get();

  Future<int> insertBucket(BucketsCompanion entry) =>
      into(buckets).insert(entry);

  Future<bool> updateBucket(Bucket entry) =>
      update(buckets).replace(entry);

  Future<void> insertAll(List<BucketsCompanion> entries) =>
      batch((b) => b.insertAll(buckets, entries));
}
