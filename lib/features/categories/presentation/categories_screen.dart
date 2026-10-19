import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/hex_color.dart';
import '../../../shared/navigation/app_routes.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/app_feedback.dart';
import '../../budget/domain/bucket_option.dart';
import '../data/categories_repository.dart';
import '../domain/category_item.dart';
import 'category_form_sheet.dart';

/// Lista de categorías de gasto; permite crear, editar y eliminar.
/// Desliza hacia abajo para recargar.
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key, required this.repository});

  final CategoriesRepository repository;

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late Future<_CategoriesData> _data = _load();

  Future<_CategoriesData> _load() async => _CategoriesData(
        categories: await widget.repository.list(),
        bucketOptions: await widget.repository.bucketOptions(),
      );

  Future<void> _refresh() async {
    final next = _load();
    setState(() {
      _data = next;
    });
    try {
      await next;
    } catch (_) {
      // El error se muestra en pantalla desde el FutureBuilder.
    }
  }

  Future<void> _openForm(
    List<BucketOption> bucketOptions, {
    CategoryItem? existing,
  }) async {
    final result = await showCategoryFormSheet(
      context,
      bucketOptions: bucketOptions,
      existing: existing,
    );
    if (result == null || !mounted) return;

    switch (result) {
      case CategorySaved(:final draft):
        await _run(
          () => existing == null
              ? widget.repository.create(draft)
              : widget.repository.update(existing.id, draft),
          success: existing == null ? 'Categoría creada' : 'Categoría actualizada',
        );
      case CategoryDeleteRequested():
        await _run(
          () => widget.repository.delete(existing!.id),
          success: 'Categoría eliminada',
        );
    }
  }

  /// Ejecuta la acción; solo avisa de error si la acción falla, y recarga la lista.
  Future<void> _run(Future<void> Function() action, {required String success}) async {
    try {
      await action();
    } catch (error) {
      if (mounted) {
        showFailure(context, error, fallback: 'Error al guardar la categoría');
      }
      return;
    }
    if (!mounted) return;
    await _refresh();
    if (mounted) showFeedback(context, success);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categorías')),
      drawer: const AppDrawer(currentRoute: AppRoutes.categories),
      floatingActionButton: FutureBuilder<_CategoriesData>(
        future: _data,
        builder: (context, snapshot) {
          final data = snapshot.data;
          if (data == null) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () => _openForm(data.bucketOptions),
            icon: const Icon(Icons.add),
            label: const Text('Nueva categoría'),
          );
        },
      ),
      body: FutureBuilder<_CategoriesData>(
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
                AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                  child: Column(
                    children: [
                      for (var i = 0; i < data.categories.length; i++) ...[
                        if (i > 0) const Divider(height: 1),
                        _CategoryRow(
                          category: data.categories[i],
                          onTap: () => _openForm(
                            data.bucketOptions,
                            existing: data.categories[i],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CategoriesData {
  const _CategoriesData({required this.categories, required this.bucketOptions});

  final List<CategoryItem> categories;
  final List<BucketOption> bucketOptions;
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.category, required this.onTap});

  final CategoryItem category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final details = [
      category.defaultBucketName ?? 'Sin porción',
      if (category.isFixed) 'fijo',
    ].join(' · ');

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorFromHex(category.colorHex), width: 1.5),
              ),
              child: Text(category.icon, style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(category.name, style: textTheme.bodyMedium),
                  const SizedBox(height: 2),
                  Text(details, style: textTheme.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.faint),
          ],
        ),
      ),
    );
  }
}
