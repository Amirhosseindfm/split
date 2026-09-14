import 'package:flutter_test/flutter_test.dart';
import 'package:hamhesab/core/domain_services/split_calculator.dart';
import 'package:hamhesab/core/money/money.dart';

void main() {
  final calc = const SplitCalculator();

  group('Equal Split', () {
    test('تقسیم مساوی بدون باقی‌مانده', () {
      final result = calc.equal(Money.fromToman(900000), ['a', 'b', 'c']);
      expect(result['a'], Money.fromToman(300000));
      expect(result['b'], Money.fromToman(300000));
      expect(result['c'], Money.fromToman(300000));
    });

    test('تقسیم مساوی با باقی‌مانده rounding - deterministic', () {
      // 100 تومان بین 3 نفر: 33.33 -> باید جمع دقیقا 100 بماند
      final result = calc.equal(Money.fromToman(100), ['a', 'b', 'c']);
      final sum = result.values.fold<Money>(Money.zero(), (s, m) => s + m);
      expect(sum, Money.fromToman(100));
    });

    test('لیست خالی -> خطا', () {
      expect(() => calc.equal(Money.fromToman(100), []),
          throwsA(isA<SplitValidationException>()));
    });
  });

  group('Exact Split', () {
    test('جمع برابر total -> موفق', () {
      final result = calc.exact(Money.fromToman(1000), {
        'a': Money.fromToman(600),
        'b': Money.fromToman(400),
      });
      expect(result['a'], Money.fromToman(600));
    });

    test('جمع نابرابر total -> خطا', () {
      expect(
        () => calc.exact(Money.fromToman(1000), {
          'a': Money.fromToman(600),
          'b': Money.fromToman(300),
        }),
        throwsA(isA<SplitValidationException>()),
      );
    });
  });

  group('Percentage Split', () {
    test('جمع 100% -> موفق و جمع مبالغ برابر total', () {
      final result = calc.percentage(Money.fromToman(1000), {
        'a': 50,
        'b': 30,
        'c': 20,
      });
      final sum = result.values.fold<Money>(Money.zero(), (s, m) => s + m);
      expect(sum, Money.fromToman(1000));
    });

    test('جمع درصد != 100 -> خطا', () {
      expect(
        () => calc.percentage(Money.fromToman(1000), {'a': 50, 'b': 40}),
        throwsA(isA<SplitValidationException>()),
      );
    });
  });

  group('Shares Split', () {
    test('تقسیم بر اساس سهم - جمع باید برابر total باشد', () {
      final result = calc.shares(Money.fromToman(400), {
        'a': 2,
        'b': 1,
        'c': 1,
      });
      final sum = result.values.fold<Money>(Money.zero(), (s, m) => s + m);
      expect(sum, Money.fromToman(400));
      expect(result['a'], Money.fromToman(200));
    });

    test('بدون هیچ سهمی -> خطا', () {
      expect(() => calc.shares(Money.fromToman(400), {}),
          throwsA(isA<SplitValidationException>()));
    });
  });

  group('Amount Validation', () {
    test('مبلغ صفر -> خطا', () {
      expect(() => calc.validateAmount(Money.zero()),
          throwsA(isA<SplitValidationException>()));
    });

    test('مبلغ منفی -> خطا', () {
      expect(() => calc.validateAmount(Money.fromToman(-100)),
          throwsA(isA<SplitValidationException>()));
    });

    test('مبلغ بیش از حد مجاز -> خطا', () {
      expect(
        () => calc.validateAmount(
          Money.fromToman(1000000),
          maxAllowed: Money.fromToman(500000),
        ),
        throwsA(isA<SplitValidationException>()),
      );
    });
  });
}
