import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/hex_color.dart';
import '../../budget/domain/bucket_option.dart';
import '../domain/category_item.dart';
import 'category_style.dart';

/// Lo que devuelve el formulario: guardar los cambios o eliminar la categoría.
sealed class CategoryFormResult {
  const CategoryFormResult();
}

class CategorySaved extends CategoryFormResult {
  const CategorySaved(this.draft);
  final CategoryDraft draft;
}

class CategoryDeleteRequested extends CategoryFormResult {
  const CategoryDeleteRequested();
}

/// Formulario para crear ([existing] null) o editar una categoría.
Future<CategoryFormResult?> showCategoryFormSheet(
  BuildContext context, {
  required List<BucketOption> bucketOptions,
  CategoryItem? existing,
}) {
  return showModalBottomSheet<CategoryFormResult>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _CategoryForm(bucketOptions: bucketOptions, existing: existing),
  );
}

class _CategoryForm extends StatefulWidget {
  const _CategoryForm({required this.bucketOptions, this.existing});

  final List<BucketOption> bucketOptions;
  final CategoryItem? existing;

  @override
  State<_CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends State<_CategoryForm> {
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  late String _icon = widget.existing?.icon ?? categoryIcons.first;
  late String _color = widget.existing?.colorHex ?? categoryColors.first;
  late int? _bucketId = widget.existing?.defaultBucketId;
  late bool _isFixed = widget.existing?.isFixed ?? false;
  String? _nameError;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    if (_name.text.trim().isEmpty) {
      setState(() => _nameError = 'Escribe un nombre');
      return;
    }
    Navigator.of(context).pop(CategorySaved(CategoryDraft(
      name: _name.text,
      icon: _icon,
      colorHex: _color,
      defaultBucketId: _bucketId,
      isFixed: _isFixed,
    )));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final editing = widget.existing != null;

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
          Text(editing ? 'Editar categoría' : 'Nueva categoría', style: textTheme.titleMedium),
          const SizedBox(height: 16),
          TextField(
            controller: _name,
            autofocus: !editing,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: 'Nombre',
              errorText: _nameError,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 18),
          Text('Icono', style: textTheme.bodySmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final icon in categoryIcons)
                _Choice(
                  selected: icon == _icon,
                  onTap: () => setState(() => _icon = icon),
                  child: Text(icon, style: const TextStyle(fontSize: 20)),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Text('Color', style: textTheme.bodySmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final color in categoryColors)
                _Choice(
                  selected: color == _color,
                  onTap: () => setState(() => _color = color),
                  child: CircleAvatar(radius: 10, backgroundColor: colorFromHex(color)),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Text('Porción a la que suele pertenecer', style: textTheme.bodySmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              ChoiceChip(
                label: const Text('Ninguna'),
                selected: _bucketId == null,
                onSelected: (_) => setState(() => _bucketId = null),
              ),
              for (final bucket in widget.bucketOptions)
                ChoiceChip(
                  label: Text(bucket.name),
                  selected: _bucketId == bucket.id,
                  onSelected: (_) => setState(() => _bucketId = bucket.id),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Gasto fijo'),
            subtitle: const Text('Se repite cada mes (arriendo, internet...)'),
            value: _isFixed,
            onChanged: (value) => setState(() => _isFixed = value),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(onPressed: _save, child: const Text('Guardar')),
          ),
          if (editing) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(const CategoryDeleteRequested()),
                child: const Text(
                  'Eliminar categoría',
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

class _Choice extends StatelessWidget {
  const _Choice({required this.selected, required this.onTap, required this.child});

  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.surfaceAlt,
          border: Border.all(
            color: selected ? AppColors.text : AppColors.line,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: child,
      ),
    );
  }
}
