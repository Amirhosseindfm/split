import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamhesab/main.dart';

void main() {
  testWidgets('App boots and shows onboarding first slide', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: HamHesabApp()));
    await tester.pumpAndSettle();

    expect(find.text('خرج‌هات رو ثبت کن.'), findsOneWidget);
    expect(find.text('بعدی'), findsOneWidget);
  });

  testWidgets('Onboarding navigates through slides to login', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: HamHesabApp()));
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
