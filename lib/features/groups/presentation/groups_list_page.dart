import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/state_views.dart';
import '../application/groups_providers.dart';

class GroupsListPage extends ConsumerWidget {
  const GroupsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(groupsListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('گروه‌ها')),
      body: groupsAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorRetryView(
          message: 'خطا در دریافت گروه‌ها.',
          onRetry: () => ref.invalidate(groupsListProvider),
        ),
        data: (groups) {
          if (groups.isEmpty) {
            return const EmptyView(
              title: 'هنوز گروهی نداری',
              subtitle: 'اولین گروهت رو بساز و هزینه‌ها رو با دوستات راحت تقسیم کن.',
              icon: Icons.groups_outlined,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: groups.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final group = groups[index];
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(AppSpacing.md),
                  title: Text(group.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${group.category} · ${group.members.length} عضو'),
                  trailing: const Icon(Icons.chevron_left),
                  onTap: () => context.go('/group/${group.id}'),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/group/create'),
        icon: const Icon(Icons.add),
        label: const Text('گروه جدید'),
      ),
    );
  }
}
