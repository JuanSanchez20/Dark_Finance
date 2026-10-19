// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bucket_definitions_dao.dart';

// ignore_for_file: type=lint
mixin _$BucketDefinitionsDaoMixin on DatabaseAccessor<AppDatabase> {
  $BucketDefinitionsTable get bucketDefinitions =>
      attachedDatabase.bucketDefinitions;
  BucketDefinitionsDaoManager get managers => BucketDefinitionsDaoManager(this);
}

class BucketDefinitionsDaoManager {
  final _$BucketDefinitionsDaoMixin _db;
  BucketDefinitionsDaoManager(this._db);
  $$BucketDefinitionsTableTableManager get bucketDefinitions =>
      $$BucketDefinitionsTableTableManager(
        _db.attachedDatabase,
        _db.bucketDefinitions,
      );
}
