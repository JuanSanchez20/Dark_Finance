// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'merchant_rules_dao.dart';

// ignore_for_file: type=lint
mixin _$MerchantRulesDaoMixin on DatabaseAccessor<AppDatabase> {
  $MerchantRulesTable get merchantRules => attachedDatabase.merchantRules;
  MerchantRulesDaoManager get managers => MerchantRulesDaoManager(this);
}

class MerchantRulesDaoManager {
  final _$MerchantRulesDaoMixin _db;
  MerchantRulesDaoManager(this._db);
  $$MerchantRulesTableTableManager get merchantRules =>
      $$MerchantRulesTableTableManager(_db.attachedDatabase, _db.merchantRules);
}
