import 'package:dio/dio.dart';

/// Transforme une erreur (souvent une DioException) en message
/// clair à afficher à l'utilisateur.
String messageErreurApi(Object erreur) {
  if (erreur is DioException) {
    final data = erreur.response?.data;
    if (data is Map && data['erreur'] != null) {
      return data['erreur'].toString();
    }
    if (erreur.type == DioExceptionType.connectionError ||
        erreur.type == DioExceptionType.connectionTimeout ||
        erreur.type == DioExceptionType.receiveTimeout) {
      return 'Impossible de contacter le serveur. Vérifie que le backend est bien lancé.';
    }
  }
  return 'Une erreur est survenue. Réessaie.';
}
