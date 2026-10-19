import '../../budget/domain/bucket_option.dart';
import '../domain/category_item.dart';

/// Contrato para consultar y editar las categorías de gasto.
///
/// Las operaciones de escritura lanzan `InvalidInputException` con un mensaje
/// legible si el dato no es válido (nombre vacío o repetido, categoría en uso).
abstract class CategoriesRepository {
  Future<List<CategoryItem>> list();

  /// Porciones que se pueden elegir como "porción habitual" de una categoría.
  Future<List<BucketOption>> bucketOptions();

  Future<void> create(CategoryDraft draft);

  Future<void> update(int id, CategoryDraft draft);

  Future<void> delete(int id);
}
