import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../domain/home_summary.dart';

/// Cabecera del Resumen: cuánto dinero queda disponible este mes.
class BalanceHero extends StatelessWidget {
  const BalanceHero({super.key, required this.summary});

  final HomeSummary summary;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final status = _status(summary);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('DISPONIBLE ESTE MES', style: textTheme.labelSmall),
        const SizedBox(height: 8),
        Text(formatMoney(summary.available), style: textTheme.displaySmall),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              'Día ${summary.daysElapsed} de ${summary.daysInMonth}',
              style: textTheme.bodySmall,
            ),
            if (status != null) ...[
              const SizedBox(width: 12),
              Text(
                status.label,
                style: textTheme.bodySmall?.copyWith(color: status.color),
              ),
            ],
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _Figure(
                label: 'Ingresos del mes',
                value: formatMoney(summary.totalIncome),
                color: AppColors.income,
              ),
            ),
            Expanded(
              child: _Figure(
                label: 'Gastado',
                value: formatMoney(summary.totalSpent),
                color: AppColors.text,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Cómo vas según lo gastado frente a lo ganado. Null si aún no hay ingresos.
  _Status? _status(HomeSummary summary) {
    if (summary.totalIncome == 0) return null;
    final ratio = summary.spentRatio;
    if (ratio >= 1) return const _Status('Te pasaste de tus ingresos', AppColors.danger);
    if (ratio >= 0.75) return const _Status('Cuidado: queda poco', AppColors.warning);
    return const _Status('Vas bien', AppColors.income);
  }
}

class _Status {
  const _Status(this.label, this.color);

  final String label;
  final Color color;
}

class _Figure extends StatelessWidget {
  const _Figure({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          value,
          style: textTheme.titleMedium?.copyWith(color: color),
        ),
      ],
    );
  }
}
