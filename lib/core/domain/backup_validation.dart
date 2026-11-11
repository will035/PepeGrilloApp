import 'money.dart';
import 'financial_validation.dart';

class BackupValidation {
  static String _string(Map<String, dynamic> row, String key) {
    final value = row[key];
    if (value is! String) throw FormatException('Campo inválido: $key.');
    return value;
  }

  static void validate(Map<String, dynamic> map) {
    // Reject old peso/REAL backups: interpreting them as cents would corrupt data.
    if (map['formatVersion'] != 3 ||
        map['currency'] != 'MXN' ||
        map['moneyUnit'] != 'cent') {
      throw const FormatException(
          'Respaldo incompatible: se requiere versión 3, MXN y centavos enteros.');
    }
    for (final table in [
      'accounts',
      'categories',
      'transactions',
      'subscriptions'
    ]) {
      if (map[table] is! List) {
        throw const FormatException('Respaldo incompleto.');
      }
      final ids = <int>{};
      for (final row in map[table] as List) {
        if (row is! Map<String, dynamic> ||
            row['id'] is! int ||
            row['id'] <= 0 ||
            !ids.add(row['id'] as int)) {
          throw const FormatException(
              'Identificadores inválidos o duplicados.');
        }
        if (table == 'accounts' || table == 'subscriptions') {
          FinancialValidation.name(_string(row, 'name'));
          FinancialValidation.color(_string(row, 'colorHex'));
          final field = table == 'accounts' ? 'balanceCents' : 'amountCents';
          if (row[field] is! int) {
            throw const FormatException('Se requieren centavos enteros.');
          }
          if (table == 'accounts') {
            Money.validateBalance(row[field] as int);
            if (row['currency'] != 'MXN') {
              throw const FormatException('Solo se admite MXN.');
            }
          } else {
            Money.validateAmount(row[field] as int);
            if (row['billingDay'] is! int ||
                row['billingDay'] < 1 ||
                row['billingDay'] > 31) {
              throw const FormatException('Día de cobro inválido.');
            }
          }
        }
        if (table == 'categories') {
          FinancialValidation.name(_string(row, 'name'));
          FinancialValidation.type(_string(row, 'type'));
          FinancialValidation.name(_string(row, 'iconName'));
        }
        if (table == 'transactions') {
          if (row['amountCents'] is! int ||
              row['accountId'] is! int ||
              row['categoryId'] is! int ||
              row['date'] is! int) {
            throw const FormatException('Movimiento inválido.');
          }
          Money.validateAmount(row['amountCents'] as int);
          FinancialValidation.type(_string(row, 'type'));
          if (row['note'] != null && row['note'] is! String) {
            throw const FormatException('Nota inválida.');
          }
          FinancialValidation.note(row['note'] as String?);
          if (row['date'] < -2208988800000 || row['date'] > 253402300799999) {
            throw const FormatException('Fecha inválida.');
          }
          FinancialValidation.date(DateTime.fromMillisecondsSinceEpoch(
              row['date'] as int,
              isUtc: true));
        }
      }
    }
    final accountRows = {
      for (final row in map['accounts'] as List) row['id']: row
    };
    final categoryRows = {
      for (final row in map['categories'] as List) row['id']: row
    };
    final balances = <int, BigInt>{};
    for (final row in map['transactions'] as List) {
      if (!accountRows.containsKey(row['accountId']) ||
          categoryRows[row['categoryId']]?['type'] != row['type']) {
        throw const FormatException(
            'Cuenta o categoría incompatible en el respaldo.');
      }
      final id = row['accountId'] as int;
      final amount = BigInt.from(row['amountCents'] as int);
      balances[id] = (balances[id] ?? BigInt.zero) +
          (row['type'] == 'income' ? amount : -amount);
    }
    for (final row in accountRows.values) {
      if (BigInt.from(row['balanceCents'] as int) !=
          (balances[row['id']] ?? BigInt.zero)) {
        throw const FormatException(
            'El saldo no coincide con los movimientos.');
      }
    }
  }
}
