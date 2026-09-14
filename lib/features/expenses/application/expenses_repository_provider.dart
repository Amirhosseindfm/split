import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database_provider.dart';
import '../data/drift_expenses_repository.dart';
import '../domain/expenses_repository.dart';

/// نقطه Dependency Injection: تعویض پیاده‌سازی فقط اینجا انجام می‌شود.
final expensesRepositoryProvider = Provider<ExpensesRepository>((ref) {
  return DriftExpensesRepository(ref.watch(appDatabaseProvider));
});
