import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/utilisateur.dart';

/// Gère la persistance locale du token JWT et de l'utilisateur connecté.
class TokenStorage {
  TokenStorage._();

  static const _cleToken = 'auth_token';
  static const _cleUtilisateur = 'auth_utilisateur';

  static Future<void> sauvegarderSession(
      String token, Utilisateur utilisateur) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cleToken, token);
    await prefs.setString(_cleUtilisateur, jsonEncode(utilisateur.toJson()));
  }

  static Future<String?> lireToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cleToken);
  }

  static Future<Utilisateur?> lireUtilisateur() async {
    final prefs = await SharedPreferences.getInstance();
    final brut = prefs.getString(_cleUtilisateur);
    if (brut == null) return null;
    return Utilisateur.fromJson(jsonDecode(brut) as Map<String, dynamic>);
  }

  static Future<void> effacerSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cleToken);
    await prefs.remove(_cleUtilisateur);
  }
}
