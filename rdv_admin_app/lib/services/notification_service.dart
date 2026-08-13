import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Gère la programmation de rappels locaux avant un rendez-vous.
///
/// IMPORTANT : ne fonctionne que sur Android/iOS, pas sur le web
/// (limitation du package flutter_local_notifications).
class NotificationService {
  NotificationService._interne();
  static final NotificationService _instance = NotificationService._interne();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialise = false;

  /// À appeler une fois, au démarrage de l'app.
  Future<void> initialiser() async {
    if (_initialise) return;

    tz_data.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Indian/Antananarivo'));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);
    _initialise = true;
  }

  /// Demande la permission d'afficher des notifications
  /// (obligatoire sur Android 13+ et iOS).
  Future<void> demanderPermission() async {
    final implementationAndroid = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await implementationAndroid?.requestNotificationsPermission();

    final implementationIos = _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    await implementationIos?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// Programme un rappel 1h avant un rendez-vous.
  /// [id] doit être unique par rendez-vous (on utilise l'id du RDV en base).
  /// Ne fait rien si le rappel tomberait dans le passé.
  Future<void> programmerRappel({
    required int id,
    required String titre,
    required String corps,
    required DateTime dateHeureRdv,
  }) async {
    final dateRappel = dateHeureRdv.subtract(const Duration(hours: 1));
    if (dateRappel.isBefore(DateTime.now())) {
      return;
    }

    await _plugin.zonedSchedule(
      id,
      titre,
      corps,
      tz.TZDateTime.from(dateRappel, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'rappels_rdv',
          'Rappels de rendez-vous',
          channelDescription: 'Rappel envoyé 1 heure avant un rendez-vous',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Annule le rappel programmé pour un rendez-vous (ex. si annulé).
  Future<void> annulerRappel(int id) async {
    await _plugin.cancel(id);
  }
}
