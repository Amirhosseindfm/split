import '../../../core/domain_services/models.dart';

/// Repository abstraction — پیاده‌سازی واقعی (Drift/Firebase/Backend) در لایه data
/// جای‌گزین می‌شود بدون تغییر در presentation یا domain services.
abstract class ExpensesRepository {
  /// خروجی آماده برای مصرف مستقیم توسط BalanceEngine.
  Future<List<ExpenseInput>> getAllActiveAsEngineInput({String? groupId});
}
