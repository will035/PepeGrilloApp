import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/domain/money.dart';
import '../../../../core/providers/dashboard_provider.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/theme/app_theme.dart';

class SoftCard extends StatelessWidget {
  const SoftCard(
      {required this.child,
      this.padding = const EdgeInsets.all(24),
      super.key});
  final Widget child;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: .025),
                  blurRadius: 30,
                  offset: const Offset(0, 8))
            ]),
        child: child,
      );
}

class BalanceCard extends ConsumerStatefulWidget {
  const BalanceCard({super.key});
  @override
  ConsumerState<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends ConsumerState<BalanceCard> {
  bool _visible = true;
  @override
  Widget build(BuildContext context) {
    final balance = ref.watch(totalBalanceProvider);
    final totals = ref.watch(monthlyTotalsProvider);
    final theme = Theme.of(context);
    return SoftCard(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
                child: Text('Balance total',
                    style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500))),
            IconButton(
                tooltip: _visible ? 'Ocultar importes' : 'Mostrar importes',
                onPressed: () => setState(() => _visible = !_visible),
                icon: Icon(
                    _visible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 21))
          ]),
          balance.when(
              data: (value) => Semantics(
                  label: _visible
                      ? 'Balance total: ${Money.format(value)}'
                      : 'Balance oculto',
                  child: ExcludeSemantics(
                      child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                              _visible
                                  ? Money.format(value).replaceFirst(' MXN', '')
                                  : '••••••',
                              style: theme.textTheme.headlineLarge)))),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('No se pudo cargar el saldo.')),
          const SizedBox(height: 6),
          Text('Pesos mexicanos · MXN', style: theme.textTheme.bodySmall),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 18),
          Text('ESTE MES',
              style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 9,
                  letterSpacing: 1.6,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          totals.when(
              data: (values) => Row(children: [
                    Expanded(
                        child: _metric(context, 'Ingresos', values.income,
                            AppTheme.green, Icons.south_west_rounded)),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _metric(context, 'Gastos', values.expenses,
                            AppTheme.red, Icons.north_east_rounded)),
                  ]),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('No se pudo cargar el resumen.')),
        ]));
  }

  Widget _metric(BuildContext context, String label, int cents, Color color,
          IconData icon) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  color: color.withValues(alpha: .1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 12)),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.bodySmall)
        ]),
        const SizedBox(height: 8),
        FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
                _visible
                    ? Money.format(cents).replaceFirst(' MXN', '')
                    : '••••',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600))),
      ]);
}

class AdvisorCard extends ConsumerWidget {
  const AdvisorCard({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final subscriptions = ref.watch(subscriptionsListProvider);
    return Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: .1)),
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.surface,
                  theme.brightness == Brightness.dark
                      ? const Color(0xFF272938)
                      : const Color(0xFFF1F5F9)
                ])),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(15)),
              child: const Icon(Icons.auto_awesome,
                  color: Colors.white, size: 23)),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text('Tu copiloto financiero',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 13)),
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: .1),
                              borderRadius: BorderRadius.circular(20)),
                          child: Text('IA · PRÓXIMAMENTE',
                              style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: .7)))
                    ]),
                const SizedBox(height: 10),
                subscriptions.when(
                    data: (rows) => Text(
                        rows.isEmpty
                            ? 'Dale claridad a tus gastos fijos. Agrega tus suscripciones y consulta cuánto destinas a ellas cada mes.'
                            : 'Tienes ${rows.length} suscripciones registradas por ${Money.format(rows.fold<int>(0, (total, row) => total + row.amountCents))} al mes. Puedes revisarlas aquí.',
                        style: TextStyle(
                            fontSize: 12,
                            height: 1.7,
                            color: theme.colorScheme.onSurfaceVariant)),
                    loading: () => const Text('Consultando tus suscripciones…'),
                    error: (_, __) => const Text(
                        'Consulta y organiza tus pagos recurrentes.')),
                const SizedBox(height: 6),
                TextButton(
                    onPressed: () => context.push('/subscriptions'),
                    style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerLeft),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Flexible(
                          child: Text('Revisar suscripciones',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600))),
                      SizedBox(width: 4),
                      Icon(Icons.chevron_right, size: 17)
                    ])),
              ])),
        ]));
  }
}

class MovementTile extends ConsumerWidget {
  const MovementTile({required this.entry, super.key});
  final MovementEntry entry;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = entry.movement;
    final income = t.type == 'income';
    final color = income ? AppTheme.green : const Color(0xFFE99B3D);
    final icon = switch (entry.category.iconName) {
      'restaurant' => Icons.shopping_basket_outlined,
      'directions_car' => Icons.directions_car_outlined,
      'work' => Icons.work_outline_rounded,
      _ => Icons.category_outlined
    };
    final date = t.date.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    final label = day == today
        ? 'Hoy'
        : day == DateTime(now.year, now.month, now.day - 1)
            ? 'Ayer'
            : '${date.day}/${date.month}/${date.year}';
    return InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _details(context, ref),
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            child: Row(children: [
              Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                      color: color.withValues(alpha: .09),
                      shape: BoxShape.circle),
                  child: Icon(icon, color: color, size: 21)),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(t.note ?? entry.category.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('$label · ${entry.account.name}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontSize: 10)),
                  ])),
              const SizedBox(width: 8),
              Flexible(
                  fit: FlexFit.tight,
                  child: Text(
                      '${income ? '+' : '-'}${Money.format(t.amountCents).replaceFirst(' MXN', '')}',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: income ? AppTheme.green : null))),
            ])));
  }

  Future<void> _details(BuildContext context, WidgetRef ref) async {
    final repository = ref.read(financeRepositoryProvider);
    final remove = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
                title: Text(entry.category.name),
                content: Text(
                    '${Money.format(entry.movement.amountCents)}\n${entry.account.name}\n${entry.movement.note ?? ''}\n\n¿Deseas eliminar este movimiento? Se actualizará el saldo.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cerrar')),
                  TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Eliminar',
                          style: TextStyle(color: AppTheme.red)))
                ]));
    if (remove != true) return;
    try {
      await repository.deleteTransaction(entry.movement.id);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('No se pudo eliminar el movimiento.')));
      }
    }
  }
}
