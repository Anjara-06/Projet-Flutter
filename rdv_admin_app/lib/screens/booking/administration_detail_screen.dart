import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/erreur_api.dart';
import '../../models/administration.dart';
import '../../models/service.dart';
import '../../services/catalogue_service.dart';
import '../../widgets/etat_chargement.dart';
import '../../widgets/etat_erreur.dart';
import '../../widgets/service_card.dart';
import 'creneau_selection_screen.dart';

class AdministrationDetailScreen extends StatefulWidget {
  final Administration administration;

  const AdministrationDetailScreen({super.key, required this.administration});

  @override
  State<AdministrationDetailScreen> createState() =>
      _AdministrationDetailScreenState();
}

class _AdministrationDetailScreenState
    extends State<AdministrationDetailScreen> {
  final CatalogueService _catalogueService = CatalogueService();
  List<Service> _services = [];
  bool _enChargement = true;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    _chargerServices();
  }

  Future<void> _chargerServices() async {
    setState(() {
      _enChargement = true;
      _erreur = null;
    });
    try {
      final services = await _catalogueService
          .recupererServices(widget.administration.id);
      setState(() {
        _services = services;
        _enChargement = false;
      });
    } catch (e) {
      setState(() {
        _erreur = messageErreurApi(e);
        _enChargement = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.administration.nom),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 16, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    widget.administration.ville,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Services disponibles',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
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
      return EtatErreur(message: _erreur!, onReessayer: _chargerServices);
    }
    if (_services.isEmpty) {
      return Center(
        child: Text(
          'Aucun service disponible pour le moment',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }
    return ListView.separated(
      itemCount: _services.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final service = _services[index];
        return ServiceCard(
          service: service,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CreneauSelectionScreen(
                  administration: widget.administration,
                  service: service,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
