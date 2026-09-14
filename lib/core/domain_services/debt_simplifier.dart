import '../money/money.dart';
import 'models.dart';

/// الگوریتم ساده‌سازی بدهی‌ها (Debt Simplification).
///
/// هدف: کمترین تعداد ممکن تراکنش برای تسویه کامل بدهی‌های یک گروه.
/// روش: Greedy Max-Min — در هر مرحله بزرگ‌ترین بدهکار را با بزرگ‌ترین
/// طلبکار تسویه می‌کنیم. این روش استاندارد صنعتی (مشابه Splitwise) است؛
/// اثبات‌شده که تعداد تراکنش را در عمل به‌شدت کاهش می‌دهد، هرچند حل
/// دقیق «حداقل مطلق تراکنش» یک مسئله NP-hard است.
///
/// pure function: بدون side effect، کاملاً تست‌پذیر.
class DebtSimplifier {
  const DebtSimplifier();

  List<SimplifiedDebt> simplify(List<BalanceEntry> balances) {
    // فقط بدهی/طلب غیرصفر را در نظر بگیر.
    final debtors = <MapEntry<String, int>>[];
    final creditors = <MapEntry<String, int>>[];

    for (final entry in balances) {
      final amount = entry.netBalance.amountInRial;
      if (amount < 0) {
        debtors.add(MapEntry(entry.userId, -amount)); // مقدار مثبت بدهی
      } else if (amount > 0) {
        creditors.add(MapEntry(entry.userId, amount));
      }
    }

    // مرتب‌سازی نزولی بر اساس مقدار، و در تساوی بر اساس userId برای پایداری.
    int cmp(MapEntry<String, int> a, MapEntry<String, int> b) {
      final byAmount = b.value.compareTo(a.value);
      return byAmount != 0 ? byAmount : a.key.compareTo(b.key);
    }

    debtors.sort(cmp);
    creditors.sort(cmp);

    final result = <SimplifiedDebt>[];
    int i = 0, j = 0;

    while (i < debtors.length && j < creditors.length) {
      final debtor = debtors[i];
      final creditor = creditors[j];
      final settleAmount =
          debtor.value < creditor.value ? debtor.value : creditor.value;

      if (settleAmount > 0) {
        result.add(SimplifiedDebt(
          fromUserId: debtor.key,
          toUserId: creditor.key,
          amount: Money(settleAmount),
        ));
      }

      debtors[i] = MapEntry(debtor.key, debtor.value - settleAmount);
      creditors[j] = MapEntry(creditor.key, creditor.value - settleAmount);

      if (debtors[i].value == 0) i++;
      if (creditors[j].value == 0) j++;
    }

    return result;
  }
}
