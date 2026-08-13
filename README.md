# Fotoana — Prise de rendez-vous administratif

> Projet L2 Génie Logiciel — Flutter — Madagascar
> Sujet A.4 : *Application mobile de prise de rendez-vous dans une administration*

Application mobile permettant à un citoyen de rechercher une administration, choisir un service, réserver un créneau horaire et obtenir un ticket numérique avec QR code — avec rappel automatique avant le rendez-vous.

---

## Sommaire

1. [Aperçu des fonctionnalités](#aperçu-des-fonctionnalités)
2. [Stack technique](#stack-technique)
3. [Architecture](#architecture)
4. [Structure du projet](#structure-du-projet)
5. [Prérequis](#prérequis)
6. [Installation — Backend](#installation--backend)
7. [Installation — Application Flutter](#installation--application-flutter)
8. [Documentation de l'API](#documentation-de-lapi)
9. [Diagrammes UML](#diagrammes-uml)
10. [Limitations connues](#limitations-connues)
11. [Tests](#tests)

---

## Aperçu des fonctionnalités

| Fonctionnalité | Statut |
|---|---|
| Authentification (inscription / connexion / déconnexion) | ✅ |
| Recherche d'administrations | ✅ |
| Consultation des services par administration | ✅ |
| Sélection de créneau (date + heure) | ✅ |
| Prise de rendez-vous avec verrouillage anti-double-réservation | ✅ |
| Ticket numérique avec QR code | ✅ |
| Historique des rendez-vous (à venir / passés / annulés) | ✅ |
| Annulation de rendez-vous | ✅ |
| Rappel automatique 1h avant le rendez-vous (notification locale) | ✅ *(Android/iOS uniquement)* |
| Gestion des erreurs et états de chargement | ✅ |

---

## Stack technique

**Frontend**
- Flutter / Dart
- `provider` — gestion d'état
- `dio` — client HTTP
- `shared_preferences` — persistance locale (session JWT)
- `qr_flutter` — génération de QR code
- `flutter_local_notifications` + `timezone` — rappels programmés
- `google_fonts` — typographie (Poppins)

**Backend**
- Node.js + Express
- PostgreSQL (via `pg`)
- Authentification JWT (`jsonwebtoken`, `bcryptjs`)
- CORS activé

---

## Architecture

```
┌──────────────────┐        HTTPS/REST         ┌───────────────────┐
│   Flutter Mobile  │ ─────────────────────────▶ │   API REST         │
│   (Provider)       │ ◀───────────────────────── │  (Node.js/Express)  │
└──────────────────┘         JSON + JWT           └─────────┬──────────┘
        │                                                    │
        │ Notifications locales                              ▼
        ▼                                             ┌──────────────┐
  Rappels avant RDV                                    │  PostgreSQL   │
                                                        └──────────────┘
```

---

## Structure du projet

```
Fotoana/
├── rdv_admin_app/              # Application Flutter
│   ├── lib/
│   │   ├── core/
│   │   │   ├── theme/          # Couleurs, thème global
│   │   │   └── utils/          # Formatage dates, gestion erreurs API
│   │   ├── models/             # Structures de données (Administration, Service, Creneau...)
│   │   ├── services/           # Appels API (Dio) + notifications + stockage local
│   │   ├── providers/          # Gestion d'état (AuthProvider)
│   │   ├── screens/            # Un dossier par écran/fonctionnalité
│   │   │   ├── auth/
│   │   │   ├── splash/
│   │   │   ├── home/
│   │   │   ├── booking/
│   │   │   ├── ticket/
│   │   │   ├── history/
│   │   │   └── profile/
│   │   └── widgets/            # Composants réutilisables (cards, états de chargement...)
│   └── test/
│       └── widget_test.dart
│
└── backend/                     # API REST
    ├── src/
    │   ├── config/db.js         # Connexion PostgreSQL
    │   ├── middleware/auth.js   # Vérification du token JWT
    │   ├── routes/               # auth, administrations, rendezvous
    │   ├── schema.sql            # Schéma de la base de données
    │   ├── seed.js                # Données de test
    │   └── server.js              # Point d'entrée Express
    └── package.json
```

---

## Prérequis

- [Flutter SDK](https://docs.flutter.dev/get-started/install) installé et fonctionnel (`flutter --version`)
- [Node.js](https://nodejs.org/) 18+ installé (`node --version`)
- [PostgreSQL](https://www.postgresql.org/download/) installé et démarré
- Un émulateur Android/iOS (pour tester les notifications ; le web fonctionne pour le reste)

---

## Installation — Backend

### 1. Installer les dépendances
```bash
cd backend
npm install
```

### 2. Créer la base de données
```bash
psql -U postgres
```
```sql
CREATE DATABASE rdv_admin;
\q
```

### 3. Configurer les variables d'environnement
Renomme `.env.example` en `.env` et renseigne ton mot de passe PostgreSQL :
```
PORT=3000
DATABASE_URL=postgresql://postgres:TON_MOT_DE_PASSE@localhost:5432/rdv_admin
JWT_SECRET=change_moi_par_une_longue_chaine_secrete_aleatoire
```

### 4. Créer les tables
```bash
psql -U postgres -d rdv_admin -f src/schema.sql
```

### 5. Remplir avec des données de test
```bash
npm run seed
```

### 6. Démarrer le serveur
```bash
npm start
```
Le serveur écoute sur `http://localhost:3000`. Vérifie avec `http://localhost:3000/api/health`.

---

## Installation — Application Flutter

### 1. Dépendances (déjà présentes dans `pubspec.yaml`)
```bash
cd rdv_admin_app
flutter pub get
```

### 2. Configuration Android (obligatoire pour les notifications)
Dans `android/app/src/main/AndroidManifest.xml`, à l'intérieur de `<manifest>`, avant `<application>` :
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE"/>
```

### 3. Lancer l'application
Le backend doit être démarré au préalable.

```bash
flutter run
```
- Sur **émulateur Android/iOS** : toutes les fonctionnalités marchent, notifications incluses.
- Sur **Chrome (web)** : tout fonctionne sauf les notifications de rappel (voir [Limitations connues](#limitations-connues)).

> **Note** : l'URL de l'API est configurée dans `lib/services/api_service.dart` (`http://localhost:3000/api`). Si tu testes sur un émulateur Android, remplace `localhost` par `10.0.2.2`.

---

## Documentation de l'API

Base URL : `http://localhost:3000/api`

### Authentification
| Méthode | Route | Description | Auth requise |
|---|---|---|---|
| POST | `/auth/register` | Créer un compte | Non |
| POST | `/auth/login` | Se connecter | Non |

### Catalogue
| Méthode | Route | Description | Auth requise |
|---|---|---|---|
| GET | `/administrations` | Liste des administrations | Non |
| GET | `/administrations/:id/services` | Services d'une administration | Non |
| GET | `/administrations/services/:serviceId/creneaux` | Créneaux disponibles d'un service | Non |

### Rendez-vous
| Méthode | Route | Description | Auth requise |
|---|---|---|---|
| POST | `/rendezvous` | Prendre un rendez-vous (`{ creneau_id }`) | **Oui** (Bearer token) |
| GET | `/rendezvous` | Mes rendez-vous | **Oui** |
| PATCH | `/rendezvous/:id/annuler` | Annuler un rendez-vous | **Oui** |

Toutes les routes protégées attendent un en-tête :
```
Authorization: Bearer <token>
```

---

## Diagrammes UML

Voir les fichiers séparés (générés lors du développement) :
- `diagramme-cas-utilisation.mermaid`
- `diagramme-classes.mermaid`
- `explication-diagrammes-uml.md`

À visualiser/exporter en image via [mermaid.live](https://mermaid.live).

---

## Limitations connues

- **Notifications** : `flutter_local_notifications` ne fonctionne pas sur Flutter Web. Les rappels ne sont programmés/testables que sur Android ou iOS.
- **Distance/géolocalisation** : le champ "distance" affiché sur les cards d'administration n'est pas encore branché sur une vraie géolocalisation (amélioration possible en V2).
- **Rôle administrateur** : hors périmètre de ce MVP (uniquement le parcours citoyen). Un dashboard agent/admin serait une évolution naturelle.
- **QR code** : généré côté client à partir d'un identifiant unique renvoyé par le serveur ; il n'est pas encore vérifié par un scanner côté guichet (hors scope MVP).

---

## Tests

```bash
cd rdv_admin_app
flutter test
```

Le test présent vérifie qu'au démarrage, sans session enregistrée, l'application affiche bien l'écran de connexion.

---

*Document réalisé dans le cadre du module Flutter — L2 Génie Logiciel — INSI — 2026.*
