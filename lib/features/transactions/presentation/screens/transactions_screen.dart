import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/dashboard_provider.dart';
import '../../../dashboard/presentation/widgets/dashboard_widgets.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});
  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  int _page = 0;
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Tus movimientos')),
      body: ref.watch(movementPageProvider(_page)).when(
            data: (entries) => Center(
                child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Column(children: [
                      Expanded(
                          child: entries.isEmpty
                              ? const Center(
                                  child: Text(
                                      'No hay movimientos en esta página.'))
                              : ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount:
                                      entries.length > 20 ? 20 : entries.length,
                                  itemBuilder: (_, i) =>
                                      MovementTile(entry: entries[i]))),
                      SafeArea(
                          top: false,
                          child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                        tooltip: 'Página anterior',
                                        onPressed: _page == 0
                                            ? null
                                            : () => setState(() => _page--),
                                        icon: const Icon(Icons.chevron_left)),
                                    Text('Página ${_page + 1}'),
                                    IconButton(
                                        tooltip: 'Página siguiente',
                                        onPressed: entries.length <= 20
                                            ? null
                                            : () => setState(() => _page++),
                                        icon: const Icon(Icons.chevron_right)),
                                  ]))),
                    ]))),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => Center(
                child: TextButton(
                    onPressed: () =>
                        ref.invalidate(movementPageProvider(_page)),
                    child: const Text('Reintentar'))),
          ));
}
