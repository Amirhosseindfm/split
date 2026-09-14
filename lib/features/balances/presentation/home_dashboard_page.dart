import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/money/money.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/state_views.dart';
import '../application/overall_balance_provider.dart';

class HomeDashboardPage extends ConsumerWidget {
  const HomeDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(overallBalanceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('خانه')),
      body: balanceAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorRetryView(
          message: 'خطا در دریافت وضعیت مالی.',
          onRetry: () => ref.invalidate(overallBalanceProvider),
        ),
        data: (summary) {
          if (summary.owedToMe.isZero && summary.owedByMe.isZero) {
            return const EmptyView(
              title: 'هنوز هیچ تراکنشی نداری',
              subtitle: 'با ساخت اولین گروه، هزینه‌هات رو با دوستات راحت تقسیم کن.',
              icon: Icons.account_balance_wallet_outlined,
            );
          }
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _row('طلبکار', summary.owedToMe, AppColors.success),
                    const SizedBox(height: AppSpacing.sm),
                    _row('بدهکار', summary.owedByMe, AppColors.danger),
                    const Divider(height: AppSpacing.xl),
                    _row(
                      'خالص',
                      summary.net,
                      summary.net.isNegative ? AppColors.danger : AppColors.success,
                      bold: true,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _row(String label, Money amount, Color color, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: bold ? FontWeight.bold : null)),
        Text(
          amount.formatToman(),
          style: TextStyle(
            color: color,
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
