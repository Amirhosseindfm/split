import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/in_memory_expenses_repository.dart';
import '../domain/expenses_repository.dart';

/// نقطه Dependency Injection: تعویض پیاده‌سازی (Drift/Backend) فقط اینجا انجام می‌شود.
final expensesRepositoryProvider = Provider<ExpensesRepository>((ref) {
  return InMemoryExpensesRepository();
});
