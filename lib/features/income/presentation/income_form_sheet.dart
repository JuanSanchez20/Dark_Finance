import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/money_parser.dart';
import '../domain/recurring_income.dart';

/// Resultado del formulario de ingresos.
sealed class IncomeFormResult {
  const IncomeFormResult();
}

class IncomeFormSaved extends IncomeFormResult {
  const IncomeFormSaved({
    required this.amount,
    required this.source,
    required this.isRecurring,
    required this.date,
  });

  final double amount;
  final String source;

  /// true = se suma al sueldo cada mes (sin fecha); false = solo este mes.
  final bool isRecurring;
  final DateTime date;
}

class IncomeFormDeleteRequested extends IncomeFormResult {
  const IncomeFormDeleteRequested();
}

/// Formulario para registrar un ingreso, o para editar un ingreso fijo ([existing]).
Future<IncomeFormResult?> showIncomeFormSheet(
  BuildContext context, {
  required List<String> knownSources,
  RecurringIncome? existing,
}) {
  return showModalBottomSheet<IncomeFormResult>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _IncomeForm(knownSources: knownSources, existing: existing),
  );
}

class _IncomeForm extends StatefulWidget {
  const _IncomeForm({required this.knownSources, this.existing});

  final List<String> knownSources;
  final RecurringIncome? existing;

  @override
  State<_IncomeForm> createState() => _IncomeFormState();
}

class _IncomeFormState extends State<_IncomeForm> {
  late final _amount = TextEditingController(
    text: widget.existing == null ? '' : widget.existing!.amount.toStringAsFixed(2),
  );
  late final _source = TextEditingController(text: widget.existing?.name ?? '');
  late bool _isRecurring = widget.existing != null;
  DateTime _date = DateTime.now();
  String? _amountError;
  String? _sourceError;

  bool get _editing => widget.existing != null;

  @override
  void dispose() {
    _amount.dispose();
    _source.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year, now.month, 1),
      lastDate: now,
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _save() {
    final amount = parseMoney(_amount.text);
    final source = _source.text.trim();
    setState(() {
      _amountError = (amount == null || amount <= 0) ? 'Escribe un monto mayor a 0' : null;
      _sourceError = source.isEmpty ? 'Indica de dónde viene' : null;
    });
    if (_amountError != null || _sourceError != null) return;

    Navigator.of(context).pop(IncomeFormSaved(
      amount: amount!,
      source: source,
      isRecurring: _isRecurring,
      date: _date,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        20,
        24,
        20,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _editing ? 'Editar ingreso fijo' : 'Nuevo ingreso',
            style: textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amount,
            autofocus: !_editing,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              prefixText: '\$ ',
              labelText: 'Monto',
              errorText: _amountError,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _source,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: 'Origen (bono, transporte, venta...)',
              errorText: _sourceError,
              border: const OutlineInputBorder(),
            ),
          ),
          if (!_editing && !_isRecurring && widget.knownSources.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                for (final source in widget.knownSources.take(6))
                  ActionChip(
                    label: Text(source),
                    onPressed: () => setState(() => _source.text = source),
                  ),
              ],
            ),
          ],
          if (!_editing) ...[
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Tipo de ingreso'),
              subtitle: Text(
                _isRecurring
                    ? 'Fijo: se suma al sueldo cada mes'
                    : 'Variable: Solo cuenta este mes',
              ),
              value: _isRecurring,
              onChanged: (value) => setState(() => _isRecurring = value),
            ),
          ],
          if (!_isRecurring) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today_outlined, size: 18),
              label: Text('Fecha: ${_date.day}/${_date.month}/${_date.year}'),
            ),
          ],
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(onPressed: _save, child: const Text('Guardar')),
          ),
          if (_editing) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(const IncomeFormDeleteRequested()),
                child: const Text(
                  'Eliminar ingreso fijo',
                  style: TextStyle(color: AppColors.danger),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
