import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_feedback.dart';
import '../data/income_repository.dart';
import '../domain/income_change.dart';
import 'edit_income_sheet.dart';
import 'income_dialogs.dart';

/// Tarjeta de Ajustes con el sueldo actual y el botón para cambiarlo.
class IncomeCard extends StatefulWidget {
  const IncomeCard({super.key, required this.repository});

  final IncomeRepository repository;

  @override
  State<IncomeCard> createState() => _IncomeCardState();
}

class _IncomeCardState extends State<IncomeCard> {
  late Future<IncomeOverview> _overview = widget.repository.overview();

  void _reload() {
    // Ojo: el callback de setState no debe devolver un Future (llevaría a un error).
    setState(() {
      _overview = widget.repository.overview();
    });
  }

  Future<void> _edit(IncomeOverview overview) async {
    final amount = await showEditIncomeSheet(
      context,
      initial: overview.currentIncome,
    );
    if (amount == null || !mounted) return;

    // Si el mes ya tiene gastos, hay que saber desde cuándo rige el cambio.
    var effect = IncomeEffect.thisMonth;
    if (overview.hasTransactions) {
      final chosen = await showIncomeEffectDialog(context);
      if (chosen == null || !mounted) return;
      effect = chosen;
    }

    try {
      final result = await widget.repository.setIncome(amount, effect: effect);
      if (!mounted) return;
      _reload();
      showFeedback(
        context,
        effect == IncomeEffect.nextMonth
            ? 'Sueldo definido para el próximo mes'
            : 'Sueldo definido',
      );
      if (result.overspends.isNotEmpty) {
        await showOverspendDialog(context, result.overspends);
      }
    } catch (_) {
      if (mounted) {
        showFeedback(context, 'Error en la definición del sueldo', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return FutureBuilder<IncomeOverview>(
      future: _overview,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return AppCard(
            child: Text(
              'Error al cargar el sueldo',
              style: textTheme.bodySmall?.copyWith(color: AppColors.danger),
            ),
          );
        }
        final overview = snapshot.data;
        if (overview == null) {
          return const AppCard(
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final pending = overview.pendingNextMonthIncome;
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Este mes', style: textTheme.bodySmall),
              const SizedBox(height: 6),
              Text(
                overview.currentIncome == 0
                    ? 'Sin definir'
                    : formatMoney(overview.currentIncome),
                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500),
              ),
              if (pending != null) ...[
                const SizedBox(height: 10),
                Text(
                  'Próximo mes: ${formatMoney(pending)}',
                  style: textTheme.bodySmall?.copyWith(color: AppColors.warning),
                ),
              ],
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => _edit(overview),
                child: Text(
                  overview.currentIncome == 0 ? 'Definir sueldo' : 'Cambiar sueldo',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
