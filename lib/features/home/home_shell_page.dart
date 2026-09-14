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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: هدایت به انتخاب گروه سپس Add Expense (بخش 33 - Add Expense UX)
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
