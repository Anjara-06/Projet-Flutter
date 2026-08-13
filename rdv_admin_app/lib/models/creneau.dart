/// Représente un créneau horaire disponible pour un service.
class Creneau {
  final int id;
  final int serviceId;
  final DateTime date;
  final String heureDebut;
  final String heureFin;
  final bool disponible;

  const Creneau({
    required this.id,
    required this.serviceId,
    required this.date,
    required this.heureDebut,
    required this.heureFin,
    required this.disponible,
  });

  factory Creneau.fromJson(Map<String, dynamic> json) {
    return Creneau(
      id: json['id'] as int,
      serviceId: json['service_id'] as int,
      date: DateTime.parse(json['date'] as String),
      heureDebut: json['heure_debut'] as String,
      heureFin: json['heure_fin'] as String,
      disponible: json['disponible'] as bool? ?? true,
    );
  }
}
