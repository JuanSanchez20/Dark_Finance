// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'buckets_dao.dart';

// ignore_for_file: type=lint
mixin _$BucketsDaoMixin on DatabaseAccessor<AppDatabase> {
  $BucketsTable get buckets => attachedDatabase.buckets;
  BucketsDaoManager get managers => BucketsDaoManager(this);
}

class BucketsDaoManager {
  final _$BucketsDaoMixin _db;
  BucketsDaoManager(this._db);
  $$BucketsTableTableManager get buckets =>
      $$BucketsTableTableManager(_db.attachedDatabase, _db.buckets);
}
