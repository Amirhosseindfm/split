import 'package:equatable/equatable.dart';

/// همه محاسبات مالی با int انجام می‌شود (کوچک‌ترین واحد پول: ریال).
/// هرگز از double برای پول استفاده نکنید.
class Money extends Equatable implements Comparable<Money> {
  /// مقدار به کوچک‌ترین واحد (ریال). برای نمایش به تومان، در 10 تقسیم می‌شود.
  final int amountInRial;

  const Money(this.amountInRial);

  factory Money.zero() => const Money(0);

  factory Money.fromToman(int toman) => Money(toman * 10);

  int get toman => amountInRial ~/ 10;

  Money operator +(Money other) => Money(amountInRial + other.amountInRial);

  Money operator -(Money other) => Money(amountInRial - other.amountInRial);

  Money operator -() => Money(-amountInRial);

  bool get isNegative => amountInRial < 0;

  bool get isPositive => amountInRial > 0;

  bool get isZero => amountInRial == 0;

  Money abs() => Money(amountInRial.abs());

  /// تقسیم مساوی بین n نفر با rounding استراتژی deterministic:
  /// باقی‌مانده (کوچک‌تر از n واحد) یکی‌یکی به نفرات اول لیست اضافه می‌شود.
  static List<Money> splitEqually(Money total, int participantCount) {
    if (participantCount <= 0) {
      throw ArgumentError('participantCount باید بزرگ‌تر از صفر باشد');
    }
    final base = total.amountInRial ~/ participantCount;
    final remainder = total.amountInRial % participantCount;
    return List.generate(participantCount, (index) {
      final extra = index < remainder ? 1 : 0;
      return Money(base + extra);
    });
  }

  /// فرمت نمایش تومانی با جداکننده هزارگان، مثلا: 1,250,000 تومان
  String formatToman() {
    final value = toman.abs();
    final str = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
      buffer.write(str[i]);
    }
    final sign = toman < 0 ? '-' : '';
    return '$sign${buffer.toString()} تومان';
  }

  @override
  int compareTo(Money other) => amountInRial.compareTo(other.amountInRial);

  @override
  List<Object?> get props => [amountInRial];

  @override
  String toString() => formatToman();
}
