import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database_provider.dart';
import '../data/auth_repository.dart';
import '../data/session_store.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(appDatabaseProvider));
});

final sessionStoreProvider = Provider<SessionStore>((ref) => SessionStore());

/// شناسه‌ی کاربر فعلی؛ null یعنی هنوز لاگین نشده.
/// در Splash خوانده می‌شود و بعد از لاگین موفق set می‌شود.
final currentUserIdProvider = StateProvider<String?>((ref) => null);

/// نسخه‌ی non-null برای Providerهایی که فقط بعد از لاگین صدا زده می‌شوند
/// (مثل overall_balance_provider که در HomeShellPage است).
final requireCurrentUserIdProvider = Provider<String>((ref) {
  final id = ref.watch(currentUserIdProvider);
  if (id == null) {
    throw StateError('کاربری لاگین نکرده؛ این Provider نباید قبل از لاگین صدا زده شود.');
  }
  return id;
});
