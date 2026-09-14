/// تبدیل اعداد لاتین به فارسی و برعکس برای نمایش صحیح در UI (بخش 34 سند).
class PersianNumbers {
  PersianNumbers._();

  static const _persianDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

  /// "1250000" -> "۱۲۵۰۰۰۰"
  static String toPersianDigits(String input) {
    final buffer = StringBuffer();
    for (final char in input.split('')) {
      final digit = int.tryParse(char);
      buffer.write(digit != null ? _persianDigits[digit] : char);
    }
    return buffer.toString();
  }

  /// "۱۲۵۰۰۰۰" -> "1250000" (برای parse کردن ورودی کاربر)
  static String toEnglishDigits(String input) {
    final buffer = StringBuffer();
    for (final char in input.split('')) {
      final index = _persianDigits.indexOf(char);
      buffer.write(index != -1 ? index.toString() : char);
    }
    return buffer.toString();
  }

  /// جداکننده هزارگان + تبدیل به ارقام فارسی: 1250000 -> "۱,۲۵۰,۰۰۰"
  static String formatWithSeparators(int value) {
    final isNegative = value < 0;
    final raw = value.abs().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < raw.length; i++) {
      if (i > 0 && (raw.length - i) % 3 == 0) buffer.write(',');
      buffer.write(raw[i]);
    }
    final withSeparators = '${isNegative ? '-' : ''}${buffer.toString()}';
    return toPersianDigits(withSeparators);
  }

  /// پارس کردن ورودی کاربر (فارسی یا لاتین، با یا بدون جداکننده) به int.
  static int? parseUserInput(String input) {
    final cleaned = toEnglishDigits(input).replaceAll(',', '').trim();
    if (cleaned.isEmpty) return null;
    return int.tryParse(cleaned);
  }
}
