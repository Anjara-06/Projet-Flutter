# Diagrammes UML — explications pour le rapport

## 1. Diagramme de cas d'utilisation

### Acteurs
- **Citoyen non authentifié** : peut créer un compte ou se connecter, mais n'a accès à rien d'autre.
- **Citoyen authentifié** : accède à toutes les fonctionnalités métier de l'application.

### Cas d'utilisation principaux
| Cas d'utilisation | Description |
|---|---|
| S'inscrire | Création d'un compte (nom, prénom, email, mot de passe) |
| Se connecter | Authentification par email/mot de passe, génération d'un token JWT |
| Rechercher une administration | Liste et recherche parmi les administrations disponibles |
| Consulter les services | Liste des services proposés par une administration choisie |
| Consulter les créneaux disponibles | Affichage des créneaux libres pour un service, par date |
| Prendre un rendez-vous | Réservation d'un créneau ; **inclut** la consultation des créneaux et génère un ticket |
| Recevoir un ticket avec QR code | Génération automatique d'un numéro de RDV et d'un QR code |
| Consulter l'historique | Liste des rendez-vous passés, à venir et annulés |
| Annuler un rendez-vous | **Étend** la consultation de l'historique ; libère le créneau |
| Consulter son profil | Affichage des informations personnelles |
| Se déconnecter | Invalide la session locale |

### Relations
- **Inclusion** (`include`) : "Prendre un rendez-vous" inclut obligatoirement "Consulter les créneaux disponibles" (on ne peut pas réserver sans d'abord voir les créneaux).
- **Extension** (`extend`) : "Annuler un rendez-vous" étend "Consulter l'historique" (l'annulation est une action optionnelle déclenchée depuis l'historique).

---

## 2. Diagramme de classes

### Classes et leur rôle
- **Utilisateur** : un citoyen inscrit dans l'application.
- **Administration** : une entité administrative (mairie, Fokontany...).
- **Service** : une prestation proposée par une administration (ex. certificat de résidence).
- **Creneau** : un horaire disponible pour un service donné, à une date précise.
- **RendezVous** : la réservation effective d'un créneau par un utilisateur.
- **Notification** : un message envoyé à un utilisateur (rappel avant RDV, etc.).

### Cardinalités (relations)
| Relation | Cardinalité | Signification |
|---|---|---|
| Utilisateur → RendezVous | 1 → 0..* | Un utilisateur peut avoir plusieurs rendez-vous, un rendez-vous appartient à un seul utilisateur |
| Administration → Service | 1 → 0..* | Une administration propose plusieurs services |
| Service → Creneau | 1 → 0..* | Un service a plusieurs créneaux possibles |
| Creneau → RendezVous | 1 → 0..1 | Un créneau est réservé par au plus un rendez-vous à la fois |
| Utilisateur → Notification | 1 → 0..* | Un utilisateur peut recevoir plusieurs notifications |
| RendezVous → Notification | 0..1 → 0..* | Un rendez-vous peut générer plusieurs notifications (rappels) |

*Ce modèle correspond exactement au schéma PostgreSQL utilisé dans le backend (`schema.sql`).*

---

## Comment utiliser ces diagrammes dans ton rapport

Les fichiers `.mermaid` peuvent être :
- Collés directement dans un bloc de code Mermaid si ton outil de rapport le supporte (Notion, GitHub, GitLab, Obsidian...)
- Rendus en image via [mermaid.live](https://mermaid.live) : colle le contenu, exporte en PNG/SVG, puis insère l'image dans ton Word/PDF
