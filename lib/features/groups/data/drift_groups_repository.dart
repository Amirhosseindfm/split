import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../domain/group_models.dart';
import '../domain/groups_repository.dart';

const _uuid = Uuid();

class DriftGroupsRepository implements GroupsRepository {
  final AppDatabase _db;
  DriftGroupsRepository(this._db);

  @override
  Stream<List<GroupSummary>> watchGroups() {
    final query = _db.select(_db.groups)
      ..orderBy([(g) => OrderingTerm.desc(g.createdAt)]);
    return query.watch().asyncMap((rows) async {
      final summaries = <GroupSummary>[];
      for (final row in rows) {
        summaries.add(await _toSummary(row));
      }
      return summaries;
    });
  }

  @override
  Stream<GroupSummary?> watchGroup(String groupId) {
    final query = _db.select(_db.groups)..where((g) => g.id.equals(groupId));
    return query.watchSingleOrNull().asyncMap((row) async {
      if (row == null) return null;
      return _toSummary(row);
    });
  }

  Future<GroupSummary> _toSummary(Group row) async {
    final memberQuery = _db.select(_db.groupMembers).join([
      innerJoin(_db.users, _db.users.id.equalsExp(_db.groupMembers.userId)),
    ])
      ..where(_db.groupMembers.groupId.equals(row.id));

    final memberRows = await memberQuery.get();
    final members = memberRows.map((r) {
      final user = r.readTable(_db.users);
      return GroupMemberInfo(userId: user.id, name: user.name, phone: user.phone);
    }).toList();

    return GroupSummary(
      id: row.id,
      name: row.name,
      category: row.category,
      members: members,
    );
  }

  @override
  Future<String> createGroup({
    required String name,
    required String category,
    required String createdByUserId,
  }) async {
    final groupId = _uuid.v4();
    await _db.transaction(() async {
      await _db.into(_db.groups).insert(GroupsCompanion.insert(
            id: groupId,
            name: name,
            category: Value(category),
            createdBy: createdByUserId,
          ));
      await _db.into(_db.groupMembers).insert(GroupMembersCompanion.insert(
            groupId: groupId,
            userId: createdByUserId,
          ));
    });
    return groupId;
  }

  @override
  Future<void> addMember({
    required String groupId,
    required String name,
    required String phone,
  }) async {
    await _db.transaction(() async {
      final existing = await (_db.select(_db.users)
            ..where((u) => u.phone.equals(phone)))
          .getSingleOrNull();

      final userId = existing?.id ?? _uuid.v4();
      if (existing == null) {
        await _db.into(_db.users).insert(UsersCompanion.insert(
              id: userId,
              name: name,
              phone: phone,
            ));
      }

      await _db.into(_db.groupMembers).insertOnConflictUpdate(
            GroupMembersCompanion.insert(groupId: groupId, userId: userId),
          );
    });
  }

  @override
  Future<void> removeMember({required String groupId, required String userId}) async {
    await (_db.delete(_db.groupMembers)
          ..where((m) => m.groupId.equals(groupId) & m.userId.equals(userId)))
        .go();
  }
}
