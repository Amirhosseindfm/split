import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database_provider.dart';
import '../data/drift_groups_repository.dart';
import '../domain/groups_repository.dart';
import '../domain/group_models.dart';

final groupsRepositoryProvider = Provider<GroupsRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return DriftGroupsRepository(db);
});

final groupsListProvider = StreamProvider<List<GroupSummary>>((ref) {
  return ref.watch(groupsRepositoryProvider).watchGroups();
});

final groupDetailProvider =
    StreamProvider.family<GroupSummary?, String>((ref, groupId) {
  return ref.watch(groupsRepositoryProvider).watchGroup(groupId);
});
