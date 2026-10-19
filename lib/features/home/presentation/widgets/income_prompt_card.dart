import 'package:flutter/material.dart';

import '../../../../shared/navigation/app_routes.dart';
import '../../../../shared/widgets/app_card.dart';

/// Aviso cuando aún no se definió el sueldo mensual.
class IncomePromptCard extends StatelessWidget {
  const IncomePromptCard({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Define tu sueldo mensual', style: textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            'Con tu sueldo la app reparte el dinero en 50/25/15/10.',
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: () =>
                Navigator.of(context).pushReplacementNamed(AppRoutes.incomes),
            child: const Text('Ir a Ingresos'),
          ),
        ],
      ),
    );
  }
}
