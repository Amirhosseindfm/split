// این تست "Integration" در سطح Repository + Domain Services است (نه UI):
// از یک دیتابیس واقعی Drift (in-memory، بدون نوشتن روی دیسک) استفاده می‌کند
// و کل مسیر User A -> Create Group -> Add User B -> Add Expense -> Split ->
// Calculate Balance -> Settle Debt -> Verify final balance (بخش 42 سند) را
// دقیقاً همان‌طور که در برنامه‌ی واقعی اتفاق می‌افتد، تست می‌کند.
//
// یک integration_test کامل در سطح UI (با flutter drive روی شبیه‌ساز/دستگاه واقعی)
// می‌تواند به‌عنوان قدم بعدی به پوشه integration_test/ اضافه شود.

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hamhesab/core/database/app_database.dart';
import 'package:hamhesab/core/domain_services/balance_engine.dart';
import 'package:hamhesab/core/domain_services/debt_simplifier.dart';
import 'package:hamhesab/core/domain_services/split_calculator.dart';
import 'package:hamhesab/core/money/money.dart';
import 'package:hamhesab/features/expenses/data/drift_expenses_repository.dart';
import 'package:hamhesab/features/expenses/domain/expense_models.dart';
import 'package:hamhesab/features/groups/data/drift_groups_repository.dart';
import 'package:hamhesab/features/settlements/data/drift_settlements_repository.dart';

void main() {
  late AppDatabase db;
  late DriftGroupsRepository groupsRepo;
  late DriftExpensesRepository expensesRepo;
  late DriftSettlementsRepository settlementsRepo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    groupsRepo = DriftGroupsRepository(db);
    expensesRepo = DriftExpensesRepository(db);
    settlementsRepo = DriftSettlementsRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('سناریوی کامل: Create Group -> Add Member -> Expense -> Balance -> Settle -> Verify', () async {
    // 1. User A ثبت‌نام می‌کند و گروه می‌سازد.
    const userA = 'userA';
    await db.into(db.users).insert(
          UsersCompanion.insert(id: userA, name: 'Ali', phone: '09120000001'),
        );
    final groupId = await groupsRepo.createGroup(
      name: 'سفر شمال',
      category: 'سفر',
      createdByUserId: userA,
    );

    // 2. Add User B به گروه.
    await groupsRepo.addMember(groupId: groupId, name: 'Reza', phone: '09120000002');

    final group = await groupsRepo.watchGroup(groupId).first;
    expect(group, isNotNull);
    expect(group!.members.length, 2);
    final userB = group.members.firstWhere((m) => m.name == 'Reza').userId;

    // 3. Add Expense + Split Expense (تقسیم مساوی 900,000 تومان بین Ali و Reza + Mohammad)
    const userC = 'userC';
    await db.into(db.users).insert(
          UsersCompanion.insert(id: userC, name: 'Mohammad', phone: '09120000003'),
        );
    await groupsRepo.addMember(groupId: groupId, name: 'Mohammad', phone: '09120000003');

    const calculator = SplitCalculator();
    final amount = Money.fromToman(900000);
    final participants = [userA, userB, userC];
    final shares = calculator.equal(amount, participants);

    await expensesRepo.createExpense(CreateExpenseInput(
      groupId: groupId,
      title: 'شام',
      amount: amount,
      paidBy: {userA: amount},
      shares: shares,
      splitMethod: SplitMethod.equal,
      category: 'غذا',
      date: DateTime.now(),
      createdBy: userA,
    ));

    // 4. Calculate Balance
    final expenseInputs = await expensesRepo.getAllActiveAsEngineInput(groupId: groupId);
    final settlementInputs = await settlementsRepo.getAllAsEngineInput(groupId: groupId);

    const engine = BalanceEngine();
    final balances = engine.calculate(expenses: expenseInputs, settlements: settlementInputs);
    final balanceMap = {for (final b in balances) b.userId: b.netBalance};

    expect(balanceMap[userA], Money.fromToman(600000));
    expect(balanceMap[userB], Money.fromToman(-300000));
    expect(balanceMap[userC], Money.fromToman(-300000));

    // 5. Debt Simplification
    const simplifier = DebtSimplifier();
    final simplifiedDebts = simplifier.simplify(balances);
    expect(simplifiedDebts.length, 2);

    // 6. Settle Debt (هر دو بدهکار تسویه می‌کنند)
    for (final debt in simplifiedDebts) {
      await settlementsRepo.createSettlement(
        groupId: groupId,
        fromUserId: debt.fromUserId,
        toUserId: debt.toUserId,
        amount: debt.amount,
      );
    }

    // 7. Verify final balance — بعد از تسویه‌ی کامل، همه باید صفر باشند.
    final finalExpenseInputs = await expensesRepo.getAllActiveAsEngineInput(groupId: groupId);
    final finalSettlementInputs = await settlementsRepo.getAllAsEngineInput(groupId: groupId);
    final finalBalances = engine.calculate(
      expenses: finalExpenseInputs,
      settlements: finalSettlementInputs,
    );

    for (final entry in finalBalances) {
      expect(entry.netBalance, Money.zero(),
          reason: '${entry.userId} باید بعد از تسویه‌ی کامل صفر باشد');
    }

    // Settlement نباید Expense را حذف کرده باشد.
    expect(finalExpenseInputs.length, 1);
  });
}
