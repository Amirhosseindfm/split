import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';

/// مدیریت نام، عکس، شماره موبایل، تنظیمات، زبان، واحد پول، نوتیفیکیشن (بخش 47).
/// TODO: اتصال به ProfileRepository واقعی.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('پروفایل')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: const [
          ListTile(leading: Icon(Icons.person_outline), title: Text('نام و عکس پروفایل')),
          ListTile(leading: Icon(Icons.phone_outlined), title: Text('شماره موبایل')),
          ListTile(leading: Icon(Icons.language_outlined), title: Text('زبان')),
          ListTile(leading: Icon(Icons.payments_outlined), title: Text('واحد پول')),
          ListTile(leading: Icon(Icons.notifications_outlined), title: Text('اعلان‌ها')),
          ListTile(leading: Icon(Icons.dark_mode_outlined), title: Text('حالت تیره/روشن')),
        ],
      ),
    );
  }
}
