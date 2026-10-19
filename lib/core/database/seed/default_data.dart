// Datos con los que nace la base de datos. Solo se usan al crearla por primera vez.

class DefaultBucket {
  const DefaultBucket({
    required this.key,
    required this.name,
    required this.description,
    required this.percent,
  });

  final String key;
  final String name;
  final String description;
  final int percent;
}

/// Reparto del ingreso (50/25/15/10). El orden define cómo se muestran.
const defaultBuckets = [
  DefaultBucket(
    key: 'obligatorios',
    name: 'Gastos Obligatorios',
    description: 'Arriendo, servicios, comida, transporte',
    percent: 50,
  ),
  DefaultBucket(
    key: 'inversion',
    name: 'Inversión',
    description: 'Ahorro e inversión',
    percent: 25,
  ),
  DefaultBucket(
    key: 'emergencia',
    name: 'Casos de Emergencia',
    description: 'Reserva para lo inesperado',
    percent: 15,
  ),
  DefaultBucket(
    key: 'gustos',
    name: 'Gustos',
    description: 'Salidas, juegos, suscripciones',
    percent: 10,
  ),
];

class DefaultCategory {
  const DefaultCategory({
    required this.name,
    required this.icon,
    required this.color,
    this.bucketKey,
    this.isFixed = false,
  });

  final String name;
  final String icon;
  final String color;

  /// `key` de la porción habitual (ver [defaultBuckets]).
  final String? bucketKey;
  final bool isFixed;
}

const defaultCategories = [
  DefaultCategory(name: 'Comida', icon: '🍽️', color: '#FF6B6B', bucketKey: 'obligatorios'),
  DefaultCategory(name: 'Transporte', icon: '🚌', color: '#4ECDC4', bucketKey: 'obligatorios'),
  DefaultCategory(name: 'Arriendo', icon: '🏠', color: '#45B7D1', bucketKey: 'obligatorios', isFixed: true),
  DefaultCategory(name: 'Servicios', icon: '💡', color: '#96CEB4', bucketKey: 'obligatorios', isFixed: true),
  DefaultCategory(name: 'Salud', icon: '💊', color: '#FFEAA7', bucketKey: 'obligatorios'),
  DefaultCategory(name: 'Entretenimiento', icon: '🎮', color: '#DDA0DD', bucketKey: 'gustos'),
  DefaultCategory(name: 'Suscripciones', icon: '📱', color: '#98D8C8', bucketKey: 'gustos', isFixed: true),
  DefaultCategory(name: 'Ropa', icon: '👕', color: '#F7DC6F', bucketKey: 'gustos'),
  DefaultCategory(name: 'Inversión', icon: '🏦', color: '#82E0AA', bucketKey: 'inversion'),
  DefaultCategory(name: 'Emergencia', icon: '⚠️', color: '#F1948A', bucketKey: 'emergencia'),
];
