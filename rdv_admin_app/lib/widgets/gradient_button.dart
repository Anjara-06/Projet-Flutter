import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Bouton principal à dégradé (violet → cyan) avec effet de lueur,
/// utilisé pour les actions clés de l'application (CTA).
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool enCours;
  final IconData? icone;

  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enCours = false,
    this.icone,
  });

  @override
  Widget build(BuildContext context) {
    final desactive = onPressed == null;

    return Opacity(
      opacity: desactive ? 0.5 : 1,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: AppColors.degradePrincipal,
          boxShadow: desactive
              ? const []
              : [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: desactive ? null : onPressed,
            child: Center(
              child: enCours
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icone != null) ...[
                          Icon(icone, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
