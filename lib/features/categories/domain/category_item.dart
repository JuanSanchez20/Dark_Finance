/// Datos editables de una categoría (lo que el usuario escribe en el formulario).
class CategoryDraft {
  const CategoryDraft({
    required this.name,
    required this.icon,
    required this.colorHex,
    this.defaultBucketId,
    this.isFixed = false,
  });

  final String name;
  final String icon;
  final String colorHex;

  /// Id de la porción a la que suele pertenecer (null = ninguna en particular).
  final int? defaultBucketId;

  /// Gasto fijo que se repite cada mes (arriendo, internet...).
  final bool isFixed;
}

/// Categoría ya guardada.
class CategoryItem extends CategoryDraft {
  const CategoryItem({
    required this.id,
    required super.name,
    required super.icon,
    required super.colorHex,
    super.defaultBucketId,
    super.isFixed,
    this.defaultBucketName,
  });

  final int id;

  /// Nombre de la porción, solo para mostrarlo (el enlace real es [defaultBucketId]).
  final String? defaultBucketName;
}
