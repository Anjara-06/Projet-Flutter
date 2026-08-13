import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/erreur_api.dart';
import '../../models/administration.dart';
import '../../providers/auth_provider.dart';
import '../../services/catalogue_service.dart';
import '../../widgets/administration_card.dart';
import '../../widgets/etat_chargement.dart';
import '../../widgets/etat_erreur.dart';
import '../booking/administration_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final CatalogueService _catalogueService = CatalogueService();

  List<Administration> _toutesLesAdministrations = [];
  List<Administration> _resultats = [];
  bool _enChargement = true;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filtrer);
    _chargerAdministrations();
  }

  @override
  void dispose() {
    _searchController.removeListener(_filtrer);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _chargerAdministrations() async {
    setState(() {
      _enChargement = true;
      _erreur = null;
    });

    try {
      final administrations = await _catalogueService.recupererAdministrations();
      setState(() {
        _toutesLesAdministrations = administrations;
        _resultats = administrations;
        _enChargement = false;
      });
    } catch (e) {
      setState(() {
        _erreur = messageErreurApi(e);
        _enChargement = false;
      });
    }
  }

  void _filtrer() {
    final requete = _searchController.text.trim().toLowerCase();
    setState(() {
      _resultats = _toutesLesAdministrations.where((admin) {
        return admin.nom.toLowerCase().contains(requete) ||
            admin.ville.toLowerCase().contains(requete);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _buildHeader(context),
              const SizedBox(height: 20),
              _buildSearchField(),
              const SizedBox(height: 24),
              Text(
                'Administrations disponibles',
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
      return EtatErreur(message: _erreur!, onReessayer: _chargerAdministrations);
    }
    if (_resultats.isEmpty) {
      return _buildEtatVide();
    }
    return RefreshIndicator(
      onRefresh: _chargerAdministrations,
      child: ListView.separated(
        itemCount: _resultats.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final administration = _resultats[index];
          return AdministrationCard(
            administration: administration,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AdministrationDetailScreen(
                    administration: administration,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final prenom = context.watch<AuthProvider>().utilisateur?.prenom ?? '';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bonjour', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 2),
            Text(prenom, style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: AppColors.degradePrincipal,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.notifications_none_rounded,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: const InputDecoration(
        hintText: 'Rechercher une administration',
        prefixIcon: Icon(Icons.search_rounded, color: AppColors.textMuted),
      ),
    );
  }

  Widget _buildEtatVide() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          children: [
            const Icon(Icons.search_off_rounded,
                size: 40, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(
              'Aucune administration trouvée',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
