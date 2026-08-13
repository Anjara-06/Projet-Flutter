import 'package:dio/dio.dart';
import '../models/utilisateur.dart';
import 'api_service.dart';

class AuthService {
  final Dio _dio = ApiService().dio;

  Future<(Utilisateur, String)> inscription({
    required String nom,
    required String prenom,
    required String email,
    required String motDePasse,
    String? telephone,
  }) async {
    final reponse = await _dio.post('/auth/register', data: {
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'mot_de_passe': motDePasse,
      'telephone': telephone,
    });
    final utilisateur =
        Utilisateur.fromJson(reponse.data['utilisateur'] as Map<String, dynamic>);
    final token = reponse.data['token'] as String;
    return (utilisateur, token);
  }

  Future<(Utilisateur, String)> connexion({
    required String email,
    required String motDePasse,
  }) async {
    final reponse = await _dio.post('/auth/login', data: {
      'email': email,
      'mot_de_passe': motDePasse,
    });
    final utilisateur =
        Utilisateur.fromJson(reponse.data['utilisateur'] as Map<String, dynamic>);
    final token = reponse.data['token'] as String;
    return (utilisateur, token);
  }
}
