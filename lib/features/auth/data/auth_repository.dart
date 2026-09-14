import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';

/// MVP: بدون Backend واقعی OTP. شماره موبایل تأییدشده به‌عنوان کاربر فعلی
/// در دیتابیس محلی ذخیره می‌شود. معماری آماده‌ی جایگزینی با OTP/Backend واقعی است
/// (فقط این کلاس عوض می‌شود، بقیه‌ی اپ دست‌نخورده می‌ماند).
class AuthRepository {
  final AppDatabase _db;
  AuthRepository(this._db);


  /// ورود با شماره موبایل: اگر کاربر وجود نداشت، پروفایل جدید ساخته می‌شود.
  Future<String> loginWithPhone({
    required String phone,
    required String name,
  }) async {
    final existing = await (_db.select(_db.users)
          ..where((u) => u.phone.equals(phone)))
        .getSingleOrNull();

    if (existing != null) return existing.id;

    final id = 'user_${DateTime.now().microsecondsSinceEpoch}';
    await _db.into(_db.users).insert(UsersCompanion.insert(
          id: id,
          name: name,
          phone: phone,
        ));
    return id;
  }

  Future<User?> getUser(String userId) {
    return (_db.select(_db.users)..where((u) => u.id.equals(userId)))
        .getSingleOrNull();
  }

  Future<void> updateProfile({
    required String userId,
    String? name,
    String? avatarPath,
  }) async {
    await (_db.update(_db.users)..where((u) => u.id.equals(userId))).write(
      UsersCompanion(
        name: name != null ? Value(name) : const Value.absent(),
        avatarPath: avatarPath != null ? Value(avatarPath) : const Value.absent(),
      ),
    );
  }
}
