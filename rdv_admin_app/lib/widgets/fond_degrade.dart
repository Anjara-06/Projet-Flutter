import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Fond décoratif avec des halos de couleur dégradés en arrière-plan,
/// pour une ambiance moderne/futuriste sur les écrans d'entrée de l'app.
class FondDegrade extends StatelessWidget {
  final Widget child;

  const FondDegrade({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -80,
          right: -60,
          child: _Halo(
            couleur: AppColors.accent.withValues(alpha: 0.18),
            taille: 220,
          ),
        ),
        Positioned(
          bottom: -100,
          left: -70,
          child: _Halo(
            couleur: AppColors.accentSecondary.withValues(alpha: 0.16),
            taille: 240,
          ),
        ),
        child,
      ],
    );
  }
}

class _Halo extends StatelessWidget {
  final Color couleur;
  final double taille;

  const _Halo({required this.couleur, required this.taille});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: taille,
      height: taille,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [couleur, couleur.withValues(alpha: 0)],
        ),
      ),
    );
  }
}
