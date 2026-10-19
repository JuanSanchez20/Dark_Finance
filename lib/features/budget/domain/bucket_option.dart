/// Una porción que se puede elegir en un formulario (por ejemplo, en una categoría).
class BucketOption {
  const BucketOption({required this.id, required this.name});

  /// Id de la porción permanente (`BucketDefinitions.id`).
  final int id;
  final String name;
}
