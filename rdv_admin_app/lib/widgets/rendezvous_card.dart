import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/date_format_fr.dart';
import '../models/rendezvous_historique.dart';

class RendezVousCard extends StatelessWidget {
  final RendezVousHistorique rendezVous;
  final VoidCallback? onAnnuler;

  const RendezVousCard({
    super.key,
    required this.rendezVous,
    this.onAnnuler,
  });

  @override
  Widget build(BuildContext context) {
    final estAnnule = rendezVous.statut == 'annule';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rendezVous.serviceNom,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${rendezVous.administrationNom} · ${rendezVous.administrationVille}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              _BadgeStatut(statut: rendezVous.statut),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 14, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Text(
                DateFormatFr.jourEtMois(rendezVous.date),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(width: 14),
              const Icon(Icons.access_time_rounded,
                  size: 14, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Text(
                rendezVous.heureDebut,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              Text(
                rendezVous.numeroRdv,
                style: const TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          if (!estAnnule && onAnnuler != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onAnnuler,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(40),
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.danger),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Annuler le rendez-vous'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BadgeStatut extends StatelessWidget {
  final String statut;

  const _BadgeStatut({required this.statut});

  @override
  Widget build(BuildContext context) {
    late final Color couleur;
    late final String texte;

    switch (statut) {
      case 'annule':
        couleur = AppColors.danger;
        texte = 'Annulé';
        break;
      case 'termine':
        couleur = AppColors.textMuted;
        texte = 'Terminé';
        break;
      default:
        couleur = AppColors.success;
        texte = 'Confirmé';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        texte,
        style: TextStyle(
          color: couleur,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
