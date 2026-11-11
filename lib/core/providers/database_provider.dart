import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/database.dart';
import '../repositories/finance_repository.dart';

part 'database_provider.g.dart';

@Riverpod(keepAlive: true)
AppDatabase database(DatabaseRef ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}

final financeRepositoryProvider = Provider<FinanceRepository>((ref) {
  return FinanceRepository(ref.watch(databaseProvider));
});

enum DateFilterType { all, firstQuincena, secondQuincena }

@riverpod
class DateFilter extends _$DateFilter {
  @override
  DateFilterType build() => DateFilterType.all;

  void setFilter(DateFilterType type) {
    state = type;
  }
}

(DateTime, DateTime)? _getDateRangeForFilter(DateFilterType type) {
  final now = DateTime.now();
  if (type == DateFilterType.all) return null;

  if (type == DateFilterType.firstQuincena) {
    return (
      DateTime(now.year, now.month, 1),
      DateTime(now.year, now.month, 15, 23, 59, 59)
    );
  } else {
    final lastDay = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    return (DateTime(now.year, now.month, 16), lastDay);
  }
}

@riverpod
Stream<List<TransactionData>> recentTransactions(RecentTransactionsRef ref) {
  final db = ref.watch(databaseProvider);
  final filter = ref.watch(dateFilterProvider);
  final range = _getDateRangeForFilter(filter);

  final query = db.select(db.transactions)
    ..orderBy(
        [(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)]);

  if (range != null) {
    query.where((t) => t.date.isBetweenValues(range.$1, range.$2));
  } else {
    query.limit(10);
  }

  return query.watch();
}

@riverpod
Stream<int> totalBalance(TotalBalanceRef ref) {
  final db = ref.watch(databaseProvider);
  final balanceExp = db.accounts.balanceCents.sum();
  final query = db.selectOnly(db.accounts)..addColumns([balanceExp]);

  return query.map((row) => row.read(balanceExp) ?? 0).watchSingle();
}

class CategorySum {
  final String categoryName;
  final int totalAmount;

  CategorySum(this.categoryName, this.totalAmount);
}

@riverpod
Stream<List<CategorySum>> expensesByCategory(ExpensesByCategoryRef ref) {
  final db = ref.watch(databaseProvider);
  final filter = ref.watch(dateFilterProvider);
  final range = _getDateRangeForFilter(filter);

  final amountSum = db.transactions.amountCents.sum();

  final query = db.selectOnly(db.transactions)
    ..addColumns([db.categories.name, amountSum])
    ..join([
      innerJoin(
          db.categories, db.categories.id.equalsExp(db.transactions.categoryId))
    ])
    ..groupBy([db.categories.id]);

  Expression<bool> whereClause = db.transactions.type.equals('expense');
  if (range != null) {
    whereClause =
        whereClause & db.transactions.date.isBetweenValues(range.$1, range.$2);
  }
  query.where(whereClause);

  return query.map((row) {
    return CategorySum(
      row.read(db.categories.name) ?? 'Unknown',
      row.read(amountSum) ?? 0,
    );
  }).watch();
}

@riverpod
Stream<List<Subscription>> subscriptionsList(SubscriptionsListRef ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.subscriptions)
        ..orderBy([
          (s) => OrderingTerm(expression: s.billingDay, mode: OrderingMode.asc)
        ]))
      .watch();
}
