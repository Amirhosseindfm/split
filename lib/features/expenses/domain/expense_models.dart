import '../../../core/domain_services/split_calculator.dart';
import '../../../core/money/money.dart';

/// ورودی برای ساخت یک هزینه‌ی جدید. سهم‌ها از قبل با SplitCalculator محاسبه شده‌اند
/// (طبق قانون: هیچ محاسبه‌ی مالی نباید در UI یا Database تکرار شود).
class CreateExpenseInput {
  final String groupId;
  final String title;
  final Money amount;
  final Map<String, Money> paidBy; // userId -> مبلغ پرداختی (پشتیبانی چند payer)
  final Map<String, Money> shares; // userId -> سهم نهایی
  final SplitMethod splitMethod;
  final String category;
  final String? note;
  final DateTime date;
  final String createdBy;

  const CreateExpenseInput({
    required this.groupId,
    required this.title,
    required this.amount,
    required this.paidBy,
    required this.shares,
    required this.splitMethod,
    required this.category,
    required this.date,
    required this.createdBy,
    this.note,
  });
}

/// نمایش یک هزینه در Timeline/History گروه (بخش 15 سند).
class ExpenseHistoryItem {
  final String id;
  final String title;
  final Money amount;
  final String category;
  final DateTime date;
  final String payerNamesSummary; // مثلا "رضا" یا "رضا و علی"
  final Money myShare;

  const ExpenseHistoryItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.payerNamesSummary,
    required this.myShare,
  });
}

const expenseCategories = [
  'غذا',
  'حمل‌ونقل',
  'اقامت',
  'خرید',
  'تفریح',
  'قبض',
  'اجاره',
  'دانشگاه',
  'سفر',
  'سایر',
];
