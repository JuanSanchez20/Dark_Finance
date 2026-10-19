import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../budget/domain/budget_bucket.dart';

/// Barra segmentada 50/25/15/10. Cada tramo muestra cuánto de su porción se ha usado.
class DistributionBar extends StatelessWidget {
  const DistributionBar({
    super.key,
    required this.buckets,
    required this.income,
  });

  final List<BudgetBucket> buckets;
  final double income;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (var i = 0; i < buckets.length; i++) ...[
              if (i > 0) const SizedBox(width: 4),
              Expanded(
                flex: buckets[i].percent,
                child: _Segment(
                  color: AppColors.bucketShades[i % AppColors.bucketShades.length],
                  ratio: buckets[i].usedRatio(income),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (var i = 0; i < buckets.length; i++) ...[
              if (i > 0) const SizedBox(width: 4),
              Expanded(
                flex: buckets[i].percent,
                child: Text(
                  '${buckets[i].percent}%',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.color, required this.ratio});

  final Color color;
  final double ratio;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 12,
        color: color.withValues(alpha: 0.18),
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: ratio.clamp(0.0, 1.0),
          child: Container(color: ratio > 1 ? AppColors.danger : color),
        ),
      ),
    );
  }
}
