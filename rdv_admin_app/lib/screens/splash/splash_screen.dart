import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../main_shell.dart';
import '../../widgets/etat_chargement.dart';

/// Premier écran affiché : vérifie si l'utilisateur a déjà une session
/// enregistrée, puis redirige vers l'accueil ou la connexion.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().verifierSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.chargementInitial) {
          return const Scaffold(body: EtatChargement());
        }
        return authProvider.estConnecte
            ? const MainShell()
            : const LoginScreen();
      },
    );
  }
}
