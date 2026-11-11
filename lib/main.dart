import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'core/presentation/scaffold_with_nav_bar.dart';
import 'features/dashboard/presentation/screens/analysis_screen.dart';
import 'features/dashboard/presentation/screens/advisor_screen.dart';
import 'features/settings/presentation/screens/settings_screen.dart';
import 'features/subscriptions/presentation/screens/subscriptions_screen.dart';
import 'features/transactions/presentation/screens/transactions_screen.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'features/transactions/presentation/screens/quick_add_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: PepeGrilloApp()));
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
        builder: (context, state, child) => ScaffoldWithNavBar(child: child),
        routes: [
          GoRoute(
              path: '/', builder: (context, state) => const DashboardScreen()),
          GoRoute(
              path: '/analysis',
              builder: (context, state) => const AnalysisScreen()),
          GoRoute(
              path: '/advisor',
              builder: (context, state) => const AdvisorScreen()),
          GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen()),
          GoRoute(
              path: '/subscriptions',
              builder: (context, state) => const SubscriptionsScreen()),
          GoRoute(
              path: '/transactions',
              builder: (context, state) => const TransactionsScreen()),
        ]),
    GoRoute(
      path: '/add',
      builder: (context, state) => const QuickAddScreen(),
    ),
  ],
);

class PepeGrilloApp extends StatelessWidget {
  const PepeGrilloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PepeGrillo',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
