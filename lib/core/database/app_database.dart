import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

part 'app_database.g.dart';

/// نکته Build: این فایل به codegen نیاز دارد. قبل از اجرا/بیلد پروژه اجرا کنید:
///   dart run build_runner build --delete-conflicting-outputs
/// (این مرحله در CI/flutter-ci.yml هم قبل از analyze/test/build انجام می‌شود.)
@DriftDatabase(
  tables: [
    Users,
    Groups,
    GroupMembers,
    Expenses,
    ExpensePayers,
    ExpenseShares,
    Settlements,
    SyncLog,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  /// سازنده‌ی کمکی برای تست: دیتابیس in-memory (بدون نوشتن روی دیسک).
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'hamhesab.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
