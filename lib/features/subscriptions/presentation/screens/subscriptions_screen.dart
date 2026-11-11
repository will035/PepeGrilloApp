import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/money.dart';
import '../../../../core/repositories/finance_repository.dart';

import '../../../../core/providers/database_provider.dart';

class SubscriptionsScreen extends ConsumerWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionsAsync = ref.watch(subscriptionsListProvider);
    final repository = ref.watch(financeRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagos y Suscripciones'),
      ),
      body: Center(
          child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: subscriptionsAsync.when(
                data: (subscriptions) {
                  final total = subscriptions.fold<int>(
                      0, (sum, s) => sum + s.amountCents);

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Card(
                          color: Theme.of(context).colorScheme.surface,
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                Text(
                                  'Total Fijo Mensual',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  Money.format(total),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: subscriptions.isEmpty
                            ? const Center(
                                child:
                                    Text('No hay suscripciones registradas.'))
                            : ListView.builder(
                                itemCount: subscriptions.length,
                                itemBuilder: (context, index) {
                                  final s = subscriptions[index];
                                  return Dismissible(
                                    key: ValueKey(s.id),
                                    direction: DismissDirection.endToStart,
                                    background: Container(
                                      color: Colors.red,
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.only(right: 20),
                                      child: const Icon(Icons.delete,
                                          color: Colors.white),
                                    ),
                                    confirmDismiss: (_) async {
                                      try {
                                        await repository
                                            .deleteSubscription(s.id);
                                        return true;
                                      } catch (_) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  content: Text(
                                                      'No se pudo eliminar la suscripción.')));
                                        }
                                        return false;
                                      }
                                    },
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        child: Text(s.name
                                            .substring(0, 1)
                                            .toUpperCase()),
                                      ),
                                      title: Text(s.name),
                                      subtitle: Text(
                                          'Se cobra el día ${s.billingDay}'),
                                      trailing: Text(
                                        Money.format(s.amountCents),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Error: $e')),
              ))),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog<void>(
            context: context,
            builder: (_) => _AddSubscriptionDialog(repository: repository)),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AddSubscriptionDialog extends StatefulWidget {
  const _AddSubscriptionDialog({required this.repository});
  final FinanceRepository repository;

  @override
  State<_AddSubscriptionDialog> createState() => _AddSubscriptionDialogState();
}

class _AddSubscriptionDialogState extends State<_AddSubscriptionDialog> {
  final _name = TextEditingController();
  final _amount = TextEditingController();
  final _day = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    _day.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final day = int.tryParse(_day.text.trim());
      if (day == null) {
        throw const FormatException('Ingresa un día de cobro válido.');
      }
      await widget.repository
          .addSubscription(_name.text, _amount.text, day, '#FF0000');
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        setState(() => _error = error is FormatException
            ? error.message
            : 'No se pudo guardar. Intenta de nuevo.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: !_saving,
        child: AlertDialog(
          title: const Text('Nueva Suscripción'),
          content: SingleChildScrollView(
              child: AbsorbPointer(
            absorbing: _saving,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                  controller: _name,
                  maxLength: 50,
                  decoration: const InputDecoration(labelText: 'Nombre')),
              const SizedBox(height: 8),
              TextField(
                  controller: _amount,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                      labelText: 'Monto en MXN',
                      helperText: 'Máximo 2 decimales, sin redondeo')),
              const SizedBox(height: 8),
              TextField(
                  controller: _day,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'Día de cobro (1–31)')),
              if (_error != null)
                Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(_error!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error))),
            ]),
          )),
          actions: [
            TextButton(
                onPressed: _saving ? null : () => Navigator.pop(context),
                child: const Text('Cancelar')),
            TextButton(
                onPressed: _saving ? null : _save,
                child: Text(_saving ? 'Guardando…' : 'Guardar')),
          ],
        ),
      );
}
