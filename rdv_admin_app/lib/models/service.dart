/// Représente un service proposé par une administration
/// (ex. "Certificat de résidence", "Acte de naissance"...)
class Service {
  final int id;
  final int administrationId;
  final String nom;
  final String description;
  final int dureeMinutes;

  const Service({
    required this.id,
    required this.administrationId,
    required this.nom,
    required this.description,
    required this.dureeMinutes,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] as int,
      administrationId: json['administration_id'] as int,
      nom: json['nom'] as String,
      description: json['description'] as String? ?? '',
      dureeMinutes: json['duree_minutes'] as int? ?? 30,
    );
  }
}
