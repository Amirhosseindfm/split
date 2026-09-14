import 'package:equatable/equatable.dart';
import '../money/money.dart';

/// ورودی خام برای BalanceEngine — یک هزینه با پرداخت‌کننده‌ها و سهم‌ها.
class ExpenseInput extends Equatable {
  final String id;
  final Map<String, Money> paidBy; // userId -> مبلغی که پرداخت کرده
  final Map<String, Money> shares; // userId -> سهمی که باید بدهد

  const ExpenseInput({
    required this.id,
    required this.paidBy,
    required this.shares,
  });

  @override
  List<Object?> get props => [id, paidBy, shares];
}

/// ورودی خام برای BalanceEngine — یک تسویه‌حساب.
class SettlementInput extends Equatable {
  final String id;
  final String fromUserId;
  final String toUserId;
  final Money amount;

  const SettlementInput({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.amount,
  });

  @override
  List<Object?> get props => [id, fromUserId, toUserId, amount];
}

/// خروجی BalanceEngine برای هر کاربر.
/// مثبت = طلبکار (دیگران به او بدهکارند)
/// منفی = بدهکار (او به دیگران بدهکار است)
class BalanceEntry extends Equatable {
  final String userId;
  final Money netBalance;

  const BalanceEntry({required this.userId, required this.netBalance});

  @override
  List<Object?> get props => [userId, netBalance];
}

/// خروجی DebtSimplifier — یک تراکنش پیشنهادی برای تسویه.
class SimplifiedDebt extends Equatable {
  final String fromUserId; // بدهکار
  final String toUserId; // طلبکار
  final Money amount;

  const SimplifiedDebt({
    required this.fromUserId,
    required this.toUserId,
    required this.amount,
  });

  @override
  List<Object?> get props => [fromUserId, toUserId, amount];

  @override
  String toString() => '$fromUserId -> $toUserId : ${amount.formatToman()}';
}
