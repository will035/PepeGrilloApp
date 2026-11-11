import 'dart:async';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pepe_grillo_app/core/database/database.dart';
import 'package:pepe_grillo_app/core/providers/database_provider.dart';
import 'package:pepe_grillo_app/core/repositories/finance_repository.dart';
import 'package:pepe_grillo_app/features/transactions/presentation/screens/quick_add_screen.dart';

class PendingRepository extends FinanceRepository {
  PendingRepository(super.db);
  final pending = Completer<int>();
  int calls = 0;
  @override
  Future<int> addTransaction(
      {required String amountText,
      required String type,
      required int categoryId,
      required DateTime date,
      int? accountId,
      String? note}) {
    calls++;
    return pending.future;
  }
}

void main() {
  testWidgets(
      'double tap starts one save; failure re-enables form without clearing input',
      (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final repository = PendingRepository(db);
    await tester.runAsync(() async {
      await db.select(db.categories).get();
      await tester.pumpWidget(ProviderScope(overrides: [
        databaseProvider.overrideWithValue(db),
        financeRepositoryProvider.overrideWithValue(repository),
      ], child: const MaterialApp(home: QuickAddScreen())));
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '12.34');
    await tester.tap(find.text('Comida'));
    await tester.pump();
    final save = find.widgetWithText(ElevatedButton, 'GUARDAR');
    await tester.tap(save);
    await tester.tap(save);
    await tester.pump();
    expect(repository.calls, 1);
    expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNull);
    repository.pending.completeError(Exception('disk error'));
    await tester.pumpAndSettle();
    expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNotNull);
    expect(find.text('12.34'), findsOneWidget);
    expect(find.textContaining('No se pudo guardar'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(db.close);
  });
}
