import '../money/money.dart';

enum SplitMethod { equal, exact, percentage, shares }

class SplitValidationException implements Exception {
  final String messageFa;
  const SplitValidationException(this.messageFa);

  @override
  String toString() => messageFa;
}

/// محاسبه سهم هر شرکت‌کننده بر اساس روش تقسیم انتخاب‌شده.
/// این تنها جای مجاز برای این منطق است (No Duplicate Business Logic).
class SplitCalculator {
  const SplitCalculator();

  /// تقسیم مساوی. ترتیب [participantIds] برای توزیع باقی‌مانده rounding مهم است.
  Map<String, Money> equal(Money total, List<String> participantIds) {
    if (participantIds.isEmpty) {
      throw const SplitValidationException('حداقل یک نفر باید در هزینه شریک باشد.');
    }
    final parts = Money.splitEqually(total, participantIds.length);
    return {
      for (int i = 0; i < participantIds.length; i++) participantIds[i]: parts[i],
    };
  }

  /// مبلغ دقیق برای هر نفر. جمع باید دقیقاً برابر total باشد.
  Map<String, Money> exact(Money total, Map<String, Money> exactShares) {
    if (exactShares.isEmpty) {
      throw const SplitValidationException('حداقل یک نفر باید در هزینه شریک باشد.');
    }
    final sum = exactShares.values.fold<Money>(
      Money.zero(),
      (acc, m) => acc + m,
    );
    if (sum != total) {
      throw const SplitValidationException(
        'مجموع سهم‌ها باید دقیقاً برابر مبلغ کل هزینه باشد.',
      );
    }
    return Map.of(exactShares);
  }

  /// تقسیم درصدی. جمع درصدها باید دقیقاً 100 باشد.
  Map<String, Money> percentage(
    Money total,
    Map<String, double> percentages,
  ) {
    if (percentages.isEmpty) {
      throw const SplitValidationException('حداقل یک نفر باید در هزینه شریک باشد.');
    }
    final sum = percentages.values.fold<double>(0, (a, b) => a + b);
    if ((sum - 100.0).abs() > 0.001) {
      throw const SplitValidationException('مجموع درصدها باید دقیقاً ۱۰۰ باشد.');
    }

    // محاسبه با int rial و توزیع باقی‌مانده deterministic بین بزرگ‌ترین سهم‌ها.
    final ids = percentages.keys.toList();
    final rawShares = <String, int>{};
    int allocated = 0;
    for (final id in ids) {
      final share = (total.amountInRial * percentages[id]! / 100).floor();
      rawShares[id] = share;
      allocated += share;
    }
    int remainder = total.amountInRial - allocated;
    // باقی‌مانده را یکی‌یکی به نفرات (بر اساس ترتیب ورودی) اضافه کن.
    int idx = 0;
    while (remainder > 0 && ids.isNotEmpty) {
      final id = ids[idx % ids.length];
      rawShares[id] = rawShares[id]! + 1;
      remainder--;
      idx++;
    }
    return rawShares.map((id, rial) => MapEntry(id, Money(rial)));
  }

  /// تقسیم بر اساس سهم (share). حداقل یک سهم برای یک نفر لازم است.
  Map<String, Money> shares(Money total, Map<String, int> shareCounts) {
    if (shareCounts.isEmpty || shareCounts.values.every((s) => s <= 0)) {
      throw const SplitValidationException(
        'حداقل یک سهم باید برای یک شرکت‌کننده در نظر گرفته شود.',
      );
    }
    final totalShares = shareCounts.values.fold<int>(0, (a, b) => a + b);
    final ids = shareCounts.keys.toList();
    final rawShares = <String, int>{};
    int allocated = 0;
    for (final id in ids) {
      final portion = (total.amountInRial * shareCounts[id]! / totalShares).floor();
      rawShares[id] = portion;
      allocated += portion;
    }
    int remainder = total.amountInRial - allocated;
    int idx = 0;
    while (remainder > 0 && ids.isNotEmpty) {
      final id = ids[idx % ids.length];
      rawShares[id] = rawShares[id]! + 1;
      remainder--;
      idx++;
    }
    return rawShares.map((id, rial) => MapEntry(id, Money(rial)));
  }

  /// Validation عمومی مبلغ هزینه.
  void validateAmount(Money amount, {Money? maxAllowed}) {
    if (amount.isZero) {
      throw const SplitValidationException('مبلغ نباید صفر باشد.');
    }
    if (amount.isNegative) {
      throw const SplitValidationException('مبلغ نباید منفی باشد.');
    }
    if (maxAllowed != null && amount.amountInRial > maxAllowed.amountInRial) {
      throw const SplitValidationException('مبلغ بیش از حد مجاز است.');
    }
  }
}
