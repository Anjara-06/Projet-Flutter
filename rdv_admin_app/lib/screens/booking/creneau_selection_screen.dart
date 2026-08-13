import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_format_fr.dart';
import '../../core/utils/erreur_api.dart';
import '../../models/administration.dart';
import '../../models/creneau.dart';
import '../../models/service.dart';
import '../../services/catalogue_service.dart';
import '../../widgets/etat_chargement.dart';
import '../../widgets/etat_erreur.dart';
import '../../widgets/gradient_button.dart';
import 'confirmation_screen.dart';

class CreneauSelectionScreen extends StatefulWidget {
  final Administration administration;
  final Service service;

  const CreneauSelectionScreen({
    super.key,
    required this.administration,
    required this.service,
  });

  @override
  State<CreneauSelectionScreen> createState() =>
      _CreneauSelectionScreenState();
}

class _CreneauSelectionScreenState extends State<CreneauSelectionScreen> {
  final CatalogueService _catalogueService = CatalogueService();

  List<Creneau> _tousLesCreneaux = [];
  DateTime? _dateSelectionnee;
  Creneau? _creneauSelectionne;
  bool _enChargement = true;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    _chargerCreneaux();
  }

  Future<void> _chargerCreneaux() async {
    setState(() {
      _enChargement = true;
      _erreur = null;
    });
    try {
      final creneaux =
          await _catalogueService.recupererCreneaux(widget.service.id);
      setState(() {
        _tousLesCreneaux = creneaux;
        _dateSelectionnee =
            _datesDisponibles.isNotEmpty ? _datesDisponibles.first : null;
        _enChargement = false;
      });
    } catch (e) {
      setState(() {
        _erreur = messageErreurApi(e);
        _enChargement = false;
      });
    }
  }

  List<DateTime> get _datesDisponibles {
    final dates = _tousLesCreneaux.map((c) => c.date).toSet().toList();
    dates.sort();
    return dates;
  }

  List<Creneau> get _creneauxDuJour {
    if (_dateSelectionnee == null) return [];
    return _tousLesCreneaux
        .where((c) =>
            c.date.year == _dateSelectionnee!.year &&
            c.date.month == _dateSelectionnee!.month &&
            c.date.day == _dateSelectionnee!.day)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choisir un créneau'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.service.nom,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildContenu()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContenu() {
    if (_enChargement) {
      return const EtatChargement();
    }
    if (_erreur != null) {
      return EtatErreur(message: _erreur!, onReessayer: _chargerCreneaux);
    }
    if (_datesDisponibles.isEmpty) {
      return Center(
        child: Text(
          'Aucun créneau disponible pour ce service actuellement',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 64,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _datesDisponibles.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final date = _datesDisponibles[index];
              final estSelectionnee = date.year == _dateSelectionnee!.year &&
                  date.month == _dateSelectionnee!.month &&
                  date.day == _dateSelectionnee!.day;
              return _DateChip(
                date: date,
                selectionnee: estSelectionnee,
                onTap: () {
                  setState(() {
                    _dateSelectionnee = date;
                    _creneauSelectionne = null;
                  });
                },
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Créneaux disponibles',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _creneauxDuJour.isEmpty
              ? Center(
                  child: Text(
                    'Aucun créneau ce jour-là',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
              : GridView.builder(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2.4,
                  ),
                  itemCount: _creneauxDuJour.length,
                  itemBuilder: (context, index) {
                    final creneau = _creneauxDuJour[index];
                    final estSelectionne =
                        _creneauSelectionne?.id == creneau.id;
                    return _CreneauChip(
                      creneau: creneau,
                      selectionne: estSelectionne,
                      onTap: creneau.disponible
                          ? () {
                              setState(() {
                                _creneauSelectionne = creneau;
                              });
                            }
                          : null,
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: GradientButton(
            label: 'Confirmer le créneau',
            onPressed: _creneauSelectionne == null
                ? null
                : () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ConfirmationScreen(
                          administration: widget.administration,
                          service: widget.service,
                          creneau: _creneauSelectionne!,
                        ),
                      ),
                    );
                  },
          ),
        ),
      ],
    );
  }
}

class _DateChip extends StatelessWidget {
  final DateTime date;
  final bool selectionnee;
  final VoidCallback onTap;

  const _DateChip({
    required this.date,
    required this.selectionnee,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 52,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selectionnee ? AppColors.accent : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormatFr.jourCourt(date),
              style: TextStyle(
                fontSize: 11,
                color: selectionnee ? AppColors.onAccent : AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: selectionnee
                    ? AppColors.onAccent
                    : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreneauChip extends StatelessWidget {
  final Creneau creneau;
  final bool selectionne;
  final VoidCallback? onTap;

  const _CreneauChip({
    required this.creneau,
    required this.selectionne,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color couleurTexte;
    final Color couleurFond;
    final Border? bordure;

    if (!creneau.disponible) {
      couleurTexte = AppColors.textMuted;
      couleurFond = AppColors.surface;
      bordure = Border.all(color: AppColors.border);
    } else if (selectionne) {
      couleurTexte = AppColors.onAccent;
      couleurFond = AppColors.accent;
      bordure = null;
    } else {
      couleurTexte = AppColors.accent;
      couleurFond = AppColors.surface;
      bordure = Border.all(color: AppColors.accent);
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: couleurFond,
          borderRadius: BorderRadius.circular(12),
          border: bordure,
        ),
        alignment: Alignment.center,
        child: Text(
          creneau.heureDebut,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: couleurTexte,
          ),
        ),
      ),
    );
  }
}
