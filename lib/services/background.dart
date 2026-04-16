import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:captured_content_reader/database/app_database.dart';
import 'package:captured_content_reader/services/article_ingestion_service.dart';
import 'package:captured_content_reader/services/storage_access.dart';

const String channelId = 'import_status_v5';
const String successChannelId = 'import_success_v5';
const int notificationId = 888;
const int successNotificationId = 889;

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  print("!!! ISOLATE BOOT SEQUENCE START !!!");

  final localNav = FlutterLocalNotificationsPlugin();

  // Wichtig: Initialisierung innerhalb von onStart für das Isolate
  await localNav.initialize(
    settings: const InitializationSettings(
      // <--- 'settings:' hinzufügen
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );

  service.on('stop_service').listen((event) {
    service.stopSelf();
  });

  service.on('start_watching').listen((event) {
    print("!!! EVENT ERHALTEN IM HINTERGRUND: $event !!!");
    if (event == null) return;

    final String fileName = event['fileName'];
    final String sourcePath =
        event['sourcePath'] ?? '/storage/emulated/0/Download';
    final String targetPath = event['targetPath'];

    // Wir nutzen try-catch hier, um Fehler beim Aufruf zu fangen
    try {
      _pollFile(fileName, sourcePath, targetPath, service, localNav);
    } catch (e) {
      print("!!! FEHLER BEIM START VON POLLFILE: $e !!!");
    }
  });
  Timer.periodic(const Duration(seconds: 10), (t) {
    print("!!! BACKGROUND HEARTBEAT !!!");
  });
}

Future<void> _pollFile(
  String fileName,
  String sourcePath,
  String targetPath,
  ServiceInstance service,
  FlutterLocalNotificationsPlugin localNav,
) async {
  print("!!! POLLFILE FUNKTION GESTARTET !!!");

  // Wir bauen den Pfad manuell, um path_provider/p.join zu vermeiden,
  // falls diese Pakete Probleme machen
  final fullPath = sourcePath.endsWith('/')
      ? '$sourcePath$fileName'
      : '$sourcePath/$fileName';
  final sourceFile = File(fullPath);

  print("!!! SUCHE DATEI UNTER: $fullPath !!!");

  int attempts = 0;
  const int maxAttempts = 120;

  Timer.periodic(const Duration(seconds: 1), (timer) async {
    attempts++;
    print(
      "!!! POLL ATTEMPT $attempts - Exists: ${sourceFile.existsSync()} !!!",
    );

    if (attempts > maxAttempts) {
      timer.cancel();
      print("!!! POLL TIMEOUT !!!");
      service.stopSelf();
      return;
    }

    if (sourceFile.existsSync()) {
      print("!!! DATEI GEFUNDEN !!!");
      timer.cancel();

      // Erst hier rufen wir die schwere Logik auf
      try {
        await _processImport(sourceFile, targetPath, localNav, service);
      } catch (e) {
        print("!!! FEHLER IN _processImport: $e !!!");
      }
    }
  });
}

Future<void> _processImport(
  File file,
  String targetPath,
  FlutterLocalNotificationsPlugin localNav,
  ServiceInstance service,
) async {
  try {
    final db = AppDatabase();
    final storageService = StorageService();
    final ingestionService = ArticleIngestionService(storageService, db);

    // Wir nutzen die Ingest-Logik, die wir bereits angepasst haben
    final String articleId = await ingestionService.ingestDownloadedFile(
      file,
      overrideTargetPath: targetPath,
    );

    await db.close();

    // Event zurück an die Main App (für UI Refresh)
    service.invoke('import_success', {'articleId': articleId});

    // Erfolgs-Notification
    const androidDetails = AndroidNotificationDetails(
      successChannelId,
      'Import Erfolg',
      importance: Importance.max,
      priority: Priority.high,
    );

    // lib/services/background.dart -> _processImport

    await localNav.show(
      id: successNotificationId, // Named parameter 'id'
      title: 'Import erfolgreich!', // Named parameter 'title'
      body: 'Der Artikel wurde hinzugefügt.', // Named parameter 'body'
      notificationDetails: const NotificationDetails(
        // Named parameter
        android: AndroidNotificationDetails(
          successChannelId,
          'Import Erfolg',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      payload: articleId,
    );
  } catch (e) {
    print("Background Ingestion Error: $e");
  } finally {
    await Future.delayed(const Duration(seconds: 2));
    service.stopSelf();
  }
}

Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();
  final localNav = FlutterLocalNotificationsPlugin();

  // Beide Channels erstellen
  const channels = [
    AndroidNotificationChannel(
      channelId,
      'Import Status',
      importance: Importance.low,
    ),
    AndroidNotificationChannel(
      successChannelId,
      'Import Erfolg',
      importance: Importance.max,
    ),
  ];

  for (var channel in channels) {
    await localNav
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false,
      isForegroundMode: true,
      notificationChannelId: channelId,
      initialNotificationTitle: 'CleanRead aktiv',
      initialNotificationContent: 'Bereit für Import...',
      foregroundServiceNotificationId: notificationId,
    ),
    iosConfiguration: IosConfiguration(),
  );
}
