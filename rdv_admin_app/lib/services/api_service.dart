import 'package:dio/dio.dart';
import 'token_storage.dart';

/// Client HTTP unique pour toute l'app, avec le token JWT
/// injecté automatiquement dans chaque requête si disponible.
///
/// IMPORTANT : sur émulateur Android, remplace 'localhost' par '10.0.2.2'.
/// Sur Chrome/web ou iOS simulateur, 'localhost' fonctionne directement.
class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';

  ApiService._interne() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStorage.lireToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  static final ApiService _instance = ApiService._interne();
  factory ApiService() => _instance;

  late final Dio dio;
}
