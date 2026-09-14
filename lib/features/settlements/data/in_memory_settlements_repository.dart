import '../../../core/domain_services/models.dart';
import '../domain/settlements_repository.dart';

/// TODO: جایگزینی با DriftSettlementsRepository.
class InMemorySettlementsRepository implements SettlementsRepository {
  final List<SettlementInput> _settlements = [];

  void addForTesting(SettlementInput settlement) => _settlements.add(settlement);

  @override
  Future<List<SettlementInput>> getAllAsEngineInput({String? groupId}) async {
    return List.unmodifiable(_settlements);
  }
}
