import 'group_models.dart';

abstract class GroupsRepository {
  Stream<List<GroupSummary>> watchGroups();

  Stream<GroupSummary?> watchGroup(String groupId);

  Future<String> createGroup({
    required String name,
    required String category,
    required String createdByUserId,
  });

  /// اگر کاربری با این شماره موبایل وجود نداشته باشد، ساخته می‌شود.
  Future<void> addMember({
    required String groupId,
    required String name,
    required String phone,
  });

  Future<void> removeMember({required String groupId, required String userId});
}
