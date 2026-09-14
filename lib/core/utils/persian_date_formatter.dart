import 'package:shamsi_date/shamsi_date.dart';
import 'persian_numbers.dart';

/// DateTime داخلی همیشه استاندارد (میلادی/UTC) نگه داشته می‌شود.
/// این کلاس فقط لایه‌ی presentation را برای نمایش شمسی می‌پوشاند (بخش 34-35 سند).
class PersianDateFormatter {
  PersianDateFormatter._();

  static const _weekdayNames = [
    'دوشنبه',
    'سه‌شنبه',
    'چهارشنبه',
    'پنجشنبه',
    'جمعه',
    'شنبه',
    'یکشنبه',
  ];

  static const _monthNames = [
    'فروردین',
    'اردیبهشت',
    'خرداد',
    'تیر',
    'مرداد',
    'شهریور',
    'مهر',
    'آبان',
    'آذر',
    'دی',
    'بهمن',
    'اسفند',
  ];

  /// "۱۴ شهریور ۱۴۰۴"
  static String formatFull(DateTime dateTime) {
    final jalali = Jalali.fromDateTime(dateTime);
    final day = PersianNumbers.toPersianDigits(jalali.day.toString());
    final month = _monthNames[jalali.month - 1];
    final year = PersianNumbers.toPersianDigits(jalali.year.toString());
    return '$day $month $year';
  }

  /// برچسب نسبی برای Timeline هزینه‌ها: «امروز»، «دیروز»، یا تاریخ کامل شمسی.
  static String relativeLabel(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final diff = today.difference(target).inDays;

    if (diff == 0) return 'امروز';
    if (diff == 1) return 'دیروز';
    return formatFull(dateTime);
  }

  static String weekdayName(DateTime dateTime) {
    final jalali = Jalali.fromDateTime(dateTime);
    return _weekdayNames[jalali.weekDay - 1];
  }
}
