import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/database.dart';
import '../../../../core/providers/database_provider.dart';

class QuickAddScreen extends ConsumerStatefulWidget {
  const QuickAddScreen({super.key});

  @override
  ConsumerState<QuickAddScreen> createState() => _QuickAddScreenState();
}

class _QuickAddScreenState extends ConsumerState<QuickAddScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isSaving = false;
  String _type = 'expense';
  int? _selectedCategoryId;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveTransaction() async {
    if (_isSaving) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una categoría')),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      await ref.read(financeRepositoryProvider).addTransaction(
            amountText: _amountController.text,
            type: _type,
            categoryId: _selectedCategoryId!,
            date: DateTime.now(),
            note: _noteController.text,
          );
      if (mounted) context.pop();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
          error is FormatException
              ? error.message
              : 'No se pudo guardar. Tus datos no se modificaron; intenta de nuevo.',
        )));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Registro'),
      ),
      body: Center(
          child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: AbsorbPointer(
                absorbing: _isSaving,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                              value: 'expense',
                              label: Text('Gasto'),
                              icon: Icon(Icons.arrow_upward)),
                          ButtonSegment(
                              value: 'income',
                              label: Text('Ingreso'),
                              icon: Icon(Icons.arrow_downward)),
                        ],
                        selected: {_type},
                        onSelectionChanged: (Set<String> newSelection) {
                          setState(() {
                            _type = newSelection.first;
                            _selectedCategoryId =
                                null; // Reset category on type change
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        style: const TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          prefixText: '\$ ',
                          helperText: 'MXN · máximo 2 decimales',
                          hintText: '0.00',
                          border: InputBorder.none,
                          filled: false,
                        ),
                        autofocus: true,
                      ),
                      const SizedBox(height: 24),
                      const Text('Categoría',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Expanded(
                        child: FutureBuilder<List<Category>>(
                          // Use a key to force FutureBuilder to reload if needed, but setState rebuilds it anyway.
                          future: (db.select(db.categories)
                                ..where((c) => c.type.equals(_type)))
                              .get(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return const Center(
                                  child: Text(
                                      'No se pudieron cargar las categorías.'));
                            }
                            if (!snapshot.hasData) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            final categories = snapshot.data!;

                            return GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio: 1.5,
                              ),
                              itemCount: categories.length + 1,
                              itemBuilder: (context, index) {
                                if (index == categories.length) {
                                  return InkWell(
                                    onTap: () async {
                                      final newCategoryName =
                                          await showDialog<String>(
                                        context: context,
                                        builder: (_) =>
                                            const _CategoryNameDialog(),
                                      );
                                      if (!mounted) return;
                                      if (newCategoryName != null &&
                                          newCategoryName.isNotEmpty) {
                                        try {
                                          final newId = await ref
                                              .read(financeRepositoryProvider)
                                              .addCategory(newCategoryName,
                                                  _type, 'category');
                                          if (!mounted) return;
                                          setState(() =>
                                              _selectedCategoryId = newId);
                                        } catch (error) {
                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: Text(error
                                                          is FormatException
                                                      ? error.message
                                                      : 'No se pudo crear la categoría.')));
                                        }
                                      }
                                    },
                                    child: Card(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHighest,
                                      child: const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add),
                                          Text('Nueva'),
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                final category = categories[index];
                                final isSelected =
                                    _selectedCategoryId == category.id;
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedCategoryId = category.id;
                                    });
                                  },
                                  child: Card(
                                    color: isSelected
                                        ? Theme.of(context)
                                            .colorScheme
                                            .primaryContainer
                                        : null,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                            Icons
                                                .category, // Simplified for MVP
                                            color: isSelected
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer
                                                : null),
                                        Text(category.name),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      TextField(
                        controller: _noteController,
                        decoration: const InputDecoration(
                          hintText: 'Nota (Opcional)',
                          prefixIcon: Icon(Icons.note),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _isSaving ? null : _saveTransaction,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(_isSaving ? 'GUARDANDO…' : 'GUARDAR',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ))),
    );
  }
}

class _CategoryNameDialog extends StatefulWidget {
  const _CategoryNameDialog();
  @override
  State<_CategoryNameDialog> createState() => _CategoryNameDialogState();
}

class _CategoryNameDialogState extends State<_CategoryNameDialog> {
  final _controller = TextEditingController();
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Nueva Categoría'),
        content: TextField(
            controller: _controller,
            maxLength: 50,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Nombre de categoría')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(context, _controller.text),
              child: const Text('Guardar')),
        ],
      );
}
