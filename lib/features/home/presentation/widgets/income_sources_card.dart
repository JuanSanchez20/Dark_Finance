import 'package:flutter/material.dart';

import '../../../../core/utils/money_formatter.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../domain/income_source.dart';

/// De dónde salen los ingresos del mes (sueldo base y extras).
class IncomeSourcesCard extends StatelessWidget {
  const IncomeSourcesCard({super.key, required this.sources});

  final List<IncomeSource> sources;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      child: Column(
        children: [
          for (var i = 0; i < sources.length; i++) ...[
            if (i > 0) const Divider(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    sources[i].label,
                    style: textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(formatMoney(sources[i].amount), style: textTheme.bodyMedium),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
