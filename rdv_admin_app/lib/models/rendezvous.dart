import 'administration.dart';
import 'creneau.dart';
import 'service.dart';

/// Représente un rendez-vous confirmé, avec son ticket numérique.
class RendezVous {
  final int id;
  final String numeroRdv;
  final String codeQr;
  final Administration administration;
  final Service service;
  final Creneau creneau;
  final DateTime dateCreation;

  const RendezVous({
    required this.id,
    required this.numeroRdv,
    required this.codeQr,
    required this.administration,
    required this.service,
    required this.creneau,
    required this.dateCreation,
  });
}
