import 'package:flutter/material.dart';

/// Palette de couleurs de l'application.
/// Style : moderne, épuré, accent violet/indigo électrique.
class AppColors {
  AppColors._();

  // Couleur d'accent principale (boutons, éléments actifs, icônes clés)
  static const Color accent = Color(0xFF6C5CE7);
  static const Color accentLight = Color(0xFFEDEBFF);
  static const Color accentDark = Color(0xFF4B3FC0);

  // Couleur d'accent secondaire (cyan électrique), utilisée en dégradé
  // avec l'accent principal pour une touche futuriste sur les éléments clés.
  static const Color accentSecondary = Color(0xFF22D3EE);

  static const LinearGradient degradePrincipal = LinearGradient(
    colors: [accent, accentSecondary],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Version très claire du dégradé, pour les fonds d'icônes sur les cards.
  static const Color accentSecondaryLight = Color(0xFFE0FBFF);
  static const LinearGradient degradeLeger = LinearGradient(
    colors: [accentLight, accentSecondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Fonds
  static const Color background = Color(0xFFF7F7FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF1F1F6);

  // Textes
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B6B80);
  static const Color textMuted = Color(0xFFA0A0B2);
  static const Color onAccent = Color(0xFFFFFFFF);

  // États
  static const Color success = Color(0xFF2ECC71);
  static const Color danger = Color(0xFFE74C3C);
  static const Color warning = Color(0xFFF5A623);

  // Bordures
  static const Color border = Color(0xFFE5E5EF);
}
