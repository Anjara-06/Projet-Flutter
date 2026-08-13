import 'package:dio/dio.dart';
import '../models/rendezvous_historique.dart';
import 'api_service.dart';

class RendezVousService {
  final Dio _dio = ApiService().dio;

  /// Crée un rendez-vous sur un créneau. Renvoie la réponse brute de l'API
  /// (contient notamment numero_rdv et code_qr générés par le serveur).
  Future<Map<String, dynamic>> creerRendezVous(int creneauId) async {
    final reponse = await _dio.post(
      '/rendezvous',
      data: {'creneau_id': creneauId},
    );
    return reponse.data as Map<String, dynamic>;
  }

  Future<List<RendezVousHistorique>> mesRendezVous() async {
    final reponse = await _dio.get('/rendezvous');
    return (reponse.data as List)
        .map((json) =>
            RendezVousHistorique.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> annuler(int rendezVousId) async {
    await _dio.patch('/rendezvous/$rendezVousId/annuler');
  }
}
