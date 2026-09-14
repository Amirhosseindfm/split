import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/money/money.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/state_views.dart';
import '../../expenses/application/expenses_repository_provider.dart';
import '../../expenses/domain/expense_models.dart';

/// آمار پایه‌ی گروه (بخش 20 سند): مجموع هزینه‌ها و هزینه بر اساس دسته‌بندی.
class StatisticsPage extends ConsumerWidget {
  final String groupId;
  const StatisticsPage({super.key, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyStream = ref.watch(expensesRepositoryProvider).watchHistory(groupId);

    return Scaffold(
      appBar: AppBar(title: const Text('آمار گروه')),
      body: StreamBuilder<List<ExpenseHistoryItem>>(
        stream: historyStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const LoadingView();
          final items = snapshot.data!;
          if (items.isEmpty) {
            return const EmptyView(
              title: 'هنوز آماری وجود ندارد',
              subtitle: 'بعد از ثبت چند هزینه، آمار گروه اینجا نمایش داده می‌شود.',
              icon: Icons.bar_chart_outlined,
            );
          }

          final total = items.fold<Money>(Money.zero(), (sum, item) => sum + item.amount);

          final Map<String, Money> byCategory = {};
          for (final item in items) {
            byCategory[item.category] = (byCategory[item.category] ?? Money.zero()) + item.amount;
          }
          final sortedCategories = byCategory.entries.toList()
            ..sort((a, b) => b.value.amountInRial.compareTo(a.value.amountInRial));

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('مجموع هزینه‌های گروه'),
                      Text(total.formatToman(),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('هزینه بر اساس دسته‌بندی', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              ...sortedCategories.map((entry) {
                final percent = total.isZero
                    ? 0.0
                    : entry.value.amountInRial / total.amountInRial;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(entry.key),
                          Text(entry.value.formatToman()),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(value: percent, minHeight: 6),
                      ),
                    ],
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
