import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/dashboard_widgets.dart';

class AdvisorScreen extends StatelessWidget {
  const AdvisorScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('PepeGrillo IA')),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
              child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: SoftCard(
                      child: Column(children: [
                    Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: .1),
                            borderRadius: BorderRadius.circular(28)),
                        child: Icon(Icons.auto_awesome,
                            size: 40,
                            color: Theme.of(context).colorScheme.primary)),
                    const SizedBox(height: 24),
                    Text('Un copiloto para tu tranquilidad',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 16),
                    const Text('Próximamente',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    const Text(
                        'El chat y las recomendaciones con inteligencia artificial aún no están disponibles. Mientras tanto, puedes registrar tus movimientos, consultar tus gastos y organizar tus suscripciones.',
                        textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                        onPressed: () => context.push('/subscriptions'),
                        icon: const Icon(Icons.event_repeat),
                        label: const Text('Organizar suscripciones')),
                    const SizedBox(height: 20),
                    const Text('Tus registros permanecen en este dispositivo.',
                        textAlign: TextAlign.center),
                  ]))))));
}
