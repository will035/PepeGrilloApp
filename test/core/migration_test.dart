import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pepe_grillo_app/core/database/database.dart';
import 'package:pepe_grillo_app/core/repositories/finance_repository.dart';

void main() {
  for (final version in [1, 2]) {
    test('v$version test data resets once; v3 persists on reopen', () async {
      final directory =
          await Directory.systemTemp.createTemp('pepegrillo_migration_');
      final file = File('${directory.path}/test.sqlite');
      var db = AppDatabase.forTesting(NativeDatabase(file, setup: (raw) {
        raw.execute(
            'CREATE TABLE accounts(id INTEGER PRIMARY KEY, name TEXT, balance REAL, currency TEXT, color_hex TEXT)');
        raw.execute(
            'CREATE TABLE categories(id INTEGER PRIMARY KEY, name TEXT, type TEXT, icon_name TEXT)');
        raw.execute(
            'CREATE TABLE transactions(id INTEGER PRIMARY KEY, amount REAL, type TEXT, date INTEGER, account_id INTEGER REFERENCES accounts(id), category_id INTEGER REFERENCES categories(id), note TEXT)');
        if (version == 2) {
          raw.execute(
              'CREATE TABLE subscriptions(id INTEGER PRIMARY KEY, name TEXT, amount REAL, billing_day INTEGER, color_hex TEXT)');
        }
        raw.execute(
            "INSERT INTO accounts VALUES(1,'Old',10.125,'USD','#000000')");
        raw.execute("INSERT INTO categories VALUES(1,'Old','income','work')");
        raw.execute(
            "INSERT INTO transactions VALUES(1,10.125,'income',1800000000,1,1,NULL)");
        raw.execute('PRAGMA user_version = $version');
      }));
      try {
        final accounts = await db.select(db.accounts).get();
        expect(accounts.map((a) => a.currency), everyElement('MXN'));
        expect(accounts.map((a) => a.balanceCents), everyElement(0));
        expect(await db.select(db.transactions).get(), isEmpty);
        await FinanceRepository(db).addTransaction(
            amountText: '0.01',
            type: 'income',
            categoryId: 3,
            date: DateTime.utc(2026));
        await db.close();
        db = AppDatabase.forTesting(NativeDatabase(file));
        expect((await db.select(db.transactions).getSingle()).amountCents, 1);
        final columns =
            await db.customSelect('PRAGMA table_info(accounts)').get();
        expect(columns.any((r) => r.data['name'] == 'balance'), isFalse);
        expect(
            columns
                .singleWhere((r) => r.data['name'] == 'balance_cents')
                .data['type'],
            'INTEGER');
      } finally {
        await db.close();
        await directory.delete(recursive: true);
      }
    });
  }
}
