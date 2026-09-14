import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/persian_date_formatter.dart';
import '../../../shared/widgets/state_views.dart';
import '../../auth/application/auth_providers.dart';
import '../../balances/application/group_balance_provider.dart';
import '../../expenses/application/expenses_repository_provider.dart';
import '../../settlements/application/settlements_repository_provider.dart';
import '../application/groups_providers.dart';
import '../domain/group_models.dart';

class GroupDetailPage extends ConsumerWidget {
  final String groupId;
  const GroupDetailPage({super.key, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(groupDetailProvider(groupId));

    return Scaffold(
      appBar: AppBar(
        title: groupAsync.maybeWhen(
          data: (g) => Text(g?.name ?? 'گروه'),
          orElse: () => const Text('گروه'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_outlined),
            tooltip: 'افزودن عضو',
            onPressed: () => context.push('/group/$groupId/add-member'),
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart_outlined),
            tooltip: 'آمار',
            onPressed: () => context.push('/group/$groupId/statistics'),
          ),
        ],
      ),
      body: groupAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorRetryView(
          message: 'خطا در دریافت اطلاعات گروه.',
          onRetry: () => ref.invalidate(groupDetailProvider(groupId)),
        ),
        data: (group) {
          if (group == null) {
            return const EmptyView(title: 'گروه یافت نشد', subtitle: '', icon: Icons.error_outline);
          }
          return _GroupDashboard(group: group);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/group/$groupId/expense/add'),
        icon: const Icon(Icons.add),
        label: const Text('هزینه'),
      ),
    );
  }
}

class _GroupDashboard extends ConsumerWidget {
  final GroupSummary group;
  const _GroupDashboard({required this.group});

  String _nameFor(String userId) {
    final match = group.members.where((m) => m.userId == userId);
    return match.isEmpty ? userId : match.first.name;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(groupBalanceProvider(group.id));
    final historyAsync = ref.watch(expensesRepositoryProvider).watchHistory(
          group.id,
          currentUserId: ref.watch(requireCurrentUserIdProvider),
        );
    final currentUserId = ref.watch(requireCurrentUserIdProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(groupBalanceProvider(group.id)),
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('وضعیت مالی گروه', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  balanceAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: LoadingView(),
                    ),
                    error: (e, _) => const Text('خطا در محاسبه بدهی‌ها'),
                    data: (result) {
                      final myBalanceMatches =
                          result.balances.where((b) => b.userId == currentUserId);
                      final myBalance =
                          myBalanceMatches.isEmpty ? null : myBalanceMatches.first.netBalance;
                      final myBalanceText = myBalance == null || myBalance.isZero
                          ? 'تسویه'
                          : myBalance.formatToman();
                      final myColor = myBalance == null
                          ? AppColors.lightTextSecondary
                          : myBalance.isNegative
                              ? AppColors.danger
                              : AppColors.success;

                      if (result.simplifiedDebts.isEmpty) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('وضعیت من'),
                            Text(myBalanceText, style: TextStyle(color: myColor, fontWeight: FontWeight.bold)),
                          ],
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('وضعیت من'),
                              Text(myBalanceText, style: TextStyle(color: myColor, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const Divider(height: AppSpacing.lg),
                          Text('چه کسی به چه کسی بدهکار است',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: AppSpacing.sm),
                          ...result.simplifiedDebts.map((debt) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${_nameFor(debt.fromUserId)} ← ${_nameFor(debt.toUserId)}',
                                      ),
                                    ),
                                    Text(debt.amount.formatToman(),
                                        style: const TextStyle(fontWeight: FontWeight.w600)),
                                    const SizedBox(width: AppSpacing.sm),
                                    TextButton(
                                      onPressed: () async {
                                        await ref.read(settlementsRepositoryProvider).createSettlement(
                                              groupId: group.id,
                                              fromUserId: debt.fromUserId,
                                              toUserId: debt.toUserId,
                                              amount: debt.amount,
                                            );
                                        ref.invalidate(groupBalanceProvider(group.id));
                                      },
                                      child: const Text('تسویه شد'),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('تاریخچه هزینه‌ها', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          StreamBuilder(
            stream: historyAsync,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: LoadingView(),
                );
              }
              final items = snapshot.data!;
              if (items.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                  child: EmptyView(
                    title: 'هنوز هزینه‌ای ثبت نشده',
                    subtitle: 'با دکمه‌ی «+ هزینه» اولین هزینه‌ی گروه رو ثبت کن.',
                    icon: Icons.receipt_long_outlined,
                  ),
                );
              }
              return Column(
                children: items.map((item) {
                  return Card(
                    child: ListTile(
                      title: Text(item.title),
                      subtitle: Text(
                        '${item.payerNamesSummary} پرداخت کرد · ${PersianDateFormatter.relativeLabel(item.date)}',
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(item.amount.formatToman(),
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('سهم تو: ${item.myShare.formatToman()}',
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
