import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/fond_degrade.dart';
import '../../widgets/gradient_button.dart';
import '../main_shell.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _motDePasseController = TextEditingController();
  bool _motDePasseVisible = false;

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _motDePasseController.dispose();
    super.dispose();
  }

  Future<void> _sInscrire() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final succes = await authProvider.inscription(
      nom: _nomController.text.trim(),
      prenom: _prenomController.text.trim(),
      email: _emailController.text.trim(),
      motDePasse: _motDePasseController.text,
      telephone: _telephoneController.text.trim().isEmpty
          ? null
          : _telephoneController.text.trim(),
    );

    if (!mounted) return;

    if (succes) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShell()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.erreur ?? "Erreur d'inscription")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chargement = context.watch<AuthProvider>().chargementAction;

    return Scaffold(
      appBar: AppBar(title: const Text('Créer un compte')),
      body: FondDegrade(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _prenomController,
                          decoration:
                              const InputDecoration(hintText: 'Prénom'),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Requis'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _nomController,
                          decoration: const InputDecoration(hintText: 'Nom'),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Requis'
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'Email',
                      prefixIcon: Icon(Icons.mail_outline_rounded,
                          color: AppColors.textMuted),
                    ),
                    validator: (valeur) {
                      if (valeur == null || valeur.trim().isEmpty) {
                        return "L'email est requis";
                      }
                      if (!valeur.contains('@')) {
                        return 'Email invalide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _telephoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: 'Téléphone (optionnel)',
                      prefixIcon: Icon(Icons.phone_outlined,
                          color: AppColors.textMuted),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _motDePasseController,
                    obscureText: !_motDePasseVisible,
                    decoration: InputDecoration(
                      hintText: 'Mot de passe (6 caractères min.)',
                      prefixIcon: const Icon(Icons.lock_outline_rounded,
                          color: AppColors.textMuted),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _motDePasseVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.textMuted,
                        ),
                        onPressed: () => setState(
                            () => _motDePasseVisible = !_motDePasseVisible),
                      ),
                    ),
                    validator: (valeur) {
                      if (valeur == null || valeur.length < 6) {
                        return 'Minimum 6 caractères';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  GradientButton(
                    label: 'Créer mon compte',
                    enCours: chargement,
                    onPressed: chargement ? null : _sInscrire,
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
