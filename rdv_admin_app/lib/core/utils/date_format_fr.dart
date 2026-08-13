/// Petites fonctions pour afficher les dates en français,
/// sans dépendance externe.
class DateFormatFr {
  DateFormatFr._();

  static const List<String> _joursCourts = [
    'Lun',
    'Mar',
    'Mer',
    'Jeu',
    'Ven',
    'Sam',
    'Dim',
  ];

  static const List<String> _moisLongs = [
    'janvier',
    'février',
    'mars',
    'avril',
    'mai',
    'juin',
    'juillet',
    'août',
    'septembre',
    'octobre',
    'novembre',
    'décembre',
  ];

  /// Ex. "Lun"
  static String jourCourt(DateTime date) {
    return _joursCourts[date.weekday - 1];
  }

  /// Ex. "12 août"
  static String jourEtMois(DateTime date) {
    return '${date.day} ${_moisLongs[date.month - 1]}';
  }
}
