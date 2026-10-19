import 'package:flutter/material.dart';

import '../../../core/utils/money_parser.dart';

/// Hoja inferior para escribir el sueldo. Devuelve el monto, o null si se cancela.
Future<double?> showEditIncomeSheet(
  BuildContext context, {
  required double initial,
}) {
  return showModalBottomSheet<double>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _EditIncomeSheet(initial: initial),
  );
}

class _EditIncomeSheet extends StatefulWidget {
  const _EditIncomeSheet({required this.initial});

  final double initial;

  @override
  State<_EditIncomeSheet> createState() => _EditIncomeSheetState();
}

class _EditIncomeSheetState extends State<_EditIncomeSheet> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial == 0 ? '' : widget.initial.toStringAsFixed(2),
  );
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final amount = parseMoney(_controller.text);
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Escribe un monto mayor a 0');
      return;
    }
    Navigator.of(context).pop(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
          Text('Sueldo mensual', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              prefixText: '\$ ',
              labelText: 'Monto',
              errorText: _error,
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(onPressed: _save, child: const Text('Guardar')),
          ),
        ],
      ),
    );
  }
}
