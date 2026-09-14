import '../../../core/domain_services/models.dart';
import '../domain/expenses_repository.dart';

/// پیاده‌سازی موقت In-Memory برای مرحله اسکلت‌سازی/توسعه اولیه.
/// TODO: جایگزینی با DriftExpensesRepository متصل به core/database.
class InMemoryExpensesRepository implements ExpensesRepository {
  final List<ExpenseInput> _expenses = [];

  void addForTesting(ExpenseInput expense) => _expenses.add(expense);

  @override
  Future<List<ExpenseInput>> getAllActiveAsEngineInput({String? groupId}) async {
    return List.unmodifiable(_expenses);
  }
}
