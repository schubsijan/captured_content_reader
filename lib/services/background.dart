import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:captured_content_reader/services/storage_access.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:captured_content_reader/database/app_database.dart';
import 'package:captured_content_reader/services/article_ingestion_service.dart';
import 'package:path/path.dart' as p;

// WICHTIG: Neue IDs, damit Android die Settings neu lädt!
const statusChannelId = 'import_status_v5';
const successChannelId = 'import_success_v5';

const notificationId = 888;
const successNotificationId = 889;

Future<void> initializeBackgroundService() async {
  if (!Platform.isAndroid && !Platform.isIOS) {
    return;
  }
  final service = FlutterBackgroundService();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // 1. Channel für den laufenden Service (ruhig)
  const AndroidNotificationChannel statusChannel = AndroidNotificationChannel(
    statusChannelId,
    'Import Status',
    description: 'Zeigt an, dass auf einen Download gewartet wird',
    importance: Importance.low, // Soll nicht bimmeln, nur da sein
  );

  // 2. Channel für den Erfolg (LAUT & POP-UP)
  const AndroidNotificationChannel successChannel = AndroidNotificationChannel(
    successChannelId,
    'Import Erfolg',
    description: 'Benachrichtigung bei erfolgreichem Import',
    importance: Importance.max, // WICHTIG: Max für Heads-Up (Pop-up)
    playSound: true,
    enableVibration: true,
  );

  // Beide Channels erstellen
  var androidPlugin = flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  await androidPlugin?.createNotificationChannel(statusChannel);
  await androidPlugin?.createNotificationChannel(successChannel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: false,
      notificationChannelId:
          statusChannelId, // Service nutzt den ruhigen Channel
      initialNotificationTitle: 'CleanRead',
      initialNotificationContent: 'Bereit...',
      foregroundServiceNotificationId: notificationId,
    ),
    iosConfiguration: IosConfiguration(),
  );
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  final localNav = FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await localNav.initialize(initializationSettings);

  final storageService = StorageService();

  service.on('start_watching').listen((event) async {
    if (event == null) return;
    final String fileName = event['fileName'];

    // "Warte..." Notification auf dem STATUS Channel (Low Prio)
    await localNav.show(
      notificationId,
      'Warte auf Download...',
      'Suche nach: $fileName',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          statusChannelId, // <--- Ruhiger Channel
          'Import Status',
          importance: Importance.low,
          priority: Priority.low,
          ongoing: true,
          indeterminate: true,
          category: AndroidNotificationCategory.service,
        ),
      ),
    );

    _pollFile(fileName, service, localNav, storageService);
  });

  service.on('stop_service').listen((event) {
    service.stopSelf();
  });
}

Future<void> _pollFile(
  String fileName,
  ServiceInstance service,
  FlutterLocalNotificationsPlugin localNav,
  StorageService storageService,
) async {
  final Directory downloadDir = Directory('/storage/emulated/0/Download');
  final File targetFile = File(p.join(downloadDir.path, fileName));

  int attempts = 0;
  const int maxAttempts = 600;

  Timer.periodic(const Duration(seconds: 1), (timer) async {
    attempts++;

    if (attempts > maxAttempts) {
      timer.cancel();
      // Fehler auch auf dem Success Channel (damit man es mitbekommt)
      await localNav.show(
        notificationId,
        'Fehler',
        'Zeitüberschreitung beim Download.',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            successChannelId,
            'Import Erfolg',
            importance: Importance.high,
          ),
        ),
      );
      service.stopSelf();
      return;
    }

    if (await targetFile.exists()) {
      int size1 = await targetFile.length();
      await Future.delayed(const Duration(milliseconds: 500));
      int size2 = await targetFile.length();

      if (size1 > 0 && size1 == size2) {
        timer.cancel();
        await _processImport(targetFile, localNav, service, storageService);
      }
    }
  });
}

Future<void> _processImport(
  File file,
  FlutterLocalNotificationsPlugin localNav,
  ServiceInstance service,
  StorageService storageService,
) async {
  try {
    // 1. Instanzen erzeugen (im Background Isolate)
    final db = AppDatabase();
    final ingestionService = ArticleIngestionService(storageService, db);

    // 2. Die ganze Magie passiert jetzt hier sauber gekapselt
    final String articleId = await ingestionService.ingestDownloadedFile(file);

    // DB Verbindung schließen, da wir im Background fertig sind
    await db.close();

    // 3. Notification (bleibt wie vorher, nur sauberer)
    await localNav.show(
      successNotificationId,
      'Import erfolgreich!',
      'Tippe zum Öffnen.',
      NotificationDetails(
        android: AndroidNotificationDetails(
          successChannelId,
          'Import Erfolg',
          importance: Importance.max,
          priority: Priority.max,
          playSound: false,
          enableVibration: false,
          timeoutAfter: 5000,
        ),
      ),
      payload: articleId,
    );
  } catch (e) {
    print("Background Ingestion Error: $e");
    // Fehler Notification wäre hier gut
  } finally {
    await Future.delayed(const Duration(milliseconds: 500));
    service.stopSelf();
  }
}
