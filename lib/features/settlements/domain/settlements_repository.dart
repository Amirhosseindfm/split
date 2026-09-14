import '../../../core/domain_services/models.dart';

abstract class SettlementsRepository {
  Future<List<SettlementInput>> getAllAsEngineInput({String? groupId});
}
