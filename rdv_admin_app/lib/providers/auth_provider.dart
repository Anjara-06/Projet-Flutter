import 'package:flutter/material.dart';
import '../core/utils/erreur_api.dart';
import '../models/utilisateur.dart';
import '../services/auth_service.dart';
import '../services/token_storage.dart';

/// Gère l'état de connexion de l'utilisateur dans toute l'application.
/// Accessible partout via `context.watch<AuthProvider>()` ou `context.read<AuthProvider>()`.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  Utilisateur? _utilisateur;
  bool _chargementInitial = true;
  bool _chargementAction = false;
  String? _erreur;

  Utilisateur? get utilisateur => _utilisateur;
  bool get estConnecte => _utilisateur != null;
  bool get chargementInitial => _chargementInitial;
  bool get chargementAction => _chargementAction;
  String? get erreur => _erreur;

  /// Vérifie si une session est déjà enregistrée localement (appelé au démarrage).
  Future<void> verifierSession() async {
    final token = await TokenStorage.lireToken();
    final utilisateurStocke = await TokenStorage.lireUtilisateur();
    if (token != null && utilisateurStocke != null) {
      _utilisateur = utilisateurStocke;
    }
    _chargementInitial = false;
    notifyListeners();
  }

  Future<bool> connexion(String email, String motDePasse) async {
    _chargementAction = true;
    _erreur = null;
    notifyListeners();

    try {
      final (utilisateur, token) =
          await _authService.connexion(email: email, motDePasse: motDePasse);
      await TokenStorage.sauvegarderSession(token, utilisateur);
      _utilisateur = utilisateur;
      _chargementAction = false;
      notifyListeners();
      return true;
    } catch (e) {
      _erreur = messageErreurApi(e);
      _chargementAction = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> inscription({
    required String nom,
    required String prenom,
    required String email,
    required String motDePasse,
    String? telephone,
  }) async {
    _chargementAction = true;
    _erreur = null;
    notifyListeners();

    try {
      final (utilisateur, token) = await _authService.inscription(
        nom: nom,
        prenom: prenom,
        email: email,
        motDePasse: motDePasse,
        telephone: telephone,
      );
      await TokenStorage.sauvegarderSession(token, utilisateur);
      _utilisateur = utilisateur;
      _chargementAction = false;
      notifyListeners();
      return true;
    } catch (e) {
      _erreur = messageErreurApi(e);
      _chargementAction = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> deconnexion() async {
    await TokenStorage.effacerSession();
    _utilisateur = null;
    notifyListeners();
  }
}
