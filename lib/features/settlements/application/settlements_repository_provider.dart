import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database_provider.dart';
import '../data/drift_settlements_repository.dart';
import '../domain/settlements_repository.dart';

final settlementsRepositoryProvider = Provider<SettlementsRepository>((ref) {
  return DriftSettlementsRepository(ref.watch(appDatabaseProvider));
});
