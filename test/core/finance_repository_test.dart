import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pepe_grillo_app/core/database/database.dart';
import 'package:pepe_grillo_app/core/repositories/finance_repository.dart';

void main() {
  late AppDatabase db;
  late FinanceRepository repository;
  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = FinanceRepository(db);
  });
  tearDown(() => db.close());

  Future<int> add(String amount,
          {String type = 'income',
          int? category,
          int? account,
          DateTime? date}) =>
      repository.addTransaction(
        amountText: amount,
        type: type,
        categoryId: category ?? (type == 'income' ? 3 : 1),
        accountId: account,
        date: date ?? DateTime.utc(2026, 11, 9),
      );
  Future<int> balance() async =>
      (await (db.select(db.accounts)..where((a) => a.id.equals(1))).getSingle())
          .balanceCents;

  test('income, expense and idempotent deletion keep exact balance', () async {
    await add('0.10');
    await add('0.20');
    final expense = await add('0.01', type: 'expense');
    expect(await balance(), 29);
    await repository.deleteTransaction(expense);
    await repository.deleteTransaction(expense);
    expect(await balance(), 30);
    expect(await db.select(db.transactions).get(), hasLength(2));
  });

  test('parallel writes do not lose balance updates', () async {
    await Future.wait(List.generate(30, (_) => add('0.01')));
    expect(await balance(), 30);
    expect(await db.select(db.transactions).get(), hasLength(30));
  });

  test('failed balance write rolls back inserted movement', () async {
    await balance();
    await db.customStatement(
        "CREATE TRIGGER fail_balance BEFORE UPDATE ON accounts BEGIN SELECT RAISE(ABORT, 'simulated write failure'); END");
    await expectLater(add('15.25'), throwsA(isA<Exception>()));
    expect(await balance(), 0);
    expect(await db.select(db.transactions).get(), isEmpty);
  });

  test('failed deletion rolls back restored balance', () async {
    final id = await add('10');
    await db.customStatement(
        "CREATE TRIGGER fail_delete BEFORE DELETE ON transactions BEGIN SELECT RAISE(ABORT, 'simulated write failure'); END");
    await expectLater(
        repository.deleteTransaction(id), throwsA(isA<Exception>()));
    expect(await balance(), 1000);
    expect(await db.select(db.transactions).get(), hasLength(1));
  });

  test('rejects invalid financial inputs before writing', () async {
    await expectLater(add('1.001'), throwsFormatException);
    await expectLater(add('1', category: 1), throwsFormatException);
    await expectLater(add('1', account: 999), throwsFormatException);
    await expectLater(add('1', type: 'invalid'), throwsFormatException);
    await expectLater(
        add('1', date: DateTime.utc(1800)), throwsFormatException);
    await expectLater(
        repository.addCategory('  ', 'income', 'work'), throwsFormatException);
    await expectLater(repository.addSubscription('Test', '1.999', 1, '#FF0000'),
        throwsFormatException);
    await expectLater(repository.addSubscription('Test', '1', 32, '#FF0000'),
        throwsFormatException);
    expect(await db.select(db.transactions).get(), isEmpty);
    expect(await balance(), 0);
  });

  test('rejects balance overflow and preserves previous movements', () async {
    await add('9999999999.99');
    await expectLater(add('0.01'), throwsFormatException);
    expect(await balance(), 999999999999);
    expect(await db.select(db.transactions).get(), hasLength(1));
  });

  test('stores the instant consistently across UTC offsets', () async {
    final date = DateTime.parse('2026-11-09T23:30:00-06:00');
    await add('1', date: date);
    final movement = await db.select(db.transactions).getSingle();
    expect(movement.date.toUtc(), DateTime.utc(2026, 11, 10, 5, 30));
  });

  test('SQLite enforces foreign keys and monetary constraints', () async {
    await balance();
    await expectLater(
        db.customStatement(
            "INSERT INTO transactions(amount_cents,type,date,account_id,category_id) VALUES(100,'income',1800000000,999,3)"),
        throwsA(isA<Exception>()));
    await expectLater(
        db.customStatement('UPDATE accounts SET balance_cents = 1.5'),
        throwsA(isA<Exception>()));
    await expectLater(
        db.customStatement("UPDATE accounts SET currency = 'USD'"),
        throwsA(isA<Exception>()));
    expect(await balance(), 0);
  });

  test('backup roundtrip preserves integer cents', () async {
    await add('12.34');
    await repository.addSubscription('Servicio', '1.01', 31, '#FF0000');
    final backup = await db.exportToJson();
    await add('50');
    await db.importFromJson(backup);
    expect(await balance(), 1234);
    expect((await db.select(db.subscriptions).getSingle()).amountCents, 101);
    expect(await db.exportToJson(), backup);
  });

  test(
      'old, fractional, inconsistent and orphan backups leave current data intact',
      () async {
    await add('12.34');
    final backup = await db.exportToJson();
    for (final mutate in <void Function(Map<String, dynamic>)>[
      (m) => m.remove('formatVersion'),
      (m) => m['transactions'][0]['amountCents'] = 1234.5,
      (m) => m['transactions'][0]['accountId'] = 999,
      (m) => m['accounts'][0]['balanceCents'] = 1,
    ]) {
      final map = jsonDecode(backup) as Map<String, dynamic>;
      mutate(map);
      await expectLater(
          db.importFromJson(jsonEncode(map)), throwsFormatException);
      expect(await db.exportToJson(), backup);
    }
  });
}
