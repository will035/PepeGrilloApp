import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pepe_grillo_app/core/database/database.dart';
import 'package:pepe_grillo_app/core/presentation/scaffold_with_nav_bar.dart';
import 'package:pepe_grillo_app/core/providers/dashboard_provider.dart';
import 'package:pepe_grillo_app/core/providers/database_provider.dart';
import 'package:pepe_grillo_app/core/theme/app_theme.dart';
import 'package:pepe_grillo_app/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:pepe_grillo_app/features/dashboard/presentation/screens/analysis_screen.dart';
import 'package:pepe_grillo_app/features/dashboard/presentation/screens/advisor_screen.dart';

void main() {
  for (final size in [
    const Size(390, 844),
    const Size(1440, 900),
    const Size(320, 740)
  ]) {
    testWidgets('dashboard adapts and navigates at ${size.width}',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final loader = FontLoader('Inter')
        ..addFont(rootBundle.load('assets/fonts/Inter.ttf'));
      await loader.load();
      await (FontLoader('MaterialIcons')
            ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
          .load();
      final router = GoRouter(routes: [
        ShellRoute(
            builder: (_, __, child) => ScaffoldWithNavBar(child: child),
            routes: [
              GoRoute(path: '/', builder: (_, __) => const DashboardScreen()),
              GoRoute(
                  path: '/analysis',
                  builder: (_, __) => const AnalysisScreen()),
              GoRoute(
                  path: '/advisor', builder: (_, __) => const AdvisorScreen()),
              GoRoute(
                  path: '/settings',
                  builder: (_, __) =>
                      const Scaffold(body: Text('Configuración'))),
              GoRoute(
                  path: '/subscriptions',
                  builder: (_, __) =>
                      const Scaffold(body: Text('Pagos y Suscripciones'))),
              GoRoute(
                  path: '/transactions',
                  builder: (_, __) =>
                      const Scaffold(body: Text('Tus movimientos'))),
            ]),
        GoRoute(
            path: '/add',
            builder: (_, __) => const Scaffold(body: Text('Nuevo Registro')))
      ]);
      addTearDown(router.dispose);
      final now = DateTime.now();
      final entries = [
        for (var i = 0; i < 3; i++)
          MovementEntry(
            TransactionData(
                id: i,
                amountCents: [125000, 21900, 1425000][i],
                type: i == 2 ? 'income' : 'expense',
                date: now.subtract(Duration(days: i)),
                accountId: 1,
                categoryId: 1,
                note: ['Supermercado', 'Netflix', 'Nómina quincenal'][i]),
            Category(
                id: 1,
                name: 'Comida',
                type: 'expense',
                iconName: ['restaurant', 'category', 'work'][i]),
            const Account(
                id: 1,
                name: 'Efectivo',
                balanceCents: 0,
                currency: 'MXN',
                colorHex: '#000000'),
          )
      ];
      final key = GlobalKey();
      await tester.pumpWidget(ProviderScope(
          overrides: [
            totalBalanceProvider.overrideWith((ref) => Stream.value(4523000)),
            monthlyTotalsProvider.overrideWith(
                (ref) => Stream.value((income: 2850000, expenses: 1234000))),
            subscriptionsListProvider.overrideWith((ref) => Stream.value([])),
            movementPageProvider
                .overrideWith((ref, page) => Stream.value(entries)),
            expensesByCategoryProvider.overrideWith((ref) => Stream.value([])),
          ],
          child: RepaintBoundary(
              key: key,
              child: MaterialApp.router(
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.lightTheme,
                  routerConfig: router))));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Balance total'), findsOneWidget);
      if (const bool.fromEnvironment('CAPTURE_DESIGN')) {
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = (await tester.runAsync(() => boundary.toImage()))!;
        final bytes = await tester
            .runAsync(() => image.toByteData(format: ui.ImageByteFormat.png));
        await tester.runAsync(() =>
            File('/tmp/pepegrillo-${size.width.toInt()}.png')
                .writeAsBytes(bytes!.buffer.asUint8List()));
        image.dispose();
      }
      await tester.tap(find.byTooltip('Ocultar importes'));
      await tester.pumpAndSettle();
      expect(find.text('••••••'), findsOneWidget);
      await tester.tap(find.text('Análisis').first);
      await tester.pumpAndSettle();
      expect(find.text('Sin gastos en este periodo'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('IA Chat').first);
      await tester.pumpAndSettle();
      expect(find.text('Próximamente'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Ajustes').first);
      await tester.pumpAndSettle();
      expect(find.text('Configuración'), findsOneWidget);
    });
  }
}
