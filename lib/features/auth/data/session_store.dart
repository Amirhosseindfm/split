import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// ذخیره‌ی امن session (بخش 39 سند - Security: Secure Storage, Token management).
/// هیچ اطلاعات حساسی به‌صورت plaintext یا در log ذخیره/چاپ نمی‌شود.
class SessionStore {
  final FlutterSecureStorage _storage;
  SessionStore([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'current_user_id';

  Future<String?> readUserId() => _storage.read(key: _key);

  Future<void> saveUserId(String userId) => _storage.write(key: _key, value: userId);

  Future<void> clear() => _storage.delete(key: _key);
}
