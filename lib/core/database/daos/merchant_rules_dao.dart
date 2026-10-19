import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/merchant_rules_table.dart';

part 'merchant_rules_dao.g.dart';

@DriftAccessor(tables: [MerchantRules])
class MerchantRulesDao extends DatabaseAccessor<AppDatabase>
    with _$MerchantRulesDaoMixin {
  MerchantRulesDao(super.db);

  Future<List<MerchantRule>> allActive() =>
      (select(merchantRules)..where((t) => t.isActive.equals(true))).get();

  /// Busca la primera regla cuyo patrón esté contenido en [merchant] (sin distinguir mayúsculas).
  Future<MerchantRule?> findForMerchant(String merchant) async {
    final rules = await allActive();
    final lower = merchant.toLowerCase();
    try {
      return rules.firstWhere(
        (r) => lower.contains(r.merchantPattern.toLowerCase()),
      );
    } catch (_) {
      return null;
    }
  }

  Future<int> insertRule(MerchantRulesCompanion entry) =>
      into(merchantRules).insert(entry);

  Future<bool> updateRule(MerchantRule entry) =>
      update(merchantRules).replace(entry);

  Future<int> deleteRule(int id) =>
      (delete(merchantRules)..where((t) => t.id.equals(id))).go();
}
