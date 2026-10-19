import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../budget/domain/budget_bucket.dart';

/// Tarjeta de una porción del presupuesto: cuánto queda de su porcentaje.
class BucketCard extends StatelessWidget {
  const BucketCard({
    super.key,
    required this.bucket,
    required this.income,
    required this.shade,
  });

  final BudgetBucket bucket;
  final double income;
  final Color shade;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final remaining = bucket.remaining(income);
    final ratio = bucket.usedRatio(income);
    final exceeded = remaining < 0;
    final nearLimit = !exceeded && ratio >= 0.9;
    final amountColor = exceeded
        ? AppColors.danger
        : nearLimit
            ? AppColors.warning
            : AppColors.text;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: shade, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(bucket.name, style: textTheme.titleMedium),
              ),
              Text('${bucket.percent}%', style: textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            formatMoney(remaining.abs()),
            style: textTheme.titleLarge?.copyWith(
              color: amountColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            exceeded ? 'excedido' : 'restante',
            style: textTheme.bodySmall?.copyWith(
              color: exceeded ? AppColors.danger : AppColors.muted,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: AppColors.surfaceAlt,
              valueColor: AlwaysStoppedAnimation(
                exceeded ? AppColors.danger : shade,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Gastado ${formatMoney(bucket.spent)} de ${formatMoney(bucket.allocated(income))}',
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Text(bucket.description, style: textTheme.bodySmall),
        ],
      ),
    );
  }
}
