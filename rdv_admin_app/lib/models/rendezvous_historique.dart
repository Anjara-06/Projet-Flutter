/// Représente un rendez-vous tel que renvoyé par GET /api/rendezvous
/// (déjà enrichi avec les infos du service et de l'administration côté backend).
class RendezVousHistorique {
  final int id;
  final String numeroRdv;
  final String codeQr;
  final String statut;
  final DateTime date;
  final String heureDebut;
  final String heureFin;
  final String serviceNom;
  final String administrationNom;
  final String administrationVille;

  const RendezVousHistorique({
    required this.id,
    required this.numeroRdv,
    required this.codeQr,
    required this.statut,
    required this.date,
    required this.heureDebut,
    required this.heureFin,
    required this.serviceNom,
    required this.administrationNom,
    required this.administrationVille,
  });

  bool get estAVenir => statut == 'confirme' && !date.isBefore(
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
      );

  factory RendezVousHistorique.fromJson(Map<String, dynamic> json) {
    return RendezVousHistorique(
      id: json['id'] as int,
      numeroRdv: json['numero_rdv'] as String,
      codeQr: json['code_qr'] as String,
      statut: json['statut'] as String,
      date: DateTime.parse(json['date'] as String),
      heureDebut: json['heure_debut'] as String,
      heureFin: json['heure_fin'] as String,
      serviceNom: json['service_nom'] as String,
      administrationNom: json['administration_nom'] as String,
      administrationVille: json['administration_ville'] as String,
    );
  }
}
