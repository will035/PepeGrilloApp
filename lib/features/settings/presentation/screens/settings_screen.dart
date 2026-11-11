import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/database_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: Center(
          child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Tus datos, siempre contigo',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.download),
                    title: const Text('Guardar un respaldo'),
                    subtitle: const Text(
                        'Exporta una copia de tus registros en formato JSON'),
                    onTap: () async {
                      try {
                        final jsonString = await db.exportToJson();
                        String? outputFile = await FilePicker.platform.saveFile(
                          dialogTitle: 'Exportar Respaldo',
                          fileName: 'pepegrillo_backup.json',
                          type: FileType.custom,
                          allowedExtensions: ['json'],
                        );

                        if (outputFile != null) {
                          final file = File(outputFile);
                          await file.writeAsString(jsonString);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Respaldo guardado en: $outputFile')),
                            );
                          }
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error al exportar: $e')),
                          );
                        }
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.upload),
                    title: const Text('Restaurar un respaldo'),
                    subtitle: const Text(
                        'Restaura tus datos desde un archivo. ¡Atención! Esto sobrescribirá los datos actuales.'),
                    onTap: () async {
                      // Confirm dialog first
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('¿Estás seguro?'),
                          content: const Text(
                              'Importar un respaldo reemplazará todos tus datos actuales. Esta acción no se puede deshacer.'),
                          actions: [
                            TextButton(
                                onPressed: () => context.pop(false),
                                child: const Text('Cancelar')),
                            TextButton(
                                onPressed: () => context.pop(true),
                                child: const Text('Importar',
                                    style: TextStyle(color: Colors.red))),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        try {
                          FilePickerResult? result =
                              await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['json'],
                          );

                          if (result != null &&
                              result.files.single.path != null) {
                            final file = File(result.files.single.path!);
                            final jsonString = await file.readAsString();
                            await db.importFromJson(jsonString);

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Respaldo restaurado con éxito')),
                              );
                            }
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error al importar: $e')),
                            );
                          }
                        }
                      }
                    },
                  ),
                ],
              ))),
    );
  }
}
