import '../money/money.dart';
import 'models.dart';

/// سرویس مستقل و pure برای محاسبه balance هر عضو گروه.
///
/// قانون: هیچ Widget یا لایه UI نباید خودش balance محاسبه کند.
/// تمام Balanceها فقط از Expenses + Settlements محاسبه می‌شوند (بدون fake/hard-coded data).
class BalanceEngine {
  const BalanceEngine();

  /// [expenses] و [settlements] باید شامل رکوردهای فعال (غیرحذف‌شده) باشند.
  ///
  /// خروجی: لیست BalanceEntry برای هر کاربری که در محاسبات ظاهر شده،
  /// مرتب‌شده بر اساس userId برای خروجی deterministic.
  List<BalanceEntry> calculate({
    required List<ExpenseInput> expenses,
    required List<SettlementInput> settlements,
  }) {
    final Map<String, int> totals = {}; // userId -> net rial

    void add(String userId, Money delta) {
      totals[userId] = (totals[userId] ?? 0) + delta.amountInRial;
    }

    for (final expense in expenses) {
      expense.paidBy.forEach((userId, paid) => add(userId, paid));
      expense.shares.forEach((userId, share) => add(userId, -share));
    }

    for (final settlement in settlements) {
      // پرداخت‌کننده (from) به همان اندازه که تسویه کرده، بدهی‌اش کم می‌شود
      // یعنی balance او به سمت صفر/مثبت حرکت می‌کند.
      add(settlement.fromUserId, settlement.amount);
      add(settlement.toUserId, -settlement.amount);
    }

    final entries = totals.entries
        .map((e) => BalanceEntry(userId: e.key, netBalance: Money(e.value)))
        .toList()
      ..sort((a, b) => a.userId.compareTo(b.userId));

    return entries;
  }

  /// خالص بدهی/طلب یک کاربر خاص.
  Money netBalanceFor(
    String userId, {
    required List<ExpenseInput> expenses,
    required List<SettlementInput> settlements,
  }) {
    final all = calculate(expenses: expenses, settlements: settlements);
    final match = all.where((e) => e.userId == userId);
    return match.isEmpty ? Money.zero() : match.first.netBalance;
  }
}
