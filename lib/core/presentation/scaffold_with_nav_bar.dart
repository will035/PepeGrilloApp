import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({required this.child, super.key});
  final Widget child;
  static const _routes = ['/', '/analysis', '/advisor', '/settings'];
  static const _labels = ['Inicio', 'Análisis', 'IA Chat', 'Ajustes'];
  static const _icons = [
    Icons.home_outlined,
    Icons.pie_chart_outline_rounded,
    Icons.auto_awesome_outlined,
    Icons.settings_outlined
  ];

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final index = _routes.indexOf(path);
    final selected = index < 0 ? 0 : index;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyN, control: true): () =>
            context.push('/add'),
        const SingleActivator(LogicalKeyboardKey.keyN, meta: true): () =>
            context.push('/add')
      },
      child: Focus(
          autofocus: true,
          child: LayoutBuilder(builder: (context, constraints) {
            final wide =
                constraints.maxWidth >= 840 && constraints.maxHeight >= 620;
            return Scaffold(
              body: Row(children: [
                if (wide)
                  Container(
                      width: 224,
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          border: Border(
                              right: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outlineVariant))),
                      child: Material(
                          color: Theme.of(context).colorScheme.surface,
                          child: SafeArea(
                              child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 32),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(children: [
                                          Icon(Icons.auto_awesome,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary),
                                          const SizedBox(width: 10),
                                          const Text('PepeGrillo',
                                              style: TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: -1))
                                        ]),
                                        const SizedBox(height: 6),
                                        const Text('Tu dinero, con claridad.',
                                            style: TextStyle(fontSize: 11)),
                                        const SizedBox(height: 44),
                                        for (var i = 0; i < 4; i++)
                                          Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 8),
                                              child: ListTile(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              14)),
                                                  selected: i == index,
                                                  selectedTileColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .primary
                                                          .withValues(
                                                              alpha: .09),
                                                  leading: Icon(_icons[i]),
                                                  title: Text(_labels[i],
                                                      style: const TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w600)),
                                                  onTap: () =>
                                                      context.go(_routes[i]))),
                                        ListTile(
                                            leading: const Icon(
                                                Icons.event_repeat_outlined),
                                            title: const Text('Suscripciones',
                                                style: TextStyle(fontSize: 13)),
                                            onTap: () =>
                                                context.go('/subscriptions')),
                                        const Spacer(),
                                        SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton.icon(
                                                onPressed: () =>
                                                    context.push('/add'),
                                                icon: const Icon(Icons.add,
                                                    size: 18),
                                                label: const Text(
                                                    'Nuevo registro'))),
                                        const SizedBox(height: 18),
                                        const Row(children: [
                                          Icon(Icons.lock_outline, size: 13),
                                          SizedBox(width: 6),
                                          Text('Tus datos, en tu dispositivo',
                                              style: TextStyle(fontSize: 10))
                                        ]),
                                      ]))))),
                Expanded(child: child),
              ]),
              bottomNavigationBar: wide
                  ? null
                  : Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          border: Border(
                              top: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outlineVariant))),
                      child: SafeArea(
                          top: false,
                          child: SizedBox(
                              height: 80,
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _nav(context, 0, selected),
                                    _nav(context, 1, selected),
                                    Tooltip(
                                        message: 'Nuevo registro',
                                        child: SizedBox(
                                            width: 56,
                                            height: 56,
                                            child: FloatingActionButton(
                                                heroTag: 'addMovement',
                                                shape: const CircleBorder(),
                                                onPressed: () =>
                                                    context.push('/add'),
                                                child: const Icon(
                                                    Icons.add_rounded,
                                                    size: 29)))),
                                    _nav(context, 2, selected),
                                    _nav(context, 3, selected),
                                  ]))),
                    ),
            );
          })),
    );
  }

  Widget _nav(BuildContext context, int index, int selected) {
    final color = index == selected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurfaceVariant;
    return Expanded(
        child: Semantics(
            selected: index == selected,
            child: InkWell(
                onTap: () => context.go(_routes[index]),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_icons[index], color: color, size: 24),
                      const SizedBox(height: 5),
                      Text(_labels[index],
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: color)),
                    ]))));
  }
}
