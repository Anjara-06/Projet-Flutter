import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_format_fr.dart';
import '../../core/utils/erreur_api.dart';
import '../../models/administration.dart';
import '../../models/creneau.dart';
import '../../models/rendezvous.dart';
import '../../models/service.dart';
import '../../services/rendezvous_service.dart';
import '../../services/notification_service.dart';
import '../../widgets/gradient_button.dart';
import '../ticket/ticket_screen.dart';

class ConfirmationScreen extends StatefulWidget {
  final Administration administration;
  final Service service;
  final Creneau creneau;

  const ConfirmationScreen({
    super.key,
    required this.administration,
    required this.service,
    required this.creneau,
  });

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  final RendezVousService _rendezVousService = RendezVousService();
  bool _enCours = false;

  Future<void> _confirmer() async {
    setState(() => _enCours = true);

    try {
      final reponse =
          await _rendezVousService.creerRendezVous(widget.creneau.id);

      final rendezVous = RendezVous(
        id: reponse['id'] as int,
        numeroRdv: reponse['numero_rdv'] as String,
        codeQr: reponse['code_qr'] as String,
        administration: widget.administration,
        service: widget.service,
        creneau: widget.creneau,
        dateCreation: DateTime.now(),
      );

      // La programmation du rappel ne doit jamais bloquer la confirmation
      // du rendez-vous, même si elle échoue (ex. permission refusée).
      try {
        final heureParts = widget.creneau.heureDebut.split(':');
        final dateHeureRdv = DateTime(
          widget.creneau.date.year,
          widget.creneau.date.month,
          widget.creneau.date.day,
          int.parse(heureParts[0]),
          int.parse(heureParts[1]),
        );
        await NotificationService().programmerRappel(
          id: rendezVous.id,
          titre: 'Rendez-vous dans 1 heure',
          corps:
              '${widget.service.nom} — ${widget.administration.nom} à ${widget.creneau.heureDebut}',
          dateHeureRdv: dateHeureRdv,
        );
      } catch (_) {
        // On ignore silencieusement : le RDV reste valide sans rappel.
      }

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => TicketScreen(rendezVous: rendezVous),
        ),
      );
    } catch (e) {
      setState(() => _enCours = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(messageErreurApi(e))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmation'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Vérifie les détails avant de confirmer',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    _LigneRecap(
                      icone: Icons.account_balance_rounded,
                      titre: 'Administration',
                      valeur: widget.administration.nom,
                    ),
                    const Divider(height: 28),
                    _LigneRecap(
                      icone: Icons.description_outlined,
                      titre: 'Service',
                      valeur: widget.service.nom,
                    ),
                    const Divider(height: 28),
                    _LigneRecap(
                      icone: Icons.calendar_today_outlined,
                      titre: 'Date',
                      valeur: DateFormatFr.jourEtMois(widget.creneau.date),
                    ),
                    const Divider(height: 28),
                    _LigneRecap(
                      icone: Icons.access_time_rounded,
                      titre: 'Heure',
                      valeur:
                          '${widget.creneau.heureDebut} - ${widget.creneau.heureFin}',
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: AppColors.degradeLeger,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: AppColors.accentDark, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Un ticket avec QR code te sera généré. Présente-le sur place.',
                        style: const TextStyle(
                          color: AppColors.accentDark,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GradientButton(
                label: 'Confirmer le rendez-vous',
                enCours: _enCours,
                onPressed: _enCours ? null : _confirmer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LigneRecap extends StatelessWidget {
  final IconData icone;
  final String titre;
  final String valeur;

  const _LigneRecap({
    required this.icone,
    required this.titre,
    required this.valeur,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            gradient: AppColors.degradeLeger,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icone, color: AppColors.accent, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titre, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 2),
              Text(valeur, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ],
    );
  }
}
