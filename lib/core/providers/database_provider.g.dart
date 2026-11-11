// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$databaseHash() => r'397e5c893a29d7b17310deb6724df71242a8ab08';

/// See also [database].
@ProviderFor(database)
final databaseProvider = Provider<AppDatabase>.internal(
  database,
  name: r'databaseProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$databaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DatabaseRef = ProviderRef<AppDatabase>;
String _$recentTransactionsHash() =>
    r'd5ecf3f4ddc09d0fc79128e4a8582a77ccd3fec8';

/// See also [recentTransactions].
@ProviderFor(recentTransactions)
final recentTransactionsProvider =
    AutoDisposeStreamProvider<List<TransactionData>>.internal(
  recentTransactions,
  name: r'recentTransactionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recentTransactionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecentTransactionsRef
    = AutoDisposeStreamProviderRef<List<TransactionData>>;
String _$totalBalanceHash() => r'c47cdf9ee0df013363ae63469fca21f504081505';

/// See also [totalBalance].
@ProviderFor(totalBalance)
final totalBalanceProvider = AutoDisposeStreamProvider<int>.internal(
  totalBalance,
  name: r'totalBalanceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$totalBalanceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TotalBalanceRef = AutoDisposeStreamProviderRef<int>;
String _$expensesByCategoryHash() =>
    r'fd08f6cef392dc73ccc4cec4ee413ae2ae212267';

/// See also [expensesByCategory].
@ProviderFor(expensesByCategory)
final expensesByCategoryProvider =
    AutoDisposeStreamProvider<List<CategorySum>>.internal(
  expensesByCategory,
  name: r'expensesByCategoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$expensesByCategoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ExpensesByCategoryRef = AutoDisposeStreamProviderRef<List<CategorySum>>;
String _$subscriptionsListHash() => r'32ac412dcfa0871c51b122b861580d0751f7adf1';

/// See also [subscriptionsList].
@ProviderFor(subscriptionsList)
final subscriptionsListProvider =
    AutoDisposeStreamProvider<List<Subscription>>.internal(
  subscriptionsList,
  name: r'subscriptionsListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$subscriptionsListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SubscriptionsListRef = AutoDisposeStreamProviderRef<List<Subscription>>;
String _$dateFilterHash() => r'75dfe7f79d53dcb8887149ed07545c62a9aca970';

/// See also [DateFilter].
@ProviderFor(DateFilter)
final dateFilterProvider =
    AutoDisposeNotifierProvider<DateFilter, DateFilterType>.internal(
  DateFilter.new,
  name: r'dateFilterProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$dateFilterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DateFilter = AutoDisposeNotifier<DateFilterType>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
