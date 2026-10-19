import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../domain/home_summary.dart';
import '../../domain/recent_transaction.dart';

class RecentTransactionsCard extends StatelessWidget {
  const RecentTransactionsCard({super.key, required this.summary});

  final HomeSummary summary;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final transactions = summary.recentTransactions;

    if (transactions.isEmpty) {
      return AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sin gastos registrados este mes', style: textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
              'Los movimientos aparecerán aquí',
              style: textTheme.bodySmall?.copyWith(color: AppColors.faint),
            ),
          ],
        ),
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < transactions.length; i++) ...[
            if (i > 0) const Divider(height: 20),
            _TransactionRow(transaction: transactions[i]),
          ],
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.transaction});

  final RecentTransaction transaction;

  String _formatDate(DateTime date) {
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final label = transaction.merchant ?? transaction.description;

    return Row(
      children: [
        Text(
          _formatDate(transaction.date),
          style: textTheme.bodySmall?.copyWith(color: AppColors.faint),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${transaction.categoryName} · ${transaction.bucketName}',
                style: textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          formatMoney(transaction.amount),
          style: textTheme.bodyMedium?.copyWith(color: AppColors.text),
        ),
      ],
    );
  }
}
