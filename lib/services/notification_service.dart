import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../navigation/navigation_handler.dart';

class NotificationService {
  final Ref _ref;
  final _notifications = FlutterLocalNotificationsPlugin();

  NotificationService(this._ref);

  Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _notifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handlePayload(response.payload);
      },
    );

    // FALL 1: App war komplett geschlossen und wird durch Klick gestartet
    final details = await _notifications.getNotificationAppLaunchDetails();
    if (details != null && details.didNotificationLaunchApp) {
      _handlePayload(details.notificationResponse?.payload);
    }
  }

  void _handlePayload(String? payload) {
    if (payload != null && payload.isNotEmpty) {
      print("Notification Klick erkannt. Payload: $payload");
      // Wir geben dem Navigator 300ms Zeit, falls die App gerade erst bootet
      Future.delayed(const Duration(milliseconds: 300), () {
        _ref.read(navigationHandlerProvider).openReader(payload);
      });
    }
  }

  // Hilfsmethode für den Import-Erfolg
  Future<void> showImportSuccess(String articleId, String title) async {
    const androidDetails = AndroidNotificationDetails(
      'import_success_v5',
      'Import Erfolg',
      importance: Importance.max,
      priority: Priority.high,
    );

    await _notifications.show(
      id: 889, // Named parameter 'id'
      title: 'Import erfolgreich!', // Named parameter 'title'
      body: title, // Named parameter 'body'
      notificationDetails: const NotificationDetails(
        android: androidDetails,
      ), // Named parameter
      payload: articleId,
    );
  }
}

final notificationServiceProvider = Provider((ref) => NotificationService(ref));
