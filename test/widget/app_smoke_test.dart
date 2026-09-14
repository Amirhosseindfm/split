import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamhesab/features/auth/application/auth_providers.dart';
import 'package:hamhesab/features/auth/data/session_store.dart';
import 'package:hamhesab/main.dart';

/// جایگزین SessionStore که به Secure Storage واقعی (platform channel) دست نمی‌زند؛
/// برای Widget Test که در آن هیچ پلتفرم واقعی در دسترس نیست.
class _FakeSessionStore implements SessionStore {
  @override
  Future<void> clear() async {}

  @override
  Future<String?> readUserId() async => null;

  @override
  Future<void> saveUserId(String userId) async {}
}

void main() {
  final overrides = [sessionStoreProvider.overrideWithValue(_FakeSessionStore())];

  testWidgets('App boots, passes splash, and shows onboarding first slide', (tester) async {
    await tester.pumpWidget(ProviderScope(overrides: overrides, child: const HamHesabApp()));
    await tester.pumpAndSettle();

    expect(find.text('خرج‌هات رو ثبت کن.'), findsOneWidget);
    expect(find.text('بعدی'), findsOneWidget);
  });

  testWidgets('Onboarding navigates through slides to login', (tester) async {
    await tester.pumpWidget(ProviderScope(overrides: overrides, child: const HamHesabApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('بعدی'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('بعدی'));
    await tester.pumpAndSettle();

    expect(find.text('شروع کنیم'), findsOneWidget);

    await tester.tap(find.text('شروع کنیم'));
    await tester.pumpAndSettle();

    expect(find.text('ورود'), findsWidgets);
  });
}
