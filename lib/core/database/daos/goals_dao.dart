import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/goals_table.dart';

part 'goals_dao.g.dart';

@DriftAccessor(tables: [Goals])
class GoalsDao extends DatabaseAccessor<AppDatabase> with _$GoalsDaoMixin {
  GoalsDao(super.db);

  Future<List<Goal>> activeGoals() =>
      (select(goals)..where((t) => t.status.equals('active'))).get();

  Stream<List<Goal>> watchActiveGoals() =>
      (select(goals)..where((t) => t.status.equals('active'))).watch();

  Future<int> insertGoal(GoalsCompanion entry) =>
      into(goals).insert(entry);

  Future<bool> updateGoal(Goal entry) => update(goals).replace(entry);

  Future<bool> addContribution(int goalId, double amount) async {
    final goal = await (select(goals)..where((t) => t.id.equals(goalId)))
        .getSingleOrNull();
    if (goal == null) return false;
    final newAmount = goal.currentAmount + amount;
    final newStatus =
        newAmount >= goal.targetAmount ? 'completed' : goal.status;
    await update(goals).replace(
      goal.copyWith(currentAmount: newAmount, status: newStatus),
    );
    return true;
  }
}
