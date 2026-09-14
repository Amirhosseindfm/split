import '../../../core/domain_services/models.dart';
import '../../../core/money/money.dart';

abstract class SettlementsRepository {
  Future<List<SettlementInput>> getAllAsEngineInput({String? groupId});

  /// ثبت یک تسویه‌حساب جدید. Settlement نباید هیچ Expense‌ای را حذف کند.
  Future<String> createSettlement({
    required String groupId,
    required String fromUserId,
    required String toUserId,
    required Money amount,
  });
}
