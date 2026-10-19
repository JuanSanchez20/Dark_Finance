/// Dato inválido escrito por el usuario. Su [message] se puede mostrar tal cual.
/// Cualquier otra excepción se trata como error inesperado.
class InvalidInputException implements Exception {
  const InvalidInputException(this.message);

  final String message;

  @override
  String toString() => message;
}
