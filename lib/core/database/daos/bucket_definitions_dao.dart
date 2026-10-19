import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/bucket_definitions_table.dart';

part 'bucket_definitions_dao.g.dart';

@DriftAccessor(tables: [BucketDefinitions])
class BucketDefinitionsDao extends DatabaseAccessor<AppDatabase>
    with _$BucketDefinitionsDaoMixin {
  BucketDefinitionsDao(super.db);

  Future<List<BucketDefinition>> all() =>
      (select(bucketDefinitions)
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .get();
}
