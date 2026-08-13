import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../services/notification_service.dart';
import 'home/home_screen.dart';
import 'history/history_screen.dart';
import 'profile/profile_screen.dart';

/// Structure principale de l'app : gère la navigation entre
/// Accueil / Mes rendez-vous / Profil via une barre flottante.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _indexActif = 0;

  final List<Widget> _ecrans = const [
    HomeScreen(),
    HistoryScreen(),
    ProfileScreen(),
  ];

  final List<_NavItem> _items = const [
    _NavItem(icone: Icons.home_rounded, label: 'Accueil'),
    _NavItem(icone: Icons.confirmation_number_rounded, label: 'Mes RDV'),
    _NavItem(icone: Icons.person_rounded, label: 'Profil'),
  ];

  @override
  void initState() {
    super.initState();
    // Demande la permission de notifications une fois arrivé sur l'app
    // principale (donc après connexion/inscription).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService().demanderPermission();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _indexActif,
        children: _ecrans,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(_items.length, (index) {
                final estActif = index == _indexActif;
                final item = _items[index];
                return Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => setState(() => _indexActif = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        gradient: estActif ? AppColors.degradePrincipal : null,
                        color: estActif ? null : Colors.transparent,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: estActif
                            ? [
                                BoxShadow(
                                  color: AppColors.accent.withValues(alpha: 0.35),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            item.icone,
                            size: 22,
                            color: estActif
                                ? AppColors.onAccent
                                : AppColors.textMuted,
                          ),
                          if (estActif) ...[
                            const SizedBox(width: 8),
                            Text(
                              item.label,
                              style: const TextStyle(
                                color: AppColors.onAccent,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icone;
  final String label;
  const _NavItem({required this.icone, required this.label});
}
