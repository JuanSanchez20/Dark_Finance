import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/money_formatter.dart';
import '../domain/income_change.dart';

/// Pregunta desde cuándo rige el nuevo sueldo. Devuelve null si se cancela.
Future<IncomeEffect?> showIncomeEffectDialog(BuildContext context) {
  return showDialog<IncomeEffect>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('¿Desde cuándo rige?'),
      content: const Text(
        'Este mes ya tiene gastos registrados. ¿El nuevo sueldo es de este mes '
        'o empieza el próximo?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, IncomeEffect.nextMonth),
          child: const Text('Próximo mes'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, IncomeEffect.thisMonth),
          child: const Text('Este mes'),
        ),
      ],
    ),
  );
}

/// Avisa de las porciones donde ya se gastó más de lo que permite el nuevo sueldo.
Future<void> showOverspendDialog(
  BuildContext context,
  List<BucketOverspend> overspends,
) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Sueldo actualizado, con alertas'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Con el nuevo monto ya te pasaste en:'),
          const SizedBox(height: 12),
          for (final o in overspends)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '${o.bucketName}: ${formatMoney(o.excess)} de más',
                style: const TextStyle(color: AppColors.danger),
              ),
            ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Entendido'),
        ),
      ],
    ),
  );
}
