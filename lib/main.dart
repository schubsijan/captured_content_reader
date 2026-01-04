import 'package:captured_content_reader/services/background.dart';
import 'package:captured_content_reader/services/import_starter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:captured_content_reader/database/app_database.dart';
import 'package:captured_content_reader/features/library/ui/library_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:captured_content_reader/features/reader/ui/article_reader_screen.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

class AndroidUtils {
  static const _platform = MethodChannel(
    'com.example.captured_content_reader/android',
  );

  static Future<void> minimizeApp() async {
    try {
      await _platform.invokeMethod('minimizeApp');
    } catch (e) {
      print("Minimize Error: $e");
    }
  }

  static Future<void> closeAppCompletely() async {
    try {
      await _platform.invokeMethod('finishAndRemoveTask');
    } catch (e) {
      SystemNavigator.pop();
    }
  }
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  if (Platform.isAndroid || Platform.isIOS) {
    await initializeBackgroundService();
  } else if (Platform.isLinux) {
    print("Linux erkannt: Starte HTTP Server Modus...");
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ImportStarter _importStarter = ImportStarter();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Steuert, ob wir den weißen Hintergrund (Bibliothek) sehen
  // Startet false (transparent), damit Deep-Link Imports im Hintergrund laufen können.
  bool _showMainUI = false;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  void _initApp() async {
    if (Platform.isAndroid || Platform.isIOS) {
      await Permission.notification.request();
      _initLocalNotifications();

      // Check: Wurde App durch Benachrichtigung gestartet?
      final notifLaunchDetails = await flutterLocalNotificationsPlugin
          .getNotificationAppLaunchDetails();

      if (notifLaunchDetails?.didNotificationLaunchApp == true) {
        final payload = notifLaunchDetails!.notificationResponse?.payload;
        if (payload != null) {
          // Direkt zum Artikel navigieren
          Future.delayed(Duration.zero, () => _openArticle(payload));
        }
        // Import Service initialisieren, aber UI Logik ist durch Notification erledigt
        _importStarter.init(onCheckComplete: null);
        return;
      }
    }

    if (Platform.isLinux) {
      setState(() {
        _showMainUI = true;
      });
    }

    // CHECK: Normaler Start oder Deep Link (Browser Share)?
    _importStarter.init(
      onCheckComplete: (foundLink) {
        if (foundLink) {
          // Szenario 2: Browser Link -> App bleibt transparent/unsichtbar während Import
        } else {
          // Szenario 1: Normaler Start -> Bibliothek anzeigen
          if (mounted) {
            setState(() {
              _showMainUI = true;
            });
          }
        }
      },
    );
  }

  void _initLocalNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          // Klick auf Benachrichtigung während App läuft (oder im Hintergrund ist)
          _openArticle(response.payload!);
        }
      },
    );
  }

  void _openArticle(String articleId) {
    // 1. App sichtbar machen (falls sie transparent war)
    if (!_showMainUI) {
      setState(() {
        _showMainUI = true;
      });
    }

    // 2. Zum Reader navigieren
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => ArticleReaderScreen(articleId: articleId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CleanRead',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
        // Wenn _showMainUI false ist, ist der Hintergrund transparent (sieht aus wie geschlossen)
        scaffoldBackgroundColor: _showMainUI
            ? Colors.white
            : Colors.transparent,
      ),
      home: _showMainUI
          ? const LibraryScreen()
          : const Scaffold(backgroundColor: Colors.transparent),
    );
  }
}
