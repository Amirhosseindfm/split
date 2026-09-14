import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/domain_services/models.dart';
import '../../../core/money/money.dart';
import '../domain/settlements_repository.dart';

const _uuid = Uuid();

class DriftSettlementsRepository implements SettlementsRepository {
  final AppDatabase _db;
  DriftSettlementsRepository(this._db);

  @override
  Future<List<SettlementInput>> getAllAsEngineInput({String? groupId}) async {
    final query = _db.select(_db.settlements);
    if (groupId != null) {
      query.where((s) => s.groupId.equals(groupId));
    }
    final rows = await query.get();
    return rows
        .map((r) => SettlementInput(
              id: r.id,
              fromUserId: r.fromUserId,
              toUserId: r.toUserId,
              amount: Money(r.amountRial),
            ))
        .toList();
  }

  @override
  Future<String> createSettlement({
    required String groupId,
    required String fromUserId,
    required String toUserId,
    required Money amount,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.settlements).insertOnConflictUpdate(
          SettlementsCompanion.insert(
            id: id,
            groupId: groupId,
            fromUserId: fromUserId,
            toUserId: toUserId,
            amountRial: amount.amountInRial,
          ),
        );
    return id;
  }
}
