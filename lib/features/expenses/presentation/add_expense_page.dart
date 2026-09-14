import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain_services/split_calculator.dart';
import '../../../core/money/money.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/persian_numbers.dart';
import '../../auth/application/auth_providers.dart';
import '../../groups/application/groups_providers.dart';
import '../../groups/domain/group_models.dart';
import '../application/expenses_repository_provider.dart';
import '../domain/expense_models.dart';

/// ثبت هزینه در چند مرحله (بخش 33 سند):
/// مبلغ -> عنوان -> پرداخت‌کننده -> افراد -> روش تقسیم -> ثبت
/// پیش‌فرض: تقسیم مساوی + پرداخت‌کننده = کاربر فعلی.
class AddExpensePage extends ConsumerStatefulWidget {
  final String groupId;
  const AddExpensePage({super.key, required this.groupId});

  @override
  ConsumerState<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends ConsumerState<AddExpensePage> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _calculator = const SplitCalculator();

  SplitMethod _splitMethod = SplitMethod.equal;
  String _category = expenseCategories.first;
  String? _payerId;
  final Set<String> _participantIds = {};
  final Map<String, TextEditingController> _exactControllers = {};
  final Map<String, TextEditingController> _percentControllers = {};
  final Map<String, TextEditingController> _shareControllers = {};

  bool _isSaving = false;
  String? _errorText;
  bool _initialized = false;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    for (final c in [..._exactControllers.values, ..._percentControllers.values, ..._shareControllers.values]) {
      c.dispose();
    }
    super.dispose();
  }

  void _ensureInitialized(GroupSummary group, String currentUserId) {
    if (_initialized) return;
    _initialized = true;
    _payerId = currentUserId;
    _participantIds.addAll(group.members.map((m) => m.userId));
    for (final m in group.members) {
      _exactControllers[m.userId] = TextEditingController();
      _percentControllers[m.userId] = TextEditingController();
      _shareControllers[m.userId] = TextEditingController(text: '1');
    }
  }

  Money? get _amount {
    final parsed = PersianNumbers.parseUserInput(_amountController.text);
    return parsed == null ? null : Money.fromToman(parsed);
  }

  Future<void> _save(GroupSummary group) async {
    setState(() => _errorText = null);

    final title = _titleController.text.trim();
    final amount = _amount;
    final payerId = _payerId;
    final currentUserId = ref.read(requireCurrentUserIdProvider);

    if (title.isEmpty) {
      setState(() => _errorText = 'عنوان هزینه را وارد کنید.');
      return;
    }
    if (amount == null) {
      setState(() => _errorText = 'مبلغ معتبر نیست.');
      return;
    }
    if (payerId == null) {
      setState(() => _errorText = 'پرداخت‌کننده را انتخاب کنید.');
      return;
    }
    if (_participantIds.isEmpty) {
      setState(() => _errorText = 'حداقل یک نفر باید در هزینه شریک باشد.');
      return;
    }

    try {
      _calculator.validateAmount(amount);

      final participants = _participantIds.toList();
      Map<String, Money> shares;

      switch (_splitMethod) {
        case SplitMethod.equal:
          shares = _calculator.equal(amount, participants);
          break;
        case SplitMethod.exact:
          shares = _calculator.exact(amount, {
            for (final id in participants)
              id: Money.fromToman(
                  PersianNumbers.parseUserInput(_exactControllers[id]!.text) ?? 0),
          });
          break;
        case SplitMethod.percentage:
          shares = _calculator.percentage(amount, {
            for (final id in participants)
              id: double.tryParse(
                      PersianNumbers.toEnglishDigits(_percentControllers[id]!.text)) ??
                  0,
          });
          break;
        case SplitMethod.shares:
          shares = _calculator.shares(amount, {
            for (final id in participants)
              id: int.tryParse(
                      PersianNumbers.toEnglishDigits(_shareControllers[id]!.text)) ??
                  0,
          });
          break;
      }

      setState(() => _isSaving = true);

      await ref.read(expensesRepositoryProvider).createExpense(
            CreateExpenseInput(
              groupId: widget.groupId,
              title: title,
              amount: amount,
              paidBy: {payerId: amount},
              shares: shares,
              splitMethod: _splitMethod,
              category: _category,
              date: DateTime.now(),
              createdBy: currentUserId,
            ),
          );

      if (!mounted) return;
      Navigator.of(context).pop();
    } on SplitValidationException catch (e) {
      setState(() => _errorText = e.messageFa);
    } catch (_) {
      setState(() => _errorText = 'خطا در ثبت هزینه. لطفاً دوباره تلاش کنید.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupAsync = ref.watch(groupDetailProvider(widget.groupId));
    final currentUserId = ref.watch(requireCurrentUserIdProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('ثبت هزینه')),
      body: groupAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('خطا در بارگذاری اطلاعات گروه')),
        data: (group) {
          if (group == null) return const Center(child: Text('گروه یافت نشد'));
          _ensureInitialized(group, currentUserId);

          return Padding(
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
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: const InputDecoration(labelText: 'دسته‌بندی'),
                  items: expenseCategories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _category = v ?? expenseCategories.first),
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<String>(
                  value: _payerId,
                  decoration: const InputDecoration(labelText: 'پرداخت‌کننده'),
                  items: group.members
                      .map((m) => DropdownMenuItem(value: m.userId, child: Text(m.name)))
                      .toList(),
                  onChanged: (v) => setState(() => _payerId = v),
                ),
                const SizedBox(height: AppSpacing.md),
                Text('افراد شریک در هزینه', style: Theme.of(context).textTheme.bodyMedium),
                ...group.members.map((m) => CheckboxListTile(
                      value: _participantIds.contains(m.userId),
                      title: Text(m.name),
                      onChanged: (checked) => setState(() {
                        if (checked ?? false) {
                          _participantIds.add(m.userId);
                        } else {
                          _participantIds.remove(m.userId);
                        }
                      }),
                    )),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<SplitMethod>(
                  value: _splitMethod,
                  decoration: const InputDecoration(labelText: 'روش تقسیم'),
                  items: const [
                    DropdownMenuItem(value: SplitMethod.equal, child: Text('مساوی')),
                    DropdownMenuItem(value: SplitMethod.exact, child: Text('مبلغ دقیق')),
                    DropdownMenuItem(value: SplitMethod.percentage, child: Text('درصدی')),
                    DropdownMenuItem(value: SplitMethod.shares, child: Text('سهمی')),
                  ],
                  onChanged: (v) => setState(() => _splitMethod = v ?? SplitMethod.equal),
                ),
                const SizedBox(height: AppSpacing.md),
                ..._buildSplitInputs(group),
                if (_errorText != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(_errorText!, style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                  onPressed: _isSaving ? null : () => _save(group),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('ثبت هزینه'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildSplitInputs(GroupSummary group) {
    if (_splitMethod == SplitMethod.equal) return const [];

    final participants = group.members.where((m) => _participantIds.contains(m.userId));
    final controllers = switch (_splitMethod) {
      SplitMethod.exact => _exactControllers,
      SplitMethod.percentage => _percentControllers,
      SplitMethod.shares => _shareControllers,
      SplitMethod.equal => <String, TextEditingController>{},
    };
    final label = switch (_splitMethod) {
      SplitMethod.exact => 'مبلغ (تومان)',
      SplitMethod.percentage => 'درصد',
      SplitMethod.shares => 'تعداد سهم',
      SplitMethod.equal => '',
    };

    return [
      for (final m in participants)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: TextField(
            controller: controllers[m.userId],
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: '${m.name} - $label'),
          ),
        ),
    ];
  }
}
