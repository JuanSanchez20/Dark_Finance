import 'package:drift/drift.dart' show Value;

import '../../../core/database/app_database.dart';
import '../../../core/errors/invalid_input_exception.dart';
import '../../budget/domain/bucket_option.dart';
import '../domain/category_item.dart';
import 'categories_repository.dart';

class DriftCategoriesRepository implements CategoriesRepository {
  DriftCategoriesRepository(this._db);

  static const _maxNameLength = 30;

  final AppDatabase _db;

  @override
  Future<List<CategoryItem>> list() async {
    final definitions = {
      for (final d in await _db.bucketDefinitionsDao.all()) d.id: d.name,
    };
    final rows = await _db.categoriesDao.allCategories();
    return [
      for (final c in rows)
        CategoryItem(
          id: c.id,
          name: c.name,
          icon: c.icon,
          colorHex: c.color,
          defaultBucketId: c.defaultBucketId,
          defaultBucketName: definitions[c.defaultBucketId],
          isFixed: c.isFixed,
        ),
    ];
  }

  @override
  Future<List<BucketOption>> bucketOptions() async {
    final definitions = await _db.bucketDefinitionsDao.all();
    return [for (final d in definitions) BucketOption(id: d.id, name: d.name)];
  }

  @override
  Future<void> create(CategoryDraft draft) async {
    final name = await _validName(draft.name);
    await _checkBucket(draft.defaultBucketId);
    await _db.categoriesDao.insertCategory(
      CategoriesCompanion.insert(
        name: name,
        icon: draft.icon,
        color: draft.colorHex,
        defaultBucketId: Value(draft.defaultBucketId),
        isFixed: Value(draft.isFixed),
      ),
    );
  }

  @override
  Future<void> update(int id, CategoryDraft draft) async {
    final name = await _validName(draft.name, ignoringId: id);
    await _checkBucket(draft.defaultBucketId);
    await (_db.update(_db.categories)..where((t) => t.id.equals(id))).write(
      CategoriesCompanion(
        name: Value(name),
        icon: Value(draft.icon),
        color: Value(draft.colorHex),
        defaultBucketId: Value(draft.defaultBucketId),
        isFixed: Value(draft.isFixed),
      ),
    );
  }

  @override
  Future<void> delete(int id) async {
    final uses = await _db.transactionsDao.countByCategory(id);
    if (uses > 0) {
      throw const InvalidInputException(
        'No se puede eliminar: hay movimientos que usan esta categoría',
      );
    }
    await _db.categoriesDao.deleteCategory(id);
  }

  /// Verifica que la porción elegida exista (null = sin porción).
  Future<void> _checkBucket(int? bucketId) async {
    if (bucketId == null) return;
    final exists = (await _db.bucketDefinitionsDao.all()).any((d) => d.id == bucketId);
    if (!exists) throw const InvalidInputException('La porción elegida no existe');
  }

  /// Nombre limpio, o `InvalidInputException` si está vacío, es muy largo o ya existe.
  Future<String> _validName(String raw, {int? ignoringId}) async {
    final name = raw.trim();
    if (name.isEmpty) {
      throw const InvalidInputException('Escribe un nombre para la categoría');
    }
    if (name.length > _maxNameLength) {
      throw const InvalidInputException('El nombre es muy largo (máximo 30 letras)');
    }
    final existing = await _db.categoriesDao.allCategories();
    final repeated = existing.any(
      (c) => c.id != ignoringId && c.name.toLowerCase() == name.toLowerCase(),
    );
    if (repeated) {
      throw const InvalidInputException('Ya existe una categoría con ese nombre');
    }
    return name;
  }
}
