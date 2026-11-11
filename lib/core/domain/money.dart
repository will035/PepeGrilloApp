/// MXN minor units. No floating point is used for input, storage or formatting.
class Money {
  // Explicit bound leaves headroom for checked additions and SQLite arithmetic.
  static const maxCents = 999999999999;

  static int parse(String input) {
    final text = input.trim();
    if (!RegExp(r'^\d{1,10}([.,]\d{1,2})?$').hasMatch(text)) {
      throw const FormatException(
          'Ingresa pesos con máximo dos decimales, sin separadores de miles.');
    }
    final parts = text.split(RegExp('[.,]'));
    final cents = int.parse(parts[0]) * 100 +
        (parts.length == 1 ? 0 : int.parse(parts[1].padRight(2, '0')));
    validateAmount(cents);
    return cents;
  }

  static void validateAmount(int cents) {
    if (cents <= 0 || cents > maxCents) {
      throw const FormatException(
          'El monto debe ser mayor que cero y no superar 9,999,999,999.99 MXN.');
    }
  }

  static void validateBalance(int cents) {
    if (cents < -maxCents || cents > maxCents) {
      throw const FormatException('El saldo excede el límite permitido.');
    }
  }

  static String format(int cents) {
    final absolute = cents.abs();
    final pesos = (absolute ~/ 100).toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]},');
    return '${cents < 0 ? '-' : ''}\$$pesos.${(absolute % 100).toString().padLeft(2, '0')} MXN';
  }
}
