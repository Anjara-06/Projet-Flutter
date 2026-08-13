import 'package:flutter/material.dart';

/// Représente une administration (mairie, Fokontany, etc.)
class Administration {
  final int id;
  final String nom;
  final String adresse;
  final String ville;
  final double distanceKm;
  final IconData icone;

  const Administration({
    required this.id,
    required this.nom,
    required this.adresse,
    required this.ville,
    required this.distanceKm,
    required this.icone,
  });

  /// Construit un objet à partir d'une réponse JSON de l'API.
  /// (utilisé plus tard, quand on connectera le backend)
  factory Administration.fromJson(Map<String, dynamic> json) {
    return Administration(
      id: json['id'] as int,
      nom: json['nom'] as String,
      adresse: json['adresse'] as String,
      ville: json['ville'] as String,
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0,
      icone: _iconeDepuisNom(json['icone'] as String?),
    );
  }

  static IconData _iconeDepuisNom(String? nom) {
    switch (nom) {
      case 'file-certificate':
        return Icons.badge_rounded;
      case 'building-bank':
      default:
        return Icons.account_balance_rounded;
    }
  }
}
