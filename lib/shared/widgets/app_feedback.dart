import 'package:flutter/material.dart';

import '../../core/errors/invalid_input_exception.dart';
import '../../core/theme/app_colors.dart';

/// Aviso breve en la parte baja de la pantalla (éxito o error).
void showFeedback(BuildContext context, String message, {bool isError = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: isError ? AppColors.danger : AppColors.income,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
}

/// Muestra un error: el mensaje propio si es un dato inválido, o [fallback] si no.
void showFailure(BuildContext context, Object error, {required String fallback}) {
  showFeedback(
    context,
    error is InvalidInputException ? error.message : fallback,
    isError: true,
  );
}
