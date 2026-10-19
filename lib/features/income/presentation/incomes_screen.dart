import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../shared/navigation/app_routes.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/app_feedback.dart';
import '../../../shared/widgets/section_title.dart';
import '../data/extra_income_repository.dart';
import '../data/income_repository.dart';
import '../data/recurring_income_repository.dart';
import '../domain/income_entry.dart';
import '../domain/recurring_income.dart';
import 'income_card.dart';
import 'income_form_sheet.dart';

/// Ingresos: sueldo base, ingresos fijos mensuales e ingresos únicos del mes.
/// Desliza hacia abajo para recargar.
class IncomesScreen extends StatefulWidget {
  const IncomesScreen({
    super.key,
    required this.incomeRepository,
    required this.recurringIncomeRepository,
    required this.extraIncomeRepository,
  });

  final IncomeRepository incomeRepository;
  final RecurringIncomeRepository recurringIncomeRepository;
  final ExtraIncomeRepository extraIncomeRepository;

  @override
  State<IncomesScreen> createState() => _IncomesScreenState();
}

class _IncomesScreenState extends State<IncomesScreen> {
  late Future<_IncomesData> _data = _load();

  /// Cambia al recargar para que la tarjeta del sueldo también se vuelva a leer.
  int _version = 0;

  Future<_IncomesData> _load() async => _IncomesData(
        recurring: await widget.recurringIncomeRepository.list(),
        entries: await widget.extraIncomeRepository.listThisMonth(),
      );

  Future<void> _refresh() async {
    final next = _load();
    setState(() {
      _version++;
      _data = next;
    });
    try {
      await next;
    } catch (_) {
      // El error se muestra en pantalla desde el FutureBuilder.
    }
  }

  /// Ejecuta una acción y deja la pantalla actualizada, con aviso de éxito o error.
  Future<void> _run(
    Future<void> Function() action, {
    required String success,
    required String failure,
  }) async {
    try {
      await action();
      if (!mounted) return;
      await _refresh();
      if (mounted) showFeedback(context, success);
    } catch (error) {
      if (mounted) showFailure(context, error, fallback: failure);
    }
  }

  Future<void> _add() async {
    try {
      final sources = await widget.extraIncomeRepository.knownSources();
      if (!mounted) return;
      final result = await showIncomeFormSheet(context, knownSources: sources);
      if (result is! IncomeFormSaved || !mounted) return;

      if (result.isRecurring) {
        await _run(
          () => widget.recurringIncomeRepository.create(
            RecurringIncomeDraft(name: result.source, amount: result.amount),
          ),
          success: 'Ingreso fijo agregado',
          failure: 'Error al agregar el ingreso fijo',
        );
      } else {
        await _run(
          () => widget.extraIncomeRepository.add(
            NewIncome(amount: result.amount, source: result.source, date: result.date),
          ),
          success: 'Ingreso registrado',
          failure: 'Error al registrar el ingreso',
        );
      }
    } catch (error) {
      if (mounted) showFailure(context, error, fallback: 'Error al abrir el formulario');
    }
  }

  Future<void> _edit(RecurringIncome income) async {
    final result = await showIncomeFormSheet(
      context,
      knownSources: const [],
      existing: income,
    );
    if (result == null || !mounted) return;

    switch (result) {
      case IncomeFormSaved():
        await _run(
          () => widget.recurringIncomeRepository.update(
            income.id,
            RecurringIncomeDraft(name: result.source, amount: result.amount),
          ),
          success: 'Ingreso fijo actualizado',
          failure: 'Error al actualizar el ingreso fijo',
        );
      case IncomeFormDeleteRequested():
        if (!await _confirm('Eliminar ingreso fijo', '¿Eliminar "${income.name}"?')) return;
        await _run(
          () => widget.recurringIncomeRepository.delete(income.id),
          success: 'Ingreso fijo eliminado',
          failure: 'Error al eliminar el ingreso fijo',
        );
    }
  }

  Future<void> _toggle(RecurringIncome income, bool isActive) => _run(
        () => widget.recurringIncomeRepository.setActive(income.id, isActive: isActive),
        success: isActive ? 'Ingreso fijo activado' : 'Ingreso fijo desactivado',
        failure: 'Error al cambiar el ingreso fijo',
      );

  Future<void> _deleteEntry(IncomeEntry entry) async {
    final ok = await _confirm(
      'Eliminar ingreso',
      '¿Eliminar "${entry.source}" por ${formatMoney(entry.amount)}?',
    );
    if (!ok) return;
    await _run(
      () => widget.extraIncomeRepository.delete(entry.id),
      success: 'Ingreso eliminado',
      failure: 'Error al eliminar el ingreso',
    );
  }

  Future<bool> _confirm(String title, String message) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    return confirmed == true && mounted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ingresos')),
      drawer: const AppDrawer(currentRoute: AppRoutes.incomes),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        icon: const Icon(Icons.add),
        label: const Text('Agregar ingreso'),
      ),
      body: FutureBuilder<_IncomesData>(
        future: _data,
        builder: (context, snapshot) {
          final data = snapshot.data;
          if (data == null) {
            if (snapshot.hasError) {
              return Center(child: Text('No se pudo cargar: ${snapshot.error}'));
            }
            return const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
              children: [
                const SectionTitle('Sueldo base'),
                IncomeCard(key: ValueKey(_version), repository: widget.incomeRepository),
                ..._recurringSection(data.recurring),
                ..._entriesSection(data.entries),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _recurringSection(List<RecurringIncome> recurring) {
    final textTheme = Theme.of(context).textTheme;
    final total = recurring
        .where((r) => r.isActive)
        .fold<double>(0, (sum, r) => sum + r.amount);
    return [
      SectionTitle('Ingresos fijos · ${formatMoney(total)} al mes'),
      if (recurring.isEmpty)
        AppCard(
          child: Text(
            'Aún no registraste ingresos fijos mensuales',
            style: textTheme.bodySmall,
          ),
        )
      else
        AppCard(
          child: Column(
            children: [
              for (var i = 0; i < recurring.length; i++) ...[
                if (i > 0) const Divider(height: 20),
                _RecurringRow(
                  income: recurring[i],
                  onTap: () => _edit(recurring[i]),
                  onToggle: (value) => _toggle(recurring[i], value),
                ),
              ],
            ],
          ),
        ),
    ];
  }

  List<Widget> _entriesSection(List<IncomeEntry> entries) {
    final textTheme = Theme.of(context).textTheme;
    final total = entries.fold<double>(0, (sum, e) => sum + e.amount);
    return [
      SectionTitle('Ingresos de este mes · ${formatMoney(total)}'),
      if (entries.isEmpty)
        AppCard(
          child: Text(
            'Aún no registraste ingresos únicos este mes',
            style: textTheme.bodySmall,
          ),
        )
      else
        AppCard(
          child: Column(
            children: [
              for (var i = 0; i < entries.length; i++) ...[
                if (i > 0) const Divider(height: 20),
                _EntryRow(entry: entries[i], onDelete: () => _deleteEntry(entries[i])),
              ],
            ],
          ),
        ),
    ];
  }
}

class _IncomesData {
  const _IncomesData({required this.recurring, required this.entries});

  final List<RecurringIncome> recurring;
  final List<IncomeEntry> entries;
}

class _RecurringRow extends StatelessWidget {
  const _RecurringRow({
    required this.income,
    required this.onTap,
    required this.onToggle,
  });

  final RecurringIncome income;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = income.isActive ? AppColors.income : AppColors.faint;
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  income.name,
                  style: textTheme.bodyMedium?.copyWith(
                    color: income.isActive ? AppColors.text : AppColors.faint,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  income.isActive ? 'Se suma cada mes' : 'Desactivado',
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            '${formatMoney(income.amount, showSign: true)}/mes',
            style: textTheme.bodyMedium?.copyWith(color: color),
          ),
          const SizedBox(width: 4),
          Switch(value: income.isActive, onChanged: onToggle),
        ],
      ),
    );
  }
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({required this.entry, required this.onDelete});

  final IncomeEntry entry;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.source, style: textTheme.bodyMedium),
              const SizedBox(height: 2),
              Text('${entry.date.day}/${entry.date.month}', style: textTheme.bodySmall),
            ],
          ),
        ),
        Text(
          formatMoney(entry.amount, showSign: true),
          style: textTheme.bodyMedium?.copyWith(color: AppColors.income),
        ),
        IconButton(
          tooltip: 'Eliminar',
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.muted),
        ),
      ],
    );
  }
}
