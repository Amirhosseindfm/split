import 'package:flutter/material.dart';
import '../../shared/widgets/state_views.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('فعالیت‌ها')),
      body: const EmptyView(
        title: 'فعالیتی وجود ندارد',
        subtitle: 'به محض ثبت هزینه یا تسویه، اینجا نمایش داده می‌شود.',
        icon: Icons.receipt_long_outlined,
      ),
    );
  }
}
