// Test de démarrage de l'application.
//
// Vérifie qu'au lancement, sans session enregistrée, l'app affiche
// bien l'écran de connexion (comportement attendu du SplashScreen).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rdv_admin_app/main.dart';
import 'package:rdv_admin_app/providers/auth_provider.dart';

void main() {
  testWidgets(
    "L'app affiche l'écran de connexion si aucune session n'existe",
    (WidgetTester tester) async {
      // Simule un stockage local vide (aucun token sauvegardé).
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
          child: const RdvAdminApp(),
        ),
      );

      // Laisse le temps au SplashScreen de vérifier la session
      // (opération asynchrone) avant de vérifier le résultat.
      await tester.pumpAndSettle();

      expect(find.text('Content de te revoir'), findsOneWidget);
    },
  );
}