import 'package:flutter_riverpod/flutter_riverpod.dart';

/// TODO: جایگزینی با session واقعی بعد از پیاده‌سازی Authentication.
final currentUserIdProvider = Provider<String>((ref) {
  return 'me';
});
