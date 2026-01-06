import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(initializationSettings);

    // Criar o canal explicitamente (Ajuda muito em telemóveis como o S60)
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      // Criação manual do canal de alta importância
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel', // ID fixo
        'Alertas Urgentes',
        description: 'Canal para lembretes de leitura',
        importance: Importance.max,
        playSound: true,
      );

      await androidPlugin.createNotificationChannel(channel);

      // Pedir permissões (Android 13+ e Alarmes exatos)
      await androidPlugin.requestNotificationsPermission();
      await androidPlugin.requestExactAlarmsPermission();
    }
  }

  // --- FUNÇÃO PARA TESTAR AGORA ---
  static Future<void> testInstant() async {
    await _notificationsPlugin.show(
      888,
      'Teste de Som! 🔔',
      'Se estás a ouvir isto, o sistema de som funciona.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'Alertas Urgentes',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        ),
      ),
    );
  }

  static Future<void> scheduleNotification(int id, String title, String body, DateTime scheduledDate) async {
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'Alertas Urgentes',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}