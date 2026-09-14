import 'package:flutter_test/flutter_test.dart';
import 'package:hamhesab/core/domain_services/debt_simplifier.dart';
import 'package:hamhesab/core/domain_services/models.dart';
import 'package:hamhesab/core/money/money.dart';

void main() {
  final simplifier = const DebtSimplifier();

  test('زنجیره A->B->C باید به A->C ساده شود', () {
    // A بدهکار 500 به B، B بدهکار 500 به C
    // یعنی: A: -500, B: 0 (چون هم بدهکار هم طلبکار 500)، C: +500
    final balances = [
      BalanceEntry(userId: 'A', netBalance: Money.fromToman(-500)),
      BalanceEntry(userId: 'B', netBalance: Money.fromToman(0)),
      BalanceEntry(userId: 'C', netBalance: Money.fromToman(500)),
    ];

    final result = simplifier.simplify(balances);

    expect(result.length, 1);
    expect(result.first.fromUserId, 'A');
    expect(result.first.toUserId, 'C');
    expect(result.first.amount, Money.fromToman(500));
  });

  test('سناریوی Ali/Reza/Mohammad: 2 تراکنش برای تسویه کامل', () {
    final balances = [
      BalanceEntry(userId: 'ali', netBalance: Money.fromToman(600000)),
      BalanceEntry(userId: 'reza', netBalance: Money.fromToman(-300000)),
      BalanceEntry(userId: 'mohammad', netBalance: Money.fromToman(-300000)),
    ];

    final result = simplifier.simplify(balances);

    expect(result.length, 2);
    // هر دو تراکنش باید به ali برسند و جمعشان 600000 باشد
    final totalToAli = result
        .where((d) => d.toUserId == 'ali')
        .fold<int>(0, (sum, d) => sum + d.amount.toman);
    expect(totalToAli, 600000);
  });

  test('balanceهای صفر نادیده گرفته می‌شوند', () {
    final balances = [
      BalanceEntry(userId: 'a', netBalance: Money.zero()),
      BalanceEntry(userId: 'b', netBalance: Money.fromToman(100)),
      BalanceEntry(userId: 'c', netBalance: Money.fromToman(-100)),
    ];
    final result = simplifier.simplify(balances);
    expect(result.length, 1);
    expect(result.first.fromUserId, 'c');
    expect(result.first.toUserId, 'b');
  });

  test('لیست خالی -> خروجی خالی', () {
    expect(simplifier.simplify([]), isEmpty);
  });

  test('جمع کل بدهی بعد از simplify باید با جمع اولیه برابر باشد', () {
    final balances = [
      BalanceEntry(userId: 'a', netBalance: Money.fromToman(700)),
      BalanceEntry(userId: 'b', netBalance: Money.fromToman(-200)),
      BalanceEntry(userId: 'c', netBalance: Money.fromToman(-500)),
    ];
    final result = simplifier.simplify(balances);
    final totalSettled = result.fold<int>(0, (sum, d) => sum + d.amount.toman);
    expect(totalSettled, 700);
  });
}
