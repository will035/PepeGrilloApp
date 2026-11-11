import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/money.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/dashboard_widgets.dart';

class AnalysisScreen extends ConsumerWidget {
  const AnalysisScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        appBar: AppBar(title: const Text('Análisis')),
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
                child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Conoce a dónde va tu dinero.',
                              style:
                                  Theme.of(context).textTheme.headlineMedium),
                          const SizedBox(height: 10),
                          const Text(
                              'Consulta los gastos por categoría. Las quincenas corresponden al mes actual.'),
                          const SizedBox(height: 24),
                          Wrap(spacing: 8, runSpacing: 8, children: [
                            for (final entry in {
                              DateFilterType.all: 'Todo el historial',
                              DateFilterType.firstQuincena: '1.ª quincena',
                              DateFilterType.secondQuincena: '2.ª quincena'
                            }.entries)
                              ChoiceChip(
                                  label: Text(entry.value),
                                  selected: ref.watch(dateFilterProvider) ==
                                      entry.key,
                                  onSelected: (_) => ref
                                      .read(dateFilterProvider.notifier)
                                      .setFilter(entry.key)),
                          ]),
                          const SizedBox(height: 24),
                          SoftCard(
                              child: ref.watch(expensesByCategoryProvider).when(
                                  data: (entries) {
                                    if (entries.isEmpty) {
                                      return const SizedBox(
                                          width: double.infinity,
                                          child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 36),
                                              child: Column(children: [
                                                Icon(
                                                    Icons
                                                        .pie_chart_outline_rounded,
                                                    size: 44,
                                                    color:
                                                        AppTheme.primaryColor),
                                                SizedBox(height: 16),
                                                Text(
                                                    'Sin gastos en este periodo')
                                              ])));
                                    }
                                    const colors = [
                                      AppTheme.primaryColor,
                                      AppTheme.green,
                                      Color(0xFFE9A04A),
                                      AppTheme.red,
                                      Color(0xFF65A8D7)
                                    ];
                                    return Column(children: [
                                      const Text('Gastos por categoría',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700)),
                                      const SizedBox(height: 24),
                                      SizedBox(
                                          height: 210,
                                          child: PieChart(PieChartData(
                                              centerSpaceRadius: 64,
                                              sectionsSpace: 4,
                                              sections: [
                                                for (var i = 0;
                                                    i < entries.length;
                                                    i++)
                                                  PieChartSectionData(
                                                      value: entries[i]
                                                          .totalAmount
                                                          .toDouble(),
                                                      color: colors[
                                                          i % colors.length],
                                                      showTitle: false,
                                                      radius: 32)
                                              ]))),
                                      const SizedBox(height: 20),
                                      for (var i = 0; i < entries.length; i++)
                                        Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8),
                                            child: Row(children: [
                                              Container(
                                                  width: 9,
                                                  height: 9,
                                                  decoration: BoxDecoration(
                                                      color: colors[
                                                          i % colors.length],
                                                      shape: BoxShape.circle)),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                  child: Text(
                                                      entries[i].categoryName)),
                                              const SizedBox(width: 12),
                                              Flexible(
                                                  child: Text(
                                                      Money.format(entries[i]
                                                          .totalAmount),
                                                      textAlign: TextAlign.end,
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600)))
                                            ])),
                                    ]);
                                  },
                                  loading: () => const Center(
                                      child: CircularProgressIndicator()),
                                  error: (_, __) => const Text(
                                      'No se pudo cargar el análisis.'))),
                        ])))),
      );
}
