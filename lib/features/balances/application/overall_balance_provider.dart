import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/domain_services/balance_engine.dart';
import '../../../core/money/money.dart';
import '../../expenses/application/expenses_repository_provider.dart';
import '../../settlements/application/settlements_repository_provider.dart';
import '../../auth/application/auth_providers.dart';

class BalanceSummary {
  final Money owedToMe;
  final Money owedByMe;
  final Money net;

  const BalanceSummary({
    required this.owedToMe,
    required this.owedByMe,
    required this.net,
  });
}

/// این Provider تنها مصرف‌کننده BalanceEngine است؛ خودش هیچ محاسبه‌ای انجام نمی‌دهد
/// (طبق قانون No Duplicate Business Logic - بخش 45 سند).
final overallBalanceProvider = FutureProvider<BalanceSummary>((ref) async {
  final currentUserId = ref.watch(requireCurrentUserIdProvider);
  final expensesRepo = ref.watch(expensesRepositoryProvider);
  final settlementsRepo = ref.watch(settlementsRepositoryProvider);

  final expenses = await expensesRepo.getAllActiveAsEngineInput();
  final settlements = await settlementsRepo.getAllAsEngineInput();

  const engine = BalanceEngine();
  final net = engine.netBalanceFor(
    currentUserId,
    expenses: expenses,
    settlements: settlements,
  );

  return BalanceSummary(
    owedToMe: net.isPositive ? net : Money.zero(),
    owedByMe: net.isNegative ? net.abs() : Money.zero(),
    net: net,
  );
});
