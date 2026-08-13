import 'package:flutter/material.dart';
import '../../core/utils/erreur_api.dart';
import '../../models/rendezvous_historique.dart';
import '../../services/rendezvous_service.dart';
import '../../services/notification_service.dart';
import '../../widgets/etat_chargement.dart';
import '../../widgets/etat_erreur.dart';
import '../../widgets/rendezvous_card.dart';
import '../../core/theme/app_colors.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final RendezVousService _rendezVousService = RendezVousService();
  List<RendezVousHistorique> _rendezVous = [];
  bool _enChargement = true;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    setState(() {
      _enChargement = true;
      _erreur = null;
    });
    try {
      final rendezVous = await _rendezVousService.mesRendezVous();
      setState(() {
        _rendezVous = rendezVous;
        _enChargement = false;
      });
    } catch (e) {
      setState(() {
        _erreur = messageErreurApi(e);
        _enChargement = false;
      });
    }
  }

  Future<void> _annuler(RendezVousHistorique rdv) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler ce rendez-vous ?'),
        content: Text(
          '${rdv.serviceNom} — ${rdv.numeroRdv}\nCette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Retour'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirmer l\'annulation'),
          ),
        ],
      ),
    );

    if (confirme != true) return;

    try {
      await _rendezVousService.annuler(rdv.id);
      try {
        await NotificationService().annulerRappel(rdv.id);
      } catch (_) {
        // Pas grave si l'annulation locale échoue, le RDV est déjà annulé côté serveur.
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rendez-vous annulé')),
      );
      _charger();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(messageErreurApi(e))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes rendez-vous')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _buildContenu(),
        ),
      ),
    );
  }

  Widget _buildContenu() {
    if (_enChargement) {
      return const EtatChargement();
    }
    if (_erreur != null) {
      return EtatErreur(message: _erreur!, onReessayer: _charger);
    }
    if (_rendezVous.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.confirmation_number_outlined,
                size: 48, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(
              'Aucun rendez-vous pour le moment',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _charger,
      child: ListView.separated(
        padding: const EdgeInsets.only(top: 8, bottom: 20),
        itemCount: _rendezVous.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final rdv = _rendezVous[index];
          return RendezVousCard(
            rendezVous: rdv,
            onAnnuler: () => _annuler(rdv),
          );
        },
      ),
    );
  }
}
