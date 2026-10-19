import '../domain/home_summary.dart';

/// Contrato de acceso a los datos del Resumen.
/// La pantalla depende de esto, no de dónde vienen los datos
/// (base local, notificaciones, datos de ejemplo...).
abstract class HomeSummaryRepository {
  Future<HomeSummary> load();
}
