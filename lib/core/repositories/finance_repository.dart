import 'package:drift/drift.dart';

import '../database/database.dart';
import '../domain/financial_validation.dart';
import '../domain/money.dart';

/// The write boundary for financial operations. UI never updates balances.
class FinanceRepository {
  FinanceRepository(this._db);
  final AppDatabase _db;

  Future<int> addTransaction({
    required String amountText,
    required String type,
    required int categoryId,
    required DateTime date,
    int? accountId,
    String? note,
  }) async {
    final cents = Money.parse(amountText);
    FinancialValidation.type(type);
    final utcDate = FinancialValidation.date(date);
    final cleanNote = FinancialValidation.note(note);
    return _db.transaction(() async {
      final accountQuery = _db.select(_db.accounts);
      if (accountId != null) {
        accountQuery.where((a) => a.id.equals(accountId));
      } else {
        accountQuery
          ..orderBy([(a) => OrderingTerm.asc(a.id)])
          ..limit(1);
      }
      final account = await accountQuery.getSingleOrNull();
      if (account == null || account.currency != 'MXN') {
        throw const FormatException('Selecciona una cuenta válida en MXN.');
      }
      final category = await (_db.select(_db.categories)
            ..where((c) => c.id.equals(categoryId)))
          .getSingleOrNull();
      if (category == null || category.type != type) {
        throw const FormatException(
            'La categoría no corresponde al movimiento.');
      }
      final delta = type == 'income' ? cents : -cents;
      Money.validateBalance(account.balanceCents + delta);
      final id = await _db.into(_db.transactions).insert(
            TransactionsCompanion.insert(
              amountCents: cents,
              type: type,
              date: Value(utcDate),
              accountId: account.id,
              categoryId: categoryId,
              note: Value(cleanNote),
            ),
          );
      // SQL arithmetic avoids writing a stale balance. Both writes commit together.
      await (_db.update(_db.accounts)..where((a) => a.id.equals(account.id)))
          .write(AccountsCompanion.custom(
        balanceCents: _db.accounts.balanceCents + Constant(delta),
      ));
      return id;
    });
  }

  Future<void> deleteTransaction(int id) => _db.transaction(() async {
        final movement = await (_db.select(_db.transactions)
              ..where((t) => t.id.equals(id)))
            .getSingleOrNull();
        if (movement == null) return; // Repeated deletion is harmless.
        final account = await (_db.select(_db.accounts)
              ..where((a) => a.id.equals(movement.accountId)))
            .getSingle();
        final delta = movement.type == 'income'
            ? -movement.amountCents
            : movement.amountCents;
        Money.validateBalance(account.balanceCents + delta);
        await (_db.update(_db.accounts)..where((a) => a.id.equals(account.id)))
            .write(AccountsCompanion.custom(
          balanceCents: _db.accounts.balanceCents + Constant(delta),
        ));
        await (_db.delete(_db.transactions)..where((t) => t.id.equals(id)))
            .go();
      });

  Future<int> addCategory(String name, String type, String iconName) async {
    final cleanName = FinancialValidation.name(name);
    FinancialValidation.type(type);
    if (iconName.trim().isEmpty || iconName.length > 50) {
      throw const FormatException('Icono inválido.');
    }
    return _db.into(_db.categories).insert(CategoriesCompanion.insert(
          name: cleanName,
          type: type,
          iconName: Value(iconName),
        ));
  }

  Future<int> addSubscription(
      String name, String amountText, int billingDay, String colorHex) async {
    final cleanName = FinancialValidation.name(name);
    final cents = Money.parse(amountText);
    FinancialValidation.color(colorHex);
    if (billingDay < 1 || billingDay > 31) {
      throw const FormatException('El día de cobro debe estar entre 1 y 31.');
    }
    return _db.into(_db.subscriptions).insert(SubscriptionsCompanion.insert(
          name: cleanName,
          amountCents: cents,
          billingDay: billingDay,
          colorHex: Value(colorHex),
        ));
  }

  Future<void> deleteSubscription(int id) async {
    await (_db.delete(_db.subscriptions)..where((s) => s.id.equals(id))).go();
  }
}
