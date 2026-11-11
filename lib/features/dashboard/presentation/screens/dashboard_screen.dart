import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/dashboard_provider.dart';
import '../widgets/dashboard_widgets.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Buenos días,'
        : hour < 19
            ? 'Buenas tardes,'
            : 'Buenas noches,';
    return SafeArea(child: LayoutBuilder(builder: (context, constraints) {
      final wide = constraints.maxWidth >= 850;
      return SingleChildScrollView(
          child: Center(
              child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1160),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        wide ? 48 : 24, 32, wide ? 48 : 24, 32),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Text(greeting,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                          fontSize: 13)),
                                  const SizedBox(height: 4),
                                  Text('Tu dinero, en calma.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium),
                                ])),
                            const SizedBox(width: 12),
                            IconButton.filledTonal(
                                tooltip: 'Configuración',
                                onPressed: () => context.go('/settings'),
                                style: IconButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.surface,
                                    minimumSize: const Size(46, 46)),
                                icon: const Icon(Icons.person_outline_rounded))
                          ]),
                          const SizedBox(height: 30),
                          if (wide)
                            Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Expanded(
                                      flex: 5,
                                      child: Column(children: [
                                        BalanceCard(),
                                        SizedBox(height: 24),
                                        AdvisorCard()
                                      ])),
                                  const SizedBox(width: 28),
                                  Expanded(
                                      flex: 6, child: _recent(context, ref)),
                                ])
                          else ...[
                            const BalanceCard(),
                            const SizedBox(height: 24),
                            const AdvisorCard(),
                            const SizedBox(height: 30),
                            _recent(context, ref)
                          ],
                          const SizedBox(height: 28),
                          Center(
                              child: Text('Un poco de claridad, cada día.',
                                  style:
                                      Theme.of(context).textTheme.bodySmall)),
                        ]),
                  ))));
    }));
  }

  Widget _recent(BuildContext context, WidgetRef ref) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: Text('Movimientos recientes',
                  style: Theme.of(context).textTheme.titleMedium)),
          TextButton(
              onPressed: () => context.push('/transactions'),
              child: const Text('Ver todos',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)))
        ]),
        const SizedBox(height: 8),
        SoftCard(
            padding: const EdgeInsets.all(8),
            child: ref.watch(movementPageProvider(0)).when(
                  data: (entries) => entries.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 32),
                          child: Column(children: [
                            Icon(Icons.receipt_long_outlined,
                                color: Theme.of(context).colorScheme.primary,
                                size: 32),
                            const SizedBox(height: 12),
                            const Text('Tu historia empieza aquí',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            const Text(
                                'Registra tu primer ingreso o gasto para empezar a conocer tus hábitos.',
                                textAlign: TextAlign.center),
                            const SizedBox(height: 14),
                            TextButton.icon(
                                onPressed: () => context.push('/add'),
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('Crear mi primer registro')),
                          ]))
                      : Column(children: [
                          for (final entry in entries.take(5))
                            MovementTile(entry: entry)
                        ]),
                  loading: () => const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator())),
                  error: (_, __) => Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(children: [
                        const Text('No pudimos cargar los movimientos.'),
                        TextButton(
                            onPressed: () =>
                                ref.invalidate(movementPageProvider(0)),
                            child: const Text('Reintentar'))
                      ])),
                )),
      ]);
}
