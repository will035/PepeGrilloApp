import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';
import 'database_provider.dart';

final monthlyTotalsProvider =
    StreamProvider.autoDispose<({int income, int expenses})>((ref) {
  final db = ref.watch(databaseProvider);
  final now = DateTime.now();
  final sum = db.transactions.amountCents.sum();
  final query = db.selectOnly(db.transactions)
    ..addColumns([db.transactions.type, sum])
    ..where(db.transactions.date
            .isBiggerOrEqualValue(DateTime(now.year, now.month)) &
        db.transactions.date
            .isSmallerThanValue(DateTime(now.year, now.month + 1)))
    ..groupBy([db.transactions.type]);
  return query.watch().map((rows) {
    var income = 0;
    var expenses = 0;
    for (final row in rows) {
      if (row.read(db.transactions.type) == 'income') {
        income = row.read(sum) ?? 0;
      } else {
        expenses = row.read(sum) ?? 0;
      }
    }
    return (income: income, expenses: expenses);
  });
});

class MovementEntry {
  const MovementEntry(this.movement, this.category, this.account);
  final TransactionData movement;
  final Category category;
  final Account account;
}

/// Fixed-size SQL pages. Read one extra row to determine whether there is a next page.
final movementPageProvider =
    StreamProvider.autoDispose.family<List<MovementEntry>, int>((ref, page) {
  final db = ref.watch(databaseProvider);
  final query = db.select(db.transactions).join([
    innerJoin(
        db.categories, db.categories.id.equalsExp(db.transactions.categoryId)),
    innerJoin(db.accounts, db.accounts.id.equalsExp(db.transactions.accountId)),
  ])
    ..orderBy([
      OrderingTerm.desc(db.transactions.date),
      OrderingTerm.desc(db.transactions.id)
    ])
    ..limit(21, offset: page * 20);
  return query.watch().map((rows) => rows
      .map((row) => MovementEntry(row.readTable(db.transactions),
          row.readTable(db.categories), row.readTable(db.accounts)))
      .toList());
});
