import 'package:flutter_test/flutter_test.dart';
import 'package:pepe_grillo_app/core/domain/money.dart';

void main() {
  test('parses pesos as exact integer cents', () {
    expect(Money.parse('0.01'), 1);
    expect(Money.parse('10'), 1000);
    expect(Money.parse(' 10,5 '), 1050);
    expect(Money.parse('9999999999.99'), Money.maxCents);
    expect(Money.parse('0.10') + Money.parse('0.20'), 30);
  });
  test('never rounds or truncates invalid input', () {
    for (final input in [
      '1.001',
      '1.000',
      '10.125',
      '1,234.56',
      'NaN',
      'Infinity',
      '1e2',
      '-1',
      '0',
      '0.00',
      '',
      '.5',
      '1.',
      '10000000000'
    ]) {
      expect(() => Money.parse(input), throwsFormatException, reason: input);
    }
  });
  test('formats cents without floating point or lost precision', () {
    expect(Money.format(1), '\$0.01 MXN');
    expect(Money.format(-123456), '-\$1,234.56 MXN');
    expect(Money.format(Money.maxCents), '\$9,999,999,999.99 MXN');
  });
}
