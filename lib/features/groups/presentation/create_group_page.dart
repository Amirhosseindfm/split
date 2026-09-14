import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/application/auth_providers.dart';
import '../application/groups_providers.dart';
import '../domain/group_models.dart';

class CreateGroupPage extends ConsumerStatefulWidget {
  const CreateGroupPage({super.key});

  @override
  ConsumerState<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends ConsumerState<CreateGroupPage> {
  final _nameController = TextEditingController();
  String _category = groupCategories.first;
  bool _isSaving = false;

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('نام گروه را وارد کنید.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final userId = ref.read(requireCurrentUserIdProvider);
      final groupId = await ref.read(groupsRepositoryProvider).createGroup(
            name: name,
            category: _category,
            createdByUserId: userId,
          );
      if (!mounted) return;
      context.go('/group/$groupId');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('خطا در ساخت گروه. لطفاً دوباره تلاش کنید.')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('گروه جدید')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'نام گروه', hintText: 'مثلاً سفر شمال'),
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: 'نوع گروه'),
              items: groupCategories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v ?? groupCategories.first),
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('ساخت گروه'),
            ),
          ],
        ),
      ),
    );
  }
}
