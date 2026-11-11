import 'dart:io';
import 'dart:convert';
import '../domain/backup_validation.dart';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

// -----------------------------------------------------------------------------
// Tables Definition
// -----------------------------------------------------------------------------

class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  IntColumn get balanceCents => integer().withDefault(const Constant(0))();
  @override
  List<String> get customConstraints => [
        "CHECK(typeof(balance_cents) = 'integer' AND balance_cents BETWEEN -999999999999 AND 999999999999)",
        "CHECK(currency = 'MXN')",
        "CHECK(length(trim(name)) BETWEEN 1 AND 50)",
      ];
  TextColumn get currency =>
      text().withLength(min: 3, max: 3).withDefault(const Constant('MXN'))();
  TextColumn get colorHex => text()
      .withLength(min: 7, max: 7)
      .withDefault(const Constant('#4CAF50'))();
}

class Categories extends Table {
  @override
  List<String> get customConstraints => [
        "CHECK(type IN ('income', 'expense'))",
        "CHECK(length(trim(name)) BETWEEN 1 AND 50)",
      ];
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  TextColumn get type =>
      text().withLength(min: 6, max: 7)(); // "income" or "expense"
  TextColumn get iconName => text().withDefault(const Constant('category'))();
}

@DataClassName('TransactionData')
class Transactions extends Table {
  @override
  List<String> get customConstraints => [
        "CHECK(typeof(amount_cents) = 'integer' AND amount_cents BETWEEN 1 AND 999999999999)",
        "CHECK(type IN ('income', 'expense'))",
        "CHECK(note IS NULL OR length(note) <= 500)",
        "CHECK(date BETWEEN -2208988800 AND 253402300799)",
      ];
  IntColumn get id => integer().autoIncrement()();
  IntColumn get amountCents => integer()();
  TextColumn get type =>
      text().withLength(min: 6, max: 7)(); // "income" or "expense"
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
  IntColumn get accountId => integer().references(Accounts, #id)();
  IntColumn get categoryId => integer().references(Categories, #id)();
  TextColumn get note => text().nullable()();
}

class Subscriptions extends Table {
  @override
  List<String> get customConstraints => [
        "CHECK(typeof(amount_cents) = 'integer' AND amount_cents BETWEEN 1 AND 999999999999)",
        "CHECK(typeof(billing_day) = 'integer' AND billing_day BETWEEN 1 AND 31)",
        "CHECK(length(trim(name)) BETWEEN 1 AND 50)",
      ];
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  IntColumn get amountCents => integer()();
  IntColumn get billingDay => integer()();
  TextColumn get colorHex => text()
      .withLength(min: 7, max: 7)
      .withDefault(const Constant('#2196F3'))();
}

// -----------------------------------------------------------------------------
// Database Implementation
// -----------------------------------------------------------------------------

@DriftDatabase(tables: [Accounts, Categories, Transactions, Subscriptions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _seed();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // One-time destructive migration authorized for pre-v3 TEST data.
        // Never use this strategy for future production migrations.
        if (from < 3) {
          await transaction(() async {
            for (final table in [
              'transactions',
              'subscriptions',
              'categories',
              'accounts'
            ]) {
              await customStatement('DROP TABLE IF EXISTS "$table"');
            }
            await m.createAll();
            await _seed();
          });
        }
      },
      beforeOpen: (_) async {
        await customStatement('PRAGMA foreign_keys = ON');
        await customStatement('PRAGMA busy_timeout = 5000');
        await customStatement('PRAGMA synchronous = FULL');
      },
    );
  }

  Future<void> _seed() async {
    await batch((b) {
      b.insertAll(accounts, [
        AccountsCompanion.insert(name: 'Efectivo'),
        AccountsCompanion.insert(
            name: 'Banco', colorHex: const Value('#2196F3')),
      ]);
      b.insertAll(categories, [
        CategoriesCompanion.insert(
            name: 'Comida',
            type: 'expense',
            iconName: const Value('restaurant')),
        CategoriesCompanion.insert(
            name: 'Transporte',
            type: 'expense',
            iconName: const Value('directions_car')),
        CategoriesCompanion.insert(
            name: 'Salario', type: 'income', iconName: const Value('work')),
      ]);
    });
  }

  Future<String> exportToJson() => transaction(() async {
        final allAccounts = await select(accounts).get();
        final allCategories = await select(categories).get();
        final allTransactions = await select(transactions).get();
        final allSubscriptions = await select(subscriptions).get();

        final map = {
          'formatVersion': 3,
          'currency': 'MXN',
          'moneyUnit': 'cent',
          'accounts': allAccounts.map((a) => a.toJson()).toList(),
          'categories': allCategories.map((c) => c.toJson()).toList(),
          'transactions': allTransactions.map((t) => t.toJson()).toList(),
          'subscriptions': allSubscriptions.map((s) => s.toJson()).toList(),
        };

        return jsonEncode(map);
      });

  Future<void> importFromJson(String jsonString) async {
    final decoded = jsonDecode(jsonString);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('El respaldo debe contener un objeto JSON.');
    }
    final map = decoded;

    BackupValidation.validate(map);
    return transaction(() async {
      await delete(transactions).go();
      await delete(categories).go();
      await delete(accounts).go();
      await delete(subscriptions).go();

      final accountsData = (map['accounts'] as List)
          .map((e) => Account.fromJson(e as Map<String, dynamic>));
      final categoriesData = (map['categories'] as List)
          .map((e) => Category.fromJson(e as Map<String, dynamic>));
      final transactionsData = (map['transactions'] as List)
          .map((e) => TransactionData.fromJson(e as Map<String, dynamic>));
      final subscriptionsData = map['subscriptions'] != null
          ? (map['subscriptions'] as List)
              .map((e) => Subscription.fromJson(e as Map<String, dynamic>))
          : <Subscription>[];

      await batch((b) {
        b.insertAll(accounts, accountsData);
        b.insertAll(categories, categoriesData);
        b.insertAll(transactions, transactionsData);
        b.insertAll(subscriptions, subscriptionsData);
      });
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'pepegrillo.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
