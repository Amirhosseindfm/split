import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/in_memory_settlements_repository.dart';
import '../domain/settlements_repository.dart';

final settlementsRepositoryProvider = Provider<SettlementsRepository>((ref) {
  return InMemorySettlementsRepository();
});
