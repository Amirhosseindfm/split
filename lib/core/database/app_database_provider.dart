import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_database.dart';

/// نمونه‌ی واحد دیتابیس برای کل اپ. جایگزین‌کردن با mock در تست‌ها با
/// override کردن این Provider ممکن است.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
