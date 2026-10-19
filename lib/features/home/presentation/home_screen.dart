import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/navigation/app_routes.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/section_title.dart';
import '../data/home_summary_repository.dart';
import '../domain/home_summary.dart';
import 'widgets/balance_hero.dart';
import 'widgets/bucket_card.dart';
import 'widgets/distribution_bar.dart';
import 'widgets/income_prompt_card.dart';
import 'widgets/income_sources_card.dart';
import 'widgets/recent_transactions_card.dart';

/// Pantalla de Resumen. Solo arma el layout; cada bloque vive en `widgets/`.
/// Desliza hacia abajo para recargar.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.repository});

  final HomeSummaryRepository repository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<HomeSummary> _summary = widget.repository.load();

  Future<void> _refresh() async {
    final next = widget.repository.load();
    setState(() {
      _summary = next;
    });
    try {
      await next;
    } catch (_) {
      // El error se muestra en pantalla desde el FutureBuilder.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resumen')),
      drawer: const AppDrawer(currentRoute: AppRoutes.home),
      body: FutureBuilder<HomeSummary>(
        future: _summary,
        builder: (context, snapshot) {
          final summary = snapshot.data;
          if (summary == null) {
            if (snapshot.hasError) {
              return Center(child: Text('No se pudo cargar: ${snapshot.error}'));
            }
            return const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: _HomeContent(summary: summary),
          );
        },
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.summary});

  final HomeSummary summary;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        if (summary.totalIncome == 0) ...[
          const IncomePromptCard(),
          const SizedBox(height: 24),
        ],
        BalanceHero(summary: summary),
        if (summary.incomeSources.length > 1) ...[
          const SectionTitle('De dónde salen tus ingresos'),
          IncomeSourcesCard(sources: summary.incomeSources),
        ],
        const SectionTitle('Distribución del ingreso'),
        DistributionBar(
          buckets: summary.buckets,
          income: summary.totalIncome,
        ),
        const SizedBox(height: 20),
        for (var i = 0; i < summary.buckets.length; i++) ...[
          BucketCard(
            bucket: summary.buckets[i],
            income: summary.totalIncome,
            shade: AppColors.bucketShades[i % AppColors.bucketShades.length],
          ),
          const SizedBox(height: 12),
        ],
        const SectionTitle('Últimos gastos'),
        RecentTransactionsCard(summary: summary),
      ],
    );
  }
}
