class FinancialValidation {
  static String name(String value) {
    final result = value.trim();
    if (result.isEmpty || result.length > 50) {
      throw const FormatException(
          'El nombre debe tener entre 1 y 50 caracteres.');
    }
    return result;
  }

  static void type(String value) {
    if (value != 'income' && value != 'expense') {
      throw const FormatException('Tipo de movimiento inválido.');
    }
  }

  static DateTime date(DateTime value) {
    final utc = value.toUtc();
    if (utc.year < 1900 || utc.year > 9999) {
      throw const FormatException('La fecha está fuera del rango permitido.');
    }
    return utc;
  }

  static String? note(String? value) {
    final result = value?.trim();
    if (result != null && result.length > 500) {
      throw const FormatException('La nota admite máximo 500 caracteres.');
    }
    return result == null || result.isEmpty ? null : result;
  }

  static void color(String value) {
    if (!RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(value)) {
      throw const FormatException('Color inválido.');
    }
  }
}
