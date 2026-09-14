import 'package:flutter/material.dart';
import '../../../core/domain_services/split_calculator.dart';
import '../../../core/theme/app_spacing.dart';

/// ثبت هزینه در حداکثر چند مرحله (بخش 33 سند):
/// مبلغ -> عنوان -> پرداخت‌کننده -> افراد -> روش تقسیم -> ثبت
/// پیش‌فرض: تقسیم مساوی + پرداخت‌کننده = کاربر فعلی.
///
/// TODO: اتصال کامل به ExpensesRepository برای ذخیره‌سازی نهایی.
class AddExpensePage extends StatefulWidget {
  final String groupId;
  const AddExpensePage({super.key, required this.groupId});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  SplitMethod _splitMethod = SplitMethod.equal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ثبت هزینه')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: ListView(
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'مبلغ (تومان)'),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'عنوان هزینه'),
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<SplitMethod>(
              initialValue: _splitMethod,
              decoration: const InputDecoration(labelText: 'روش تقسیم'),
              items: const [
                DropdownMenuItem(value: SplitMethod.equal, child: Text('مساوی')),
                DropdownMenuItem(value: SplitMethod.exact, child: Text('مبلغ دقیق')),
                DropdownMenuItem(value: SplitMethod.percentage, child: Text('درصدی')),
                DropdownMenuItem(value: SplitMethod.shares, child: Text('سهمی')),
              ],
              onChanged: (v) => setState(() => _splitMethod = v ?? SplitMethod.equal),
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: () {
                // TODO: Validation + فراخوانی SplitCalculator + ذخیره در Repository
              },
              child: const Text('ثبت هزینه'),
            ),
          ],
        ),
      ),
    );
  }
}
