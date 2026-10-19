/// Tipo de movimiento. Se guarda en la base como el nombre ('expense', 'income'...).
enum TransactionType { expense, income, goalContribution }

/// Cómo se creó el movimiento.
/// - manual: lo escribió el usuario.
/// - notification: vino de una notificación del banco.
/// - recurring: lo generó un ingreso fijo mensual.
enum TransactionSource { manual, notification, recurring }
