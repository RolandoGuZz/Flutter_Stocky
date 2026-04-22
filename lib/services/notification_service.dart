import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      tz.initializeTimeZones();

      // Configuración para Android
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

      // Configuración para iOS (si aplica)
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      final initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      );

      await _notificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      // Solicitar permisos en Android 13+
      if (Platform.isAndroid) {
        await _requestPermissions();
      }

      // Crear canal de notificaciones
      await _createNotificationChannel();

      _isInitialized = true;
    } catch (e) {
      print('Error inicializando NotificationService: $e');
    }
  }

  Future<void> _requestPermissions() async {
    try {
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidPlugin != null) {
        await androidPlugin.requestNotificationsPermission();
      }
    } catch (e) {
      print('Error solicitando permisos: $e');
    }
  }

  Future<void> _createNotificationChannel() async {
    try {
      const channel = AndroidNotificationChannel(
        'stocky_channel',
        'Recordatorios de Stocky',
        description: 'Notificaciones cuando los productos están por caducar',
        importance: Importance.high,
      );

      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);
    } catch (e) {
      print('Error creando canal: $e');
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    print('Notificación tocada con payload: ${response.payload}');
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (!_isInitialized) {
      await init();
    }

    if (scheduledDate.isBefore(DateTime.now())) {
      print('La fecha para la notificación ya pasó');
      return;
    }

    try {
      const androidDetails = AndroidNotificationDetails(
        'stocky_channel',
        'Recordatorios de Stocky',
        channelDescription:
            'Notificaciones cuando los productos están por caducar',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
      );

      const notificationDetails = NotificationDetails(android: androidDetails);

      final tzDateTime = tz.TZDateTime.from(scheduledDate, tz.local);

      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tzDateTime,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );

      print('Notificación programada: $title para $scheduledDate');
    } catch (e) {
      print('Error programando notificación: $e');
    }
  }

  Future<void> showTestNotification() async {
    if (!_isInitialized) {
      await init();
    }

    try {
      const androidDetails = AndroidNotificationDetails(
        'stocky_channel',
        'Recordatorios de Stocky',
        channelDescription:
            'Notificaciones cuando los productos están por caducar',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const notificationDetails = NotificationDetails(android: androidDetails);

      await _notificationsPlugin.show(
        id: 0,
        title: 'Stocky',
        body: 'Notificaciones funcionando correctamente',
        notificationDetails: notificationDetails,
      );
    } catch (e) {
      print('Error mostrando notificación: $e');
    }
  }

  Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) {
      await init();
    }

    try {
      const androidDetails = AndroidNotificationDetails(
        'stocky_channel',
        'Recordatorios de Stocky',
        channelDescription:
            'Notificaciones cuando los productos están por caducar',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
      );

      const notificationDetails = NotificationDetails(android: androidDetails);

      await _notificationsPlugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
        payload: payload,
      );
    } catch (e) {
      print('Error mostrando notificación inmediata: $e');
    }
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id: id);
  }

  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
}
