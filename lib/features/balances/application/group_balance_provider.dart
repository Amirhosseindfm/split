import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/domain_services/balance_engine.dart';
import '../../../core/domain_services/debt_simplifier.dart';
import '../../../core/domain_services/models.dart';
import '../../expenses/application/expenses_repository_provider.dart';
import '../../settlements/application/settlements_repository_provider.dart';

class GroupBalanceResult {
  final List<BalanceEntry> balances;
  final List<SimplifiedDebt> simplifiedDebts;

  const GroupBalanceResult({required this.balances, required this.simplifiedDebts});
}

/// این Provider تنها مصرف‌کننده BalanceEngine/DebtSimplifier است.
/// UI (GroupDetailPage) هرگز خودش محاسبه‌ای انجام نمی‌دهد.
final groupBalanceProvider =
    FutureProvider.family<GroupBalanceResult, String>((ref, groupId) async {
  final expensesRepo = ref.watch(expensesRepositoryProvider);
  final settlementsRepo = ref.watch(settlementsRepositoryProvider);

  final expenses = await expensesRepo.getAllActiveAsEngineInput(groupId: groupId);
  final settlements = await settlementsRepo.getAllAsEngineInput(groupId: groupId);

  const engine = BalanceEngine();
  const simplifier = DebtSimplifier();

  final balances = engine.calculate(expenses: expenses, settlements: settlements);
  final simplifiedDebts = simplifier.simplify(balances);

  return GroupBalanceResult(balances: balances, simplifiedDebts: simplifiedDebts);
});
