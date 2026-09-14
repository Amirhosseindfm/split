import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/onboarding/presentation/onboarding_page.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/home/home_shell_page.dart';
import '../../features/groups/presentation/group_detail_page.dart';
import '../../features/expenses/presentation/add_expense_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeShellPage(),
      ),
      GoRoute(
        path: '/group/:groupId',
        builder: (context, state) => GroupDetailPage(
          groupId: state.pathParameters['groupId']!,
        ),
        routes: [
          GoRoute(
            path: 'expense/add',
            builder: (context, state) => AddExpensePage(
              groupId: state.pathParameters['groupId']!,
            ),
          ),
        ],
      ),
      // /invite/:code برای Deep Linking دعوت به گروه (پیاده‌سازی آینده)
      GoRoute(
        path: '/invite/:code',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('دعوت به گروه')),
          body: Center(
            child: Text('کد دعوت: ${state.pathParameters['code']}'),
          ),
        ),
      ),
    ],
  );
});
