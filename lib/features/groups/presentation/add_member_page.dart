import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_spacing.dart';
import '../application/groups_providers.dart';

/// روش اول (شماره موبایل) طبق بخش 10 سند. لینک دعوت/QR در آینده اضافه می‌شود.
class AddMemberPage extends ConsumerStatefulWidget {
  final String groupId;
  const AddMemberPage({super.key, required this.groupId});

  @override
  ConsumerState<AddMemberPage> createState() => _AddMemberPageState();
}

class _AddMemberPageState extends ConsumerState<AddMemberPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isSaving = false;

  Future<void> _add() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    if (name.isEmpty || phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('نام و شماره موبایل معتبر وارد کنید.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref.read(groupsRepositoryProvider).addMember(
            groupId: widget.groupId,
            name: name,
            phone: phone,
          );
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('خطا در افزودن عضو.')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('افزودن عضو')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'نام عضو'),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              decoration: const InputDecoration(labelText: 'شماره موبایل', hintText: '09xxxxxxxxx'),
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: _isSaving ? null : _add,
              child: _isSaving
                  ? const SizedBox(
                      width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('افزودن به گروه'),
            ),
          ],
        ),
      ),
    );
  }
}
