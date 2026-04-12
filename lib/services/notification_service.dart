import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Inicializar notificaciones
  Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidSettings);

    await _flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Inicializar zonas horarias
    tz.initializeTimeZones();

    // Pedir permisos
    await _requestPermissions();
  }

  // Permisos (Android 13+)
  Future<void> _requestPermissions() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  // Cuando el usuario toca la notificación
  void _onNotificationTap(NotificationResponse response) {
    print('Notificación tocada: ${response.payload}');
  }

  // Mostrar notificación inmediata
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'default_channel',
          'Notificaciones de Stocky',
          channelDescription: 'Recordatorios de productos por caducar',
          importance: Importance.high,
          priority: Priority.high,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payload,
    );
  }

  // Programar notificación
  // Future<void> scheduleNotification({
  //   required int id,
  //   required String title,
  //   required String body,
  //   required DateTime scheduledDate,
  //   String? payload,
  // }) async {
  //   const AndroidNotificationDetails androidDetails =
  //       AndroidNotificationDetails(
  //         'default_channel',
  //         'Notificaciones de Stocky',
  //         channelDescription: 'Recordatorios de productos por caducar',
  //         importance: Importance.high,
  //         priority: Priority.high,
  //       );

  //   const NotificationDetails notificationDetails = NotificationDetails(
  //     android: androidDetails,
  //   );

  //   await _flutterLocalNotificationsPlugin.zonedSchedule(
  //     id: id,
  //     title: title,
  //     body: body,
  //     scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
  //     notificationDetails: notificationDetails,
  //     androidScheduleMode: AndroidScheduleMode.exact,
  //     payload: payload,
  //   );
  //   print(' Notificación programada con ID: $id para: $scheduledDate');
  // }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    print('[1] Entró a scheduleNotification con ID: $id');

    try {
      final androidDetails = AndroidNotificationDetails(
        'default_channel',
        'Notificaciones de Stocky',
        channelDescription: 'Recordatorios de productos por caducar',
        importance: Importance.high,
        priority: Priority.high,
      );
      print('[2] AndroidNotificationDetails creado');

      final notificationDetails = NotificationDetails(android: androidDetails);
      print('[3] NotificationDetails creado');

      final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);
      print('[4] Fecha convertida a TZ: $tzDate');

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exact,
        payload: payload,
      );
      print('[5] Notificación programada exitosamente');
    } catch (e) {
      print('ERROR en scheduleNotification: $e');
    }
  }

  // Cancelar una notificación
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id: id);
  }

  // Cancelar todas
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}
