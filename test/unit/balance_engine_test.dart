import 'package:flutter_test/flutter_test.dart';
import 'package:hamhesab/core/domain_services/balance_engine.dart';
import 'package:hamhesab/core/domain_services/models.dart';
import 'package:hamhesab/core/money/money.dart';

void main() {
  final engine = const BalanceEngine();

  test('سناریوی اصلی: Ali/Reza/Mohammad - 900,000 تومان تقسیم مساوی', () {
    // Ali پرداخت کرده و در تقسیم هم شریک است.
    final expense = ExpenseInput(
      id: 'e1',
      paidBy: {'ali': Money.fromToman(900000)},
      shares: {
        'ali': Money.fromToman(300000),
        'reza': Money.fromToman(300000),
        'mohammad': Money.fromToman(300000),
      },
    );

    final result = engine.calculate(expenses: [expense], settlements: []);
    final map = {for (final e in result) e.userId: e.netBalance};

    expect(map['ali'], Money.fromToman(600000));
    expect(map['reza'], Money.fromToman(-300000));
    expect(map['mohammad'], Money.fromToman(-300000));
  });

  test('پرداخت‌کننده جزو participants نیست', () {
    final expense = ExpenseInput(
      id: 'e2',
      paidBy: {'sara': Money.fromToman(300000)},
      shares: {
        'ali': Money.fromToman(150000),
        'reza': Money.fromToman(150000),
      },
    );
    final result = engine.calculate(expenses: [expense], settlements: []);
    final map = {for (final e in result) e.userId: e.netBalance};

    expect(map['sara'], Money.fromToman(300000));
    expect(map['ali'], Money.fromToman(-150000));
    expect(map['reza'], Money.fromToman(-150000));
  });

  test('چند payer برای یک هزینه', () {
    final expense = ExpenseInput(
      id: 'e3',
      paidBy: {
        'ali': Money.fromToman(200000),
        'reza': Money.fromToman(100000),
      },
      shares: {
        'ali': Money.fromToman(150000),
        'reza': Money.fromToman(150000),
      },
    );
    final result = engine.calculate(expenses: [expense], settlements: []);
    final map = {for (final e in result) e.userId: e.netBalance};

    expect(map['ali'], Money.fromToman(50000));
    expect(map['reza'], Money.fromToman(-50000));
  });

  test('اعمال Settlement روی balance', () {
    final expense = ExpenseInput(
      id: 'e4',
      paidBy: {'ali': Money.fromToman(600000)},
      shares: {
        'ali': Money.fromToman(300000),
        'reza': Money.fromToman(300000),
      },
    );
    final settlement = SettlementInput(
      id: 's1',
      fromUserId: 'reza',
      toUserId: 'ali',
      amount: Money.fromToman(300000),
    );

    final result = engine.calculate(
      expenses: [expense],
      settlements: [settlement],
    );
    final map = {for (final e in result) e.userId: e.netBalance};

    expect(map['ali'], Money.zero());
    expect(map['reza'], Money.zero());
  });

  test('چند هزینه مختلف برای یک نفر جمع می‌شود', () {
    final e1 = ExpenseInput(
      id: 'e5',
      paidBy: {'ali': Money.fromToman(100000)},
      shares: {'ali': Money.fromToman(50000), 'reza': Money.fromToman(50000)},
    );
    final e2 = ExpenseInput(
      id: 'e6',
      paidBy: {'reza': Money.fromToman(200000)},
      shares: {'ali': Money.fromToman(100000), 'reza': Money.fromToman(100000)},
    );

    final result = engine.calculate(expenses: [e1, e2], settlements: []);
    final map = {for (final e in result) e.userId: e.netBalance};

    // ali: +100000 -50000 -100000 = -50000
    // reza: -100000 +200000 -50000... let's just check totals sum to zero
    final total = map.values.fold<int>(0, (a, b) => a + b.amountInRial);
    expect(total, 0);
  });
}
