import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../auth/application/auth_providers.dart';

/// مدیریت نام، عکس، شماره موبایل، تنظیمات (بخش 47 سند).
/// عکس پروفایل، زبان، واحد پول و نوتیفیکیشن‌ها در نسخه‌های بعدی تکمیل می‌شوند.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(requireCurrentUserIdProvider);
    final userFuture = ref.watch(authRepositoryProvider).getUser(userId);

    return Scaffold(
      appBar: AppBar(title: const Text('پروفایل')),
      body: FutureBuilder(
        future: userFuture,
        builder: (context, snapshot) {
          final user = snapshot.data;
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                title: Text(user?.name ?? '...'),
                subtitle: Text(user?.phone ?? ''),
              ),
              const Divider(),
              const ListTile(leading: Icon(Icons.language_outlined), title: Text('زبان: فارسی')),
              const ListTile(leading: Icon(Icons.payments_outlined), title: Text('واحد پول: تومان')),
              const ListTile(
                  leading: Icon(Icons.notifications_outlined), title: Text('اعلان‌ها')),
              const ListTile(
                  leading: Icon(Icons.dark_mode_outlined), title: Text('حالت تیره/روشن: سیستم')),
              const SizedBox(height: AppSpacing.lg),
              OutlinedButton.icon(
                onPressed: () async {
                  await ref.read(sessionStoreProvider).clear();
                  ref.read(currentUserIdProvider.notifier).state = null;
                  if (context.mounted) context.go('/onboarding');
                },
                icon: const Icon(Icons.logout),
                label: const Text('خروج از حساب'),
              ),
            ],
          );
        },
      ),
    );
  }
}
