import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Dashboard گروه: Total Expenses, My Balance, Who Owes Whom (بخش 19 سند).
/// TODO: اتصال به GroupRepository + BalanceEngine + DebtSimplifier برای داده واقعی.
class GroupDetailPage extends StatelessWidget {
  final String groupId;
  const GroupDetailPage({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('گروه $groupId')),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () => context.go('/group/$groupId/expense/add'),
          icon: const Icon(Icons.add),
          label: const Text('ثبت هزینه جدید'),
        ),
      ),
    );
  }
}
