import 'package:dio/dio.dart';
import '../models/administration.dart';
import '../models/creneau.dart';
import '../models/service.dart';
import 'api_service.dart';

/// Regroupe les appels API liés au catalogue :
/// administrations, services, créneaux.
class CatalogueService {
  final Dio _dio = ApiService().dio;

  Future<List<Administration>> recupererAdministrations() async {
    final reponse = await _dio.get('/administrations');
    return (reponse.data as List)
        .map((json) => Administration.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<Service>> recupererServices(int administrationId) async {
    final reponse =
        await _dio.get('/administrations/$administrationId/services');
    return (reponse.data as List)
        .map((json) => Service.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<Creneau>> recupererCreneaux(int serviceId) async {
    final reponse =
        await _dio.get('/administrations/services/$serviceId/creneaux');
    return (reponse.data as List)
        .map((json) => Creneau.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
