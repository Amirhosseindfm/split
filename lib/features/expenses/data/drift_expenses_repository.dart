import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/domain_services/models.dart' as domain;
import '../../../core/money/money.dart';
import '../domain/expense_models.dart';
import '../domain/expenses_repository.dart';

const _uuid = Uuid();

class DriftExpensesRepository implements ExpensesRepository {
  final AppDatabase _db;
  DriftExpensesRepository(this._db);

  @override
  Future<List<domain.ExpenseInput>> getAllActiveAsEngineInput({String? groupId}) async {
    final expenseQuery = _db.select(_db.expenses)
      ..where((e) => e.isDeleted.equals(false));
    if (groupId != null) {
      expenseQuery.where((e) => e.groupId.equals(groupId));
    }
    final expenseRows = await expenseQuery.get();

    final result = <domain.ExpenseInput>[];
    for (final expense in expenseRows) {
      final payerRows = await (_db.select(_db.expensePayers)
            ..where((p) => p.expenseId.equals(expense.id)))
          .get();
      final shareRows = await (_db.select(_db.expenseShares)
            ..where((s) => s.expenseId.equals(expense.id)))
          .get();

      result.add(domain.ExpenseInput(
        id: expense.id,
        paidBy: {for (final p in payerRows) p.userId: Money(p.paidAmountRial)},
        shares: {for (final s in shareRows) s.userId: Money(s.shareAmountRial)},
      ));
    }
    return result;
  }

  @override
  Future<String> createExpense(CreateExpenseInput input) async {
    final expenseId = _uuid.v4();
    await _db.transaction(() async {
      await _db.into(_db.expenses).insert(ExpensesCompanion.insert(
            id: expenseId,
            groupId: input.groupId,
            title: input.title,
            amountRial: input.amount.amountInRial,
            splitMethod: input.splitMethod.name,
            category: Value(input.category),
            note: Value(input.note),
            date: input.date,
            createdBy: input.createdBy,
          ));

      for (final entry in input.paidBy.entries) {
        await _db.into(_db.expensePayers).insert(ExpensePayersCompanion.insert(
              expenseId: expenseId,
              userId: entry.key,
              paidAmountRial: entry.value.amountInRial,
            ));
      }

      for (final entry in input.shares.entries) {
        await _db.into(_db.expenseShares).insert(ExpenseSharesCompanion.insert(
              expenseId: expenseId,
              userId: entry.key,
              shareAmountRial: entry.value.amountInRial,
            ));
      }
    });
    return expenseId;
  }

  @override
  Stream<List<ExpenseHistoryItem>> watchHistory(String groupId, {String currentUserId = ''}) {
    final query = _db.select(_db.expenses)
      ..where((e) => e.groupId.equals(groupId) & e.isDeleted.equals(false))
      ..orderBy([(e) => OrderingTerm.desc(e.date)]);

    return query.watch().asyncMap((rows) async {
      final items = <ExpenseHistoryItem>[];
      for (final row in rows) {
        final payerRows = await (_db.select(_db.expensePayers).join([
          innerJoin(_db.users, _db.users.id.equalsExp(_db.expensePayers.userId)),
        ])
              ..where(_db.expensePayers.expenseId.equals(row.id)))
            .get();

        final payerNames = payerRows.map((r) => r.readTable(_db.users).name).toList();
        final summary = payerNames.length <= 1
            ? (payerNames.isEmpty ? '' : payerNames.first)
            : '${payerNames.first} و ${payerNames.length - 1} نفر دیگر';

        Money myShare = Money.zero();
        if (currentUserId.isNotEmpty) {
          final myShareRow = await (_db.select(_db.expenseShares)
                ..where((s) =>
                    s.expenseId.equals(row.id) & s.userId.equals(currentUserId)))
              .getSingleOrNull();
          if (myShareRow != null) myShare = Money(myShareRow.shareAmountRial);
        }

        items.add(ExpenseHistoryItem(
          id: row.id,
          title: row.title,
          amount: Money(row.amountRial),
          category: row.category,
          date: row.date,
          payerNamesSummary: summary,
          myShare: myShare,
        ));
      }
      return items;
    });
  }

  @override
  Future<void> softDeleteExpense(String expenseId) async {
    await (_db.update(_db.expenses)..where((e) => e.id.equals(expenseId)))
        .write(const ExpensesCompanion(isDeleted: Value(true)));
  }
}
