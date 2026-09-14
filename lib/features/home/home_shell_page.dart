import 'package:flutter/material.dart';
import '../groups/presentation/groups_list_page.dart';
import '../balances/presentation/home_dashboard_page.dart';
import '../profile/presentation/profile_page.dart';
import 'activity_page.dart';

/// پوسته اصلی اپ با Bottom Navigation: خانه | گروه‌ها | فعالیت‌ها | پروفایل
class HomeShellPage extends StatefulWidget {
  const HomeShellPage({super.key});

  @override
  State<HomeShellPage> createState() => _HomeShellPageState();
}

class _HomeShellPageState extends State<HomeShellPage> {
  int _index = 0;

  static const _pages = [
    HomeDashboardPage(),
    GroupsListPage(),
    ActivityPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      floatingActionButton: _index == 1
          ? null // در تب گروه‌ها، دکمه‌ی «گروه جدید» خودِ صفحه نمایش داده می‌شود
          : FloatingActionButton.extended(
              onPressed: () {
                setState(() => _index = 1);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('یک گروه را انتخاب کن تا هزینه ثبت کنی.')),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('هزینه'),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'خانه'),
          NavigationDestination(icon: Icon(Icons.groups_outlined), label: 'گروه‌ها'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: 'فعالیت‌ها'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'پروفایل'),
        ],
      ),
    );
  }
}
