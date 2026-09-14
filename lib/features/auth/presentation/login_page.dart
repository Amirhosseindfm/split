import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../application/auth_providers.dart';

/// MVP: ورود با شماره موبایل + نام (OTP واقعی در معماری جای‌گذاری شده،
/// اما برای این مرحله شبیه‌سازی شده تا اپ کاملاً local/offline قابل اجرا باشد).
/// معماری آماده‌ی اضافه‌شدن Google/Apple Login است (بخش 7 سند).
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  String? _errorText;

  Future<void> _login() async {
    final phone = _phoneController.text.trim();
    final name = _nameController.text.trim();

    if (phone.length < 10) {
      setState(() => _errorText = 'شماره موبایل معتبر نیست.');
      return;
    }
    if (name.isEmpty) {
      setState(() => _errorText = 'نام را وارد کنید.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final userId = await authRepo.loginWithPhone(phone: phone, name: name);

      await ref.read(sessionStoreProvider).saveUserId(userId);
      ref.read(currentUserIdProvider.notifier).state = userId;

      if (!mounted) return;
      context.go('/home');
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorText = 'خطا در ورود. لطفاً دوباره تلاش کنید.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ورود')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('اطلاعات ورود', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'نام'),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              decoration: const InputDecoration(labelText: 'شماره موبایل', hintText: '09xxxxxxxxx'),
            ),
            if (_errorText != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(_errorText!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('ورود'),
            ),
          ],
        ),
      ),
    );
  }
}
