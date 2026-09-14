import 'package:flutter/material.dart';
import '../../../shared/widgets/state_views.dart';
import '../../../core/theme/app_spacing.dart';

/// TODO: اتصال به GroupsRepository واقعی. فعلاً حالت خالی طبق بخش 38 سند نمایش داده می‌شود.
class GroupsListPage extends StatelessWidget {
  const GroupsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('گروه‌ها')),
      body: const EmptyView(
        title: 'هنوز گروهی نداری',
        subtitle: 'اولین گروهت رو بساز و هزینه‌ها رو با دوستات راحت تقسیم کن.',
        icon: Icons.groups_outlined,
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: FloatingActionButton.extended(
          onPressed: () {
            // TODO: باز کردن فرم CreateGroup (بخش 9 سند)
          },
          icon: const Icon(Icons.add),
          label: const Text('گروه جدید'),
        ),
      ),
    );
  }
}
